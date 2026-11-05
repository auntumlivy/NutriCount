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

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
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

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
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
                  LabeledField(
                    label: 'Password',
                    controller: _pass,
                    obscure: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: Text('New here? Create an account',
                        style: serif(
                            size: AppText.body,
                            weight: FontWeight.w400,
                            color: AppColors.textHint)),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                      label: 'Login', onPressed: _login, loading: _loading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
