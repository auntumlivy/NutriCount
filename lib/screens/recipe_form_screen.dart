import 'dart:async';

import 'package:flutter/material.dart';
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
  bool _loading = false;

  List<String> _baris(String teks) => teks
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _kirim() async {
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
        namaPembuat: widget.adminMode
            ? 'Admin'
            : (nama.isEmpty ? 'Anonim' : nama),
        dibuat: DateTime.now(),
      );
      final aksi = widget.adminMode
          ? DataService.instance.adminAddRecipe(resep)
          : DataService.instance.submitRecipe(resep);
      await aksi.timeout(const Duration(seconds: 15));
      messenger.showSnackBar(SnackBar(
          content: Text(widget.adminMode
              ? 'Resep diterbitkan.'
              : 'Resep terkirim. Menunggu persetujuan admin.')));
      nav.pop();
    } on TimeoutException {
      // Koneksi lambat: Firestore tetap mengirim saat sudah online.
      messenger.showSnackBar(const SnackBar(
          content: Text('Koneksi lambat. Resep akan terkirim saat online.')));
      nav.pop();
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
                    label: widget.adminMode ? 'Terbitkan Resep' : 'Kirim untuk Ditinjau',
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
