import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';
import 'community_recipes_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fs = DataService.instance;
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  Uint8List? _foto;
  bool _fotoBusy = false;


  static const _batasFotoByte = 200 * 1024;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await _fs.getUser();
    _nama.text = u?['nama'] ?? '';
    _email.text = u?['email'] ?? '';
    _dob.text = u?['tglLahir'] ?? '';
    final f = (u?['foto'] as String?) ?? '';
    if (f.isNotEmpty) {
      try {
        _foto = base64Decode(f);
      } catch (_) {
        _foto = null;
      }
    }
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

    Future<void> _ambilFoto(ImageSource sumber) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: sumber,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > _batasFotoByte) {
        messenger.showSnackBar(SnackBar(
            content: Text(
                'Foto terlalu besar (${(bytes.length / 1024).round()} KB, maks 200 KB). Pilih foto lain.')));
        return;
      }
      if (!mounted) return;
      setState(() {
        _foto = bytes;
        _fotoBusy = true;
      });
      await _simpanFoto(base64Encode(bytes));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka foto: $e')));
    }
  }

  Future<void> _hapusFoto() async {
    setState(() {
      _foto = null;
      _fotoBusy = true;
    });
    await _simpanFoto('');
  }

  Future<void> _simpanFoto(String data) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _fs.updateUser({'foto': data}).timeout(const Duration(seconds: 15));
      messenger.showSnackBar(SnackBar(
          content: Text(
              data.isEmpty ? 'Foto profil dihapus.' : 'Foto profil diperbarui.')));
    } on TimeoutException {
      messenger.showSnackBar(const SnackBar(
          content: Text('Koneksi lambat. Foto akan tersimpan saat online.')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Gagal menyimpan foto: $e')));
    } finally {
      if (mounted) setState(() => _fotoBusy = false);
    }
  }

  void _menuFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil dari kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _ambilFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _ambilFoto(ImageSource.gallery);
              },
            ),
            if (_foto != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Hapus foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _hapusFoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

    Widget _avatar() {
    return GestureDetector(
      onTap: _fotoBusy ? null : _menuFoto,
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipOval(
                child: _foto != null
                    ? Image.memory(_foto!,
                    fit: BoxFit.cover, gaplessPlayback: true)
                    : Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.sageLight, AppColors.sage],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  child: const Icon(Icons.person,
                      size: 84, color: Colors.white),
                ),
              ),
            ),
            if (_fotoBusy)
              Positioned.fill(
                child: ClipOval(
                  child: Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 4,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.photo_camera,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
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
                child: Text('Profil', style: serif(size: AppText.hero))),
            const SizedBox(height: 16),
            _avatar(),
            const SizedBox(height: 16),
            LabeledField(label: 'Nama', controller: _nama),
            if (_fs.adaAkun) ...[
              const SizedBox(height: 16),
              LabeledField(label: 'Email', controller: _email, readOnly: true),
            ],
            const SizedBox(height: 16),
            LabeledField(
                label: 'Date of Birth',
                controller: _dob,
                readOnly: true,
                onTap: _pilihTanggal),
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'Simpan Perubahan', onPressed: _simpan, loading: _saving),
            const SizedBox(height: 24),
            MenuTile(
              icon: Icons.menu_book_outlined,
              label: 'Resep Saya',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const CommunityRecipesScreen(initialTab: 1))),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: Colors.black, width: 0.8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _fs.keluar(),
                child: const Text('Logout',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: AppText.body)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}