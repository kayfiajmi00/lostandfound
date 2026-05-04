import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _convs = [];
  bool _loading = true;
  int? _myId;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final uid = await SessionService.getUserId();
    setState(() => _myId = uid);
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final c = await ApiService.getConversations(uid);
      setState(() { _convs = c; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text('Messages', style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
              : _convs.isEmpty
                ? _empty()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _convs.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: AppColors.border),
                      itemBuilder: (_, i) =>
                          _tile(_convs[i] as Map<String, dynamic>),
                    ),
                  ),
          ),
        ],
      )),
    );
  }

  Widget _tile(Map<String, dynamic> c) {
    final name      = c['full_name']?.toString() ?? 'Unknown';
    final lastMsg   = c['last_message']?.toString() ?? '';
    final contactId = int.tryParse(c['contact_id']?.toString() ?? '0') ?? 0;
    final itemId    = int.tryParse(c['item_id']?.toString()    ?? '0') ?? 0;
    final initial   = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatScreen(
          myUserId: _myId!, contactId: contactId,
          contactName: name, itemId: itemId))),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(initial, style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w700)),
      ),
      title: Text(name, style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: lastMsg.isNotEmpty
        ? Text(lastMsg, style: const TextStyle(
              color: AppColors.textMuted, fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis)
        : null,
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textMuted, size: 18),
    );
  }

  Widget _empty() => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.chat_bubble_outline, color: AppColors.textMuted, size: 44),
    SizedBox(height: 14),
    Text('No messages yet', style: TextStyle(
        color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
    SizedBox(height: 4),
    Text('Verify a claim to start chatting',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
  ]));
}
