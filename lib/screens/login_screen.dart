import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _sembunyi = true;

  bool get _sedangProses => _loading || _loadingGoogle;

  Future<void> _login() async {
    if (!_form.currentState!.validate() || _sedangProses) return;
    setState(() => _loading = true);
    try {
      await AuthService().login(_email.text, _pass.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AuthService.pesanError(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    if (_sedangProses) return;
    setState(() => _loadingGoogle = true);
    try {
      await AuthService().loginDenganGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AuthService.pesanError(e))));
      }
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  Future<void> _lupaPassword() async {
    final resetEmail = TextEditingController(text: _email.text.trim());
    bool mengirim = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Reset Password', style: serif(size: AppText.subtitle)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan email akunmu. Kami akan mengirimkan tautan untuk mengatur ulang password.',
                style:
                TextStyle(fontSize: AppText.small, color: AppColors.textHint),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: resetEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Alamat email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: mengirim ? null : () => Navigator.pop(ctx),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textHint)),
            ),
            TextButton(
              onPressed: mengirim
                  ? null
                  : () async {
                final email = resetEmail.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Masukkan alamat email yang valid.')),
                  );
                  return;
                }
                setDialogState(() => mengirim = true);
                try {
                  await AuthService().kirimResetPassword(email);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Link reset password dikirim ke $email. Cek kotak masuk atau folder Spam.'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() => mengirim = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AuthService.pesanError(e))),
                    );
                  }
                }
              },
              child: mengirim
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.sageDark),
              )
                  : const Text(
                'Kirim Link',
                style: TextStyle(
                    color: AppColors.sageDark,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), resetEmail.dispose);
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Widget _kolomPassword() {
    return Column(
      children: [
        Text('PASSWORD',
            style: serif(
                size: AppText.small,
                weight: FontWeight.w400,
                color: AppColors.textHint,
                spacing: 2.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pass,
          obscureText: _sembunyi,
          textAlign: TextAlign.center,
          validator: (v) =>
          (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
          decoration: InputDecoration(
            prefixIcon: const SizedBox(width: 48),
            suffixIcon: IconButton(
              tooltip: _sembunyi ? 'Tampilkan password' : 'Sembunyikan password',
              icon: Icon(
                _sembunyi
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textHint,
              ),
              onPressed: () => setState(() => _sembunyi = !_sembunyi),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tombolGoogle() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _sedangProses ? null : _loginGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: const BorderSide(color: AppColors.sage, width: 1.5),
          shape: const StadiumBorder(),
        ),
        child: _loadingGoogle
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.sageDark),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.sageLight.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'G',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.sageDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Masuk dengan Google',
                overflow: TextOverflow.ellipsis,
                style: serif(
                  size: AppText.body,
                  weight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        color: AppColors.sageLight,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.eco, color: Colors.white, size: 84),
                  ),
                  const SizedBox(height: 32),
                  Text('NutriCount',
                      style: serif(
                          size: AppText.body,
                          weight: FontWeight.w400,
                          color: AppColors.textHint)),
                  const SizedBox(height: 8),
                  Text('Login',
                      style: serif(size: AppText.hero, color: AppColors.sageLight)),
                  const SizedBox(height: 28),
                  LabeledField(
                    label: 'Email',
                    controller: _email,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Email tidak valid'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _kolomPassword(),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _sedangProses ? null : _lupaPassword,
                    child: Text(
                      'Forgot password?',
                      style: serif(
                        size: AppText.small,
                        weight: FontWeight.w600,
                        color: AppColors.sageDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: Text('New here? Create an account',
                        style: serif(
                            size: AppText.body,
                            weight: FontWeight.w400,
                            color: AppColors.textHint)),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                      label: 'Login',
                      onPressed: _sedangProses ? () {} : _login,
                      loading: _loading),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: AppColors.sageLight.withValues(alpha: 0.8))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('atau',
                            style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: AppText.small)),
                      ),
                      Expanded(
                          child: Divider(
                              color: AppColors.sageLight.withValues(alpha: 0.8))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _tombolGoogle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}