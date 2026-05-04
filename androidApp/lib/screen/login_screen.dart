import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/nsu_logo.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.login(email, pass);
      if (res['status'] == 'success') {
        await SessionService.save(res['user'] as Map<String, dynamic>);
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainShell()));
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Login failed');
      }
    } catch (_) {
      setState(() => _error = 'Connection error — is XAMPP running?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 52),
            // Logo centered
            const Center(child: NsuLogo(size: 72, showText: false)),
            const SizedBox(height: 28),
            Center(
                child: Text('NSU Recovery',
                    style: GoogleFonts.nunitoSans(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800))),
            const SizedBox(height: 4),
            Center(
                child: Text('Sign in to your account',
                    style: GoogleFonts.nunitoSans(
                        color: AppColors.textMuted, fontSize: 13))),
            const SizedBox(height: 36),

            if (_error != null) _errBox(_error!),

            // Email label
            Text('Email',
                style: GoogleFonts.nunitoSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.nunitoSans(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'john@northsouth.edu',
                prefixIcon: Icon(Icons.email_outlined,
                    color: AppColors.textMuted, size: 18),
              ),
            ),
            const SizedBox(height: 18),

            Text('Password',
                style: GoogleFonts.nunitoSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: GoogleFonts.nunitoSans(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textMuted, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('LOG IN',
                        style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'If you don\'t have an account, please contact your admin.',
                style: GoogleFonts.nunitoSans(
                    color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text("Don't have an account? ",
                  style: GoogleFonts.nunitoSans(
                      color: AppColors.textMuted, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text('Sign up',
                    style: GoogleFonts.nunitoSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ])),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _errBox(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg,
                  style: GoogleFonts.nunitoSans(
                      color: AppColors.error, fontSize: 13))),
        ]),
      );
}
