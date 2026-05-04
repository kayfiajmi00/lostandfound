import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/nsu_logo.dart';
import '../services/session_service.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final Animation<double>   _logoScale;
  late final Animation<double>   _logoFade;
  late final Animation<double>   _textFade;
  late final Animation<Offset>   _textSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _textCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _textFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
        begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final ok = await SessionService.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) =>
            ok ? const MainShell() : const LoginScreen()));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _logoCtrl,
          builder: (_, __) => FadeTransition(
            opacity: _logoFade,
            child: ScaleTransition(
              scale: _logoScale,
              child: const NsuLogo(size: 90),
            ),
          ),
        ),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: _textCtrl,
          builder: (_, __) => FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: Column(children: [
                Text('NSU Recovery',
                  style: GoogleFonts.nunitoSans(
                    color: AppColors.textPrimary,
                    fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Lost & Found Platform',
                  style: GoogleFonts.nunitoSans(
                    color: AppColors.textMuted, fontSize: 13)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 60),
        AnimatedBuilder(
          animation: _textCtrl,
          builder: (_, __) => FadeTransition(
            opacity: _textFade,
            child: SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withOpacity(0.5))),
          ),
        ),
      ])),
    );
  }
}
