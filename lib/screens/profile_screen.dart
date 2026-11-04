import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fs = DataService.instance;
  final _nama = TextEditingController();
  final _dob = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await _fs.getUser();
    _nama.text = u?['nama'] ?? '';
    _dob.text = u?['tglLahir'] ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (d != null) _dob.text = BmiUtils.fmtTanggal(d);
  }

  Future<void> _simpan() async {
    if (_nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong.')));
      return;
    }
    setState(() => _saving = true);
    await _fs.updateUser({'nama': _nama.text.trim(), 'tglLahir': _dob.text});
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profil diperbarui.')));
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _dob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Profil', style: serif(size: 34))),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.sageLight, AppColors.sage],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: const Icon(Icons.person, size: 84, color: Colors.white),
            ),
            const SizedBox(height: 16),
            LabeledField(label: 'Nama', controller: _nama),
            const SizedBox(height: 16),
            LabeledField(
                label: 'Date of Birth',
                controller: _dob,
                readOnly: true,
                onTap: _pilihTanggal),
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'Simpan Perubahan', onPressed: _simpan, loading: _saving),
          ],
        ),
      ),
    );
  }
}
