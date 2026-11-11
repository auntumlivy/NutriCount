import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';

/// Form user untuk mengirim resep. Setelah dikirim, status = menunggu admin.
class RecipeFormScreen extends StatefulWidget {
  /// true = admin menerbitkan resep langsung (tanpa menunggu persetujuan).
  final bool adminMode;
  const RecipeFormScreen({super.key, this.adminMode = false});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _form = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();
  final _bahan = TextEditingController();
  final _langkah = TextEditingController();
  final _kalori = TextEditingController();
  final _sumber = TextEditingController();
  final _picker = ImagePicker();
  bool _loading = false;
  Uint8List? _foto; // foto yang sudah dikompres (opsional)

  // Foto disimpan di dokumen Firestore (batas dokumen 1 MiB). Base64 menambah
  // ukuran sekitar 33%, jadi batas mentahnya dibuat kecil.
  static const _batasFotoByte = 400 * 1024;

  @override
  void initState() {
    super.initState();
    _pulihkanFotoHilang();
  }

  /// Android bisa mematikan aplikasi saat kamera terbuka; foto dipulihkan di sini.
  Future<void> _pulihkanFotoHilang() async {
    if (kIsWeb) return;
    try {
      final res = await _picker.retrieveLostData();
      if (res.isEmpty || res.file == null) return;
      final bytes = await res.file!.readAsBytes();
      if (bytes.length <= _batasFotoByte && mounted) {
        setState(() => _foto = bytes);
      }
    } catch (_) {
      // Abaikan: pemulihan hanya bonus.
    }
  }

