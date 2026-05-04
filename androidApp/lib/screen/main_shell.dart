import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'report_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _idx;

  @override
  void initState() {
    super.initState();
    _idx = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register context for in-app notifications
    NotificationService.setContext(context);
  }

  static const _screens = [
    HomeScreen(), ExploreScreen(), ReportScreen(),
    MessagesScreen(), ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        IndexedStack(index: _idx, children: _screens),
        Positioned(
          bottom: 86,
          right: 14,
          child: _ChatbotFAB(),
        ),
      ]),
      bottomNavigationBar: _NavBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
      ),
    );
  }
}

class _ChatbotFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen())),
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 14, offset: const Offset(0, 4),
          )],
        ),
        child: const Icon(Icons.smart_toy_outlined,
            color: Colors.white, size: 22),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _NavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(context, 0, Icons.home_outlined,    Icons.home_rounded,    'Home'),
              _item(context, 1, Icons.search_outlined,  Icons.search_rounded,  'Explore'),
              _centerPost(context),
              _item(context, 3, Icons.inbox_outlined,   Icons.inbox_rounded,   'Messages'),
              _item(context, 4, Icons.person_outline,   Icons.person_rounded,  'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext ctx, int idx, IconData off, IconData on, String label) {
    final active = currentIndex == idx;
    return GestureDetector(
      onTap: () => onTap(idx),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? on : off,
              color: active ? AppColors.primary : AppColors.textMuted, size: 22),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.nunitoSans(
            color: active ? AppColors.primary : AppColors.textMuted,
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          )),
        ]),
      ),
    );
  }

  Widget _centerPost(BuildContext ctx) {
    final active = currentIndex == 2;
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.add_rounded,
          color: active ? Colors.white : AppColors.primary,
          size: 26),
      ),
    );
  }
}
