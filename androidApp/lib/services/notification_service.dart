// In-app notification service — no external packages needed
// Shows overlay banners inside the app (works on all platforms)
import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationService {
  static final List<_NotifData> _queue = [];
  static OverlayEntry? _current;
  static BuildContext? _ctx;

  static void setContext(BuildContext ctx) => _ctx = ctx;

  static void show({
    required String title,
    required String body,
    bool isEmergency = false,
  }) {
    _queue.add(_NotifData(title: title, body: body, isEmergency: isEmergency));
    _showNext();
  }

  static void newMessage(String from, String preview) =>
      show(title: 'New message from $from', body: preview);

  static void emergencyAlert(String itemTitle, String location) =>
      show(
        title: '🚨 Emergency Alert',
        body: '"$itemTitle" last seen at $location. Please help!',
        isEmergency: true,
      );

  static void claimAlert(String itemTitle, String claimerName) =>
      show(
        title: 'Someone claimed your item!',
        body: '$claimerName wants to claim "$itemTitle"',
      );

  static void _showNext() {
    if (_queue.isEmpty || _current != null) return;
    final ctx = _ctx;
    if (ctx == null) return;

    final data = _queue.removeAt(0);
    _current = OverlayEntry(builder: (_) => _NotifBanner(
      data: data,
      onDismiss: () {
        _current?.remove();
        _current = null;
        Future.delayed(const Duration(milliseconds: 300), _showNext);
      },
    ));
    Overlay.of(ctx).insert(_current!);
  }
}

class _NotifData {
  final String title, body;
  final bool isEmergency;
  _NotifData({required this.title, required this.body,
      this.isEmergency = false});
}

class _NotifBanner extends StatefulWidget {
  final _NotifData data;
  final VoidCallback onDismiss;
  const _NotifBanner({required this.data, required this.onDismiss});
  @override
  State<_NotifBanner> createState() => _NotifBannerState();
}

class _NotifBannerState extends State<_NotifBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
        begin: const Offset(0, -1), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = widget.data.isEmergency
        ? AppColors.error : AppColors.primary;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16, right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16, offset: const Offset(0, 4),
                )],
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.data.isEmergency
                        ? Icons.warning_amber_rounded
                        : Icons.notifications_outlined,
                    color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.data.title, style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(widget.data.body, style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                )),
                const Icon(Icons.close, color: AppColors.textMuted, size: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
