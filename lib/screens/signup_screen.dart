import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _dob = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (d != null) _dob.text = BmiUtils.fmtTanggal(d);
  }

  Future<void> _signUp() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService().signUp(
        nama: _nama.text,
        email: _email.text,
        password: _pass.text,
        tglLahir: _dob.text,
      );
      // AuthGate otomatis pindah ke aplikasi utama; tutup halaman ini.
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
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
    _nama.dispose();
    _email.dispose();
    _pass.dispose();
    _dob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Form(
            key: _form,
            child: Column(
              children: [
                Text('Create New\nAccount',
                    textAlign: TextAlign.center,
                    style: serif(size: AppText.hero, color: AppColors.sageLight)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('Already Registered? Log in here.',
                      style: serif(
                          size: AppText.body,
                          weight: FontWeight.w400,
                          color: AppColors.textHint)),
                ),
                const SizedBox(height: 28),
                LabeledField(
                  label: 'Name',
                  controller: _nama,
                  hint: 'Nama lengkap',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Email',
                  controller: _email,
                  hint: 'email@contoh.com',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Email tidak valid'
                      : null,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Password',
                  controller: _pass,
                  hint: '*****',
                  obscure: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Date of Birth',
                  controller: _dob,
                  hint: 'DD/MM/YYYY',
                  readOnly: true,
                  onTap: _pilihTanggal,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Tanggal lahir wajib diisi' : null,
                ),
                const SizedBox(height: 34),
                PrimaryButton(
                    label: 'Sign up', onPressed: _signUp, loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
