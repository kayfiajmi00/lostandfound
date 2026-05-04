import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _thinking = false;

  static const _starters = [
    'How do I report a lost item?',
    'How does verification work?',
    'How to find my lost item?',
    'How does chat work?',
  ];

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(
      text:
          "Hi! I'm the NSU Recovery Assistant.\n\nI can help you use this app — reporting items, finding things, verification, and more. What would you like to know?",
      isBot: true,
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _thinking) return;
    _ctrl.clear();

    setState(() {
      _msgs.add(_Msg(text: text, isBot: false));
      _thinking = true;
    });
    _scrollBottom();

    try {
      final history = _msgs
          .where((m) => !m.isThinking)
          .map((m) => {
                'role': m.isBot ? 'assistant' : 'user',
                'content': m.text,
              })
          .toList();

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 500,
          'system':
              '''You are the NSU Recovery Assistant for the NSU Lost & Found mobile app at North South University, Dhaka.

Help students with:
- Reporting lost/found items (tap the + button)
- Searching in Explore tab
- Security verification (answer questions to contact reporter)
- Using the chat system
- Managing profile and posts

Be concise, friendly, and helpful. Answer in the same language as the user (Bengali or English).''',
          'messages': history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final contentList = data['content'] as List<dynamic>;
        final textBlock = contentList.firstWhere(
          (c) => c['type'] == 'text',
          orElse: () =>
              <String, dynamic>{'text': 'Sorry, I could not respond.'},
        );
        final reply =
            textBlock['text']?.toString() ?? 'Sorry, I could not respond.';
        setState(() {
          _thinking = false;
          _msgs.add(_Msg(text: reply, isBot: true));
        });
      } else {
        _setError('Could not get a response (${response.statusCode}).');
      }
    } catch (_) {
      _setError('Connection error. Please try again.');
    }
    _scrollBottom();
  }

  void _setError(String msg) {
    setState(() {
      _thinking = false;
      _msgs.add(_Msg(text: msg, isBot: true, isError: true));
    });
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showStarters = _msgs.length == 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Assistant',
                  style: GoogleFonts.nunitoSans(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              Text('Powered by Claude',
                  style: GoogleFonts.nunitoSans(
                      color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ]),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _msgs.length + (showStarters ? 1 : 0),
            itemBuilder: (_, i) {
              if (showStarters && i == 1) return _starterChips();
              return _bubble(_msgs[i]);
            },
          ),
        ),
        if (_thinking) _typingIndicator(),
        _inputBar(),
      ]),
    );
  }

  Widget _bubble(_Msg msg) {
    return Align(
      alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: msg.isError
              ? AppColors.error.withOpacity(0.07)
              : msg.isBot
                  ? AppColors.surface
                  : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isBot ? 4 : 16),
            bottomRight: Radius.circular(msg.isBot ? 16 : 4),
          ),
          border: msg.isBot
              ? Border.all(
                  color: msg.isError
                      ? AppColors.error.withOpacity(0.3)
                      : AppColors.border)
              : null,
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isError
                ? AppColors.error
                : msg.isBot
                    ? AppColors.textPrimary
                    : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _starterChips() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Quick questions:',
                  style: GoogleFonts.nunitoSans(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _starters
                  .map((s) => GestureDetector(
                        onTap: () => _send(s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(s,
                              style: GoogleFonts.nunitoSans(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      );

  Widget _typingIndicator() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 0, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _Dot(delay: i * 200)),
          ),
        ),
      );

  Widget _inputBar() => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: GoogleFonts.nunitoSans(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: GoogleFonts.nunitoSans(
                      color: AppColors.textMuted, fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _thinking ? null : () => _send(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _thinking ? AppColors.surfaceLight : AppColors.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: _thinking ? AppColors.textMuted : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ]),
        ),
      );
}

// ─── Data class ──────────────────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isBot;
  final bool isError;
  final bool isThinking;

  _Msg({
    required this.text,
    required this.isBot,
    this.isError = false,
    this.isThinking = false,
  });
}

// ─── Animated dot for typing indicator ───────────────────────────────────────
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _anim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color:
                Color.lerp(AppColors.textMuted, AppColors.primary, _anim.value),
            shape: BoxShape.circle,
          ),
          transform: Matrix4.translationValues(0, -3 * _anim.value, 0),
        ),
      );
}