  List<String> _baris(String teks) => teks
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  void _snack(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _ambilFoto(ImageSource sumber) async {
    try {
      final file = await _picker.pickImage(
        source: sumber,
        maxWidth: 640, // diperkecil & dikompres supaya ringan
        maxHeight: 640,
        imageQuality: 50,
        requestFullMetadata: false, // hindari permintaan izin tambahan
      );
      if (file == null) return; // pengguna membatalkan
      final bytes = await file.readAsBytes();
      if (bytes.length > _batasFotoByte) {
        _snack('Foto terlalu besar (${(bytes.length / 1024).round()} KB, '
            'maks ${_batasFotoByte ~/ 1024} KB). Pilih foto lain.');
        return;
      }
      if (mounted) setState(() => _foto = bytes);
    } on PlatformException catch (e) {
      final kode = e.code.toLowerCase();
      if (kode.contains('denied') || kode.contains('permission')) {
        _snack('Izin ${sumber == ImageSource.camera ? 'kamera' : 'galeri'} '
            'ditolak. Aktifkan lewat Pengaturan perangkat.');
      } else if (kode.contains('no_available_camera')) {
        _snack('Kamera tidak tersedia di perangkat ini. Pilih dari galeri.');
      } else {
        _snack('Tidak bisa membuka foto (${e.code}): ${e.message ?? ''}');
      }
    } catch (e) {
      _snack('Tidak bisa membuka foto: $e');
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
            if (!kIsWeb)
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
                  setState(() => _foto = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _kolomFoto() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOTO MAKANAN',
              style: serif(
                  size: AppText.small,
                  weight: FontWeight.w400,
                  color: AppColors.textHint,
                  spacing: 2)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _menuFoto,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 190,
                width: double.infinity,
                color: AppColors.fieldGrey,
                child: _foto == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 40, color: AppColors.sageDark),
                    SizedBox(height: 8),
                    Text('Ketuk untuk menambah foto makanan (opsional)',
                        style: TextStyle(color: AppColors.textHint)),
                  ],
                )
                    : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      _foto!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('Foto tidak bisa ditampilkan',
                            style:
                            TextStyle(color: AppColors.textHint)),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit,
                                size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Ganti',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_foto != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Ukuran foto: ${(_foto!.length / 1024).round()} KB',
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: AppText.caption)),
            ),
        ],
      ),
    );
  }

  Future<void> _kirim() async {
    if (_loading) return; // cegah kirim ganda
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _loading = true);
    try {
      final u = await DataService.instance.getUser();
      final nama = ((u?['nama'] ?? '') as String).trim();
      final resep = Recipe(
        judul: _judul.text.trim(),
        deskripsi: _deskripsi.text.trim(),
        bahan: _baris(_bahan.text),
        langkah: _baris(_langkah.text),
        kalori: int.parse(_kalori.text.trim()),
        sumberUrl: _sumber.text.trim(),
        foto: _foto == null ? '' : base64Encode(_foto!),
        namaPembuat:
        widget.adminMode ? 'Admin' : (nama.isEmpty ? 'Anonim' : nama),
        dibuat: DateTime.now(),
      );
      final aksi = widget.adminMode
          ? DataService.instance.adminAddRecipe(resep)
          : DataService.instance.submitRecipe(resep);
      await aksi.timeout(const Duration(seconds: 30));
      messenger.showSnackBar(SnackBar(
          content: Text(widget.adminMode
              ? 'Resep diterbitkan.'
              : 'Resep terkirim. Menunggu persetujuan admin.')));
      if (mounted) nav.pop();
    } on TimeoutException {
      // Koneksi lambat: Firestore tetap mengirim saat sudah online.
      messenger.showSnackBar(const SnackBar(
          content: Text('Koneksi lambat. Resep akan terkirim saat online.')));
      if (mounted) nav.pop();
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      messenger.showSnackBar(SnackBar(content: Text('Gagal mengirim: $e')));
    }
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    _bahan.dispose();
    _langkah.dispose();
    _kalori.dispose();
    _sumber.dispose();
    super.dispose();
  }

  Widget _isian(
      String label,
      TextEditingController c, {
        String? hint,
        int maxLines = 1,
        TextInputType? keyboard,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: serif(
                  size: AppText.small,
                  weight: FontWeight.w400,
                  color: AppColors.textHint,
                  spacing: 2)),
          const SizedBox(height: 8),
          TextFormField(
            controller: c,
            minLines: maxLines > 1 ? 3 : 1,
            maxLines: maxLines,
            keyboardType: keyboard,
            validator: validator,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(widget.adminMode ? 'Tambah Resep (Admin)' : 'Kirim Resep',
            style: serif(size: AppText.section)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    widget.adminMode
                        ? 'Resep dari admin langsung tampil ke semua pengguna.'
                        : 'Resep akan dicek admin dulu sebelum tampil ke pengguna lain.',
                    style: const TextStyle(color: AppColors.textHint)),
                const SizedBox(height: 20),
                _kolomFoto(),
                _isian('Judul resep', _judul,
                    hint: 'Contoh: Sup Ayam Sayur',
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Judul minimal 3 karakter'
                        : null),
                _isian('Deskripsi singkat', _deskripsi,
                    hint: 'Opsional', maxLines: 3),
                _isian('Bahan', _bahan,
                    hint: 'Satu bahan per baris',
                    maxLines: 8,
                    validator: (v) => _baris(v ?? '').isEmpty
                        ? 'Isi minimal satu bahan'
                        : null),
                _isian('Langkah', _langkah,
                    hint: 'Satu langkah per baris',
                    maxLines: 8,
                    validator: (v) => _baris(v ?? '').isEmpty
                        ? 'Isi minimal satu langkah'
                        : null),
                _isian('Kalori per porsi (kkal)', _kalori,
                    hint: 'Contoh: 250',
                    keyboard: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      return (n == null || n <= 0)
                          ? 'Isi angka kalori yang valid'
                          : null;
                    }),
                _isian('Link sumber', _sumber,
                    hint: 'Opsional, kalau resep dari internet',
                    keyboard: TextInputType.url,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      return t.startsWith('http')
                          ? null
                          : 'Link harus diawali http atau https';
                    }),
                const SizedBox(height: 6),
                PrimaryButton(
                    label: widget.adminMode
                        ? 'Terbitkan Resep'
                        : 'Kirim untuk Ditinjau',
                    onPressed: _kirim,
                    loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}