import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _sidCtrl   = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _nameCtrl.dispose(); _sidCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if ([_nameCtrl, _sidCtrl, _emailCtrl, _passCtrl].any((c) => c.text.isEmpty)) {
      setState(() => _error = 'Please fill all fields'); return;
    }
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final res = await ApiService.signup(
        fullName: _nameCtrl.text.trim(),
        studentId: _sidCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (res['status'] == 'success') {
        setState(() => _success = 'Account created! Please sign in.');
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Failed');
      }
    } catch (_) {
      setState(() => _error = 'Connection error — is XAMPP running?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Create Account', style: TextStyle(
              color: AppColors.primary, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Join NSU Recovery Platform', style: TextStyle(
              color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 32),

            if (_error   != null) _msgBox(_error!,   AppColors.red),
            if (_success != null) _msgBox(_success!, AppColors.green),

            _lbl('Full Name'),     const SizedBox(height: 8),
            _field(_nameCtrl,  'Your full name',       Icons.person_outline),
            const SizedBox(height: 18),

            _lbl('Student ID'),    const SizedBox(height: 8),
            _field(_sidCtrl,   'e.g. 2211653',         Icons.badge_outlined),
            const SizedBox(height: 18),

            _lbl('NSU Email'),     const SizedBox(height: 8),
            _field(_emailCtrl, 'name@northsouth.edu',  Icons.email_outlined,
                type: TextInputType.emailAddress),
            const SizedBox(height: 18),

            _lbl('Password'),      const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Min 6 characters',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('CREATE ACCOUNT', style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 24),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ',
                  style: TextStyle(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Sign In',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Text(t, style: const TextStyle(
    color: AppColors.textSecondary, fontSize: 12,
    fontWeight: FontWeight.w700, letterSpacing: 0.4));

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) =>
    TextField(
      controller: c, keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20)));

  Widget _msgBox(String msg, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(msg, style: TextStyle(color: color, fontSize: 13)));
}
