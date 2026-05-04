import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme.dart';

class ApiService {
  static const String _b = kBaseUrl;

  // AUTH
  static Future<Map<String, dynamic>> login(String email, String pass) async {
    final r = await http.post(Uri.parse('$_b/auth_api.php'),
        body: {'action': 'login', 'email': email, 'password': pass});
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    final r = await http.post(Uri.parse('$_b/auth_api.php'), body: {
      'action': 'signup',
      'full_name': fullName,
      'student_id': studentId,
      'email': email,
      'password': password,
    });
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // ITEMS
  static Future<List<dynamic>> getItems({int? catId, String? type}) async {
    String url = '$_b/test_connection.php?dummy=1';
    if (catId != null) url += '&cat_id=$catId';
    if (type  != null) url += '&type=$type';
    final r = await http.get(Uri.parse(url));
    final d = jsonDecode(r.body) as Map<String, dynamic>;
    return d['data'] as List<dynamic>? ?? [];
  }

  // MESSAGES
  static Future<List<dynamic>> getConversations(int userId) async {
    final r = await http.post(Uri.parse('$_b/mobile_messages.php'),
        body: {'action': 'get_conversations', 'user_id': '$userId'});
    final d = jsonDecode(r.body) as Map<String, dynamic>;
    return d['data'] as List<dynamic>? ?? [];
  }

  static Future<List<dynamic>> getMessages(int userId, int contactId, int itemId) async {
    final r = await http.post(Uri.parse('$_b/mobile_messages.php'), body: {
      'action': 'get_messages',
      'user_id': '$userId',
      'contact_id': '$contactId',
      'item_id': '$itemId',
    });
    final d = jsonDecode(r.body) as Map<String, dynamic>;
    return d['data'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> sendMessage({
    required int senderId,
    required int receiverId,
    required int itemId,
    required String message,
  }) async {
    final r = await http.post(Uri.parse('$_b/mobile_messages.php'), body: {
      'action': 'send_message',
      'sender_id': '$senderId',
      'receiver_id': '$receiverId',
      'item_id': '$itemId',
      'message': message,
    });
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // MY POSTS
  static Future<List<dynamic>> getMyPosts(int userId) async {
    final r = await http.post(Uri.parse('$_b/auth_api.php'),
        body: {'action': 'get_my_posts', 'user_id': '$userId'});
    final d = jsonDecode(r.body) as Map<String, dynamic>;
    return d['data'] as List<dynamic>? ?? [];
  }

  static Future<Map<String, dynamic>> deletePost(int itemId) async {
    final r = await http.post(Uri.parse('$_b/auth_api.php'),
        body: {'action': 'delete_post', 'item_id': '$itemId'});
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
