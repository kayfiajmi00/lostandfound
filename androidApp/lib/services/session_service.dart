import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kId    = 'user_id';
  static const _kName  = 'full_name';
  static const _kEmail = 'email';
  static const _kSid   = 'student_id';

  static Future<void> save(Map<String, dynamic> user) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt   (_kId,    int.tryParse(user['user_id'].toString()) ?? 0);
    await p.setString(_kName,  user['full_name']  ?? '');
    await p.setString(_kEmail, user['email']      ?? '');
    await p.setString(_kSid,   user['student_id'] ?? '');
  }

  static Future<int?>    getUserId()  async => (await SharedPreferences.getInstance()).getInt(_kId);
  static Future<String?> getName()    async => (await SharedPreferences.getInstance()).getString(_kName);
  static Future<String?> getEmail()   async => (await SharedPreferences.getInstance()).getString(_kEmail);
  static Future<String?> getStudentId() async => (await SharedPreferences.getInstance()).getString(_kSid);
  static Future<bool>    isLoggedIn() async => ((await getUserId()) ?? 0) > 0;
  static Future<void>    clear()      async => (await SharedPreferences.getInstance()).clear();
}
