import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int myUserId;
  final int contactId;
  final String contactName;
  final int itemId;
  const ChatScreen({
    super.key,
    required this.myUserId,
    required this.contactId,
    required this.contactName,
    required this.itemId,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<dynamic> _msgs = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() { super.initState(); _loadMsgs(); }

  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _loadMsgs() async {
    setState(() { _loading = true; _error = null; });
    try {
      final m = await ApiService.getMessages(
          widget.myUserId, widget.contactId, widget.itemId);
      if (mounted) setState(() { _msgs = m; _loading = false; });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom());
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Could not load messages.'; });
    }
  }

  void _scrollBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _msgCtrl.clear();
    final optimistic = {
      'sender_id': widget.myUserId.toString(),
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
      '_pending': true,
    };
    setState(() { _msgs = [..._msgs, optimistic]; _sending = true; });
    _scrollBottom();
    try {
      final res = await ApiService.sendMessage(
        senderId:   widget.myUserId,
        receiverId: widget.contactId,
        itemId:     widget.itemId,
        message:    text,
      );
      if (res['status'] == 'success') {
        await _loadMsgs();
      } else {
        setState(() {
          _msgs = _msgs.where((m) => m['_pending'] != true).toList();
          _error = 'Failed to send.';
          _sending = false;
        });
      }
    } catch (_) {
      setState(() {
        _msgs = _msgs.where((m) => m['_pending'] != true).toList();
        _error = 'Connection error.';
        _sending = false;
      });
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              widget.contactName.isNotEmpty
                  ? widget.contactName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary,
                  fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.contactName,
              style: const TextStyle(color: AppColors.textPrimary,
                  fontSize: 15, fontWeight: FontWeight.w600)),
            const Text('NSU Student',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined,
                color: AppColors.textMuted, size: 20),
            onPressed: _loadMsgs),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(children: [
        if (_error != null)
          Material(
            color: AppColors.error.withOpacity(0.07),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 12))),
                GestureDetector(
                  onTap: () => setState(() => _error = null),
                  child: const Icon(Icons.close, color: AppColors.error, size: 14)),
              ]),
            ),
          ),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2))
            : _msgs.isEmpty
              ? _emptyChat()
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: _msgs.length,
                  itemBuilder: (_, i) => _bubble(_msgs[i] as Map<String, dynamic>),
                ),
        ),
        _inputBar(),
      ]),
    );
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final isMine = msg['sender_id'].toString() == widget.myUserId.toString();
    final isPending = msg['_pending'] == true;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4  : 16),
          ),
          border: isMine ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg['message']?.toString() ?? '',
              style: TextStyle(
                color: isMine ? Colors.white : AppColors.textPrimary,
                fontSize: 14, height: 1.4)),
            const SizedBox(height: 4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_fmtTime(msg['timestamp']?.toString() ?? ''),
                style: TextStyle(
                  color: isMine ? Colors.white54 : AppColors.textMuted,
                  fontSize: 10)),
              if (isPending) ...[
                const SizedBox(width: 4),
                SizedBox(width: 9, height: 9,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white.withOpacity(0.5))),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  String _fmtTime(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }

  Widget _inputBar() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(top: false, child: Row(children: [
      Expanded(
        child: TextField(
          controller: _msgCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Message...',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
          onSubmitted: (_) => _send(),
          textInputAction: TextInputAction.send,
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: _sending ? null : _send,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _sending ? AppColors.surfaceLight : AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: _sending
            ? const Center(child: SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)))
            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    ])),
  );

  Widget _emptyChat() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.chat_bubble_outline, color: AppColors.textMuted, size: 44),
    const SizedBox(height: 14),
    Text('Start chatting with ${widget.contactName.split(" ").first}',
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
  ]));
}
