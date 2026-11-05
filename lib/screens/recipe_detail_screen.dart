import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';

/// Detail resep. Kalau [adminMode] = true dan status masih menunggu,
/// muncul tombol Setujui / Tolak di bawah.
class RecipeDetailScreen extends StatefulWidget {
  final Recipe resep;
  final bool adminMode;
  const RecipeDetailScreen(
      {super.key, required this.resep, this.adminMode = false});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _busy = false;

  Future<void> _ubah(String status, {String alasan = ''}) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await DataService.instance
          .setRecipeStatus(widget.resep.id, status, alasan: alasan);
      messenger.showSnackBar(SnackBar(
          content: Text(status == RecipeStatus.approved
              ? 'Resep disetujui.'
              : 'Resep ditolak.')));
      nav.pop();
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _tolak() async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak resep ini?'),
        content: TextField(
          controller: c,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Alasan (opsional)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tolak')),
        ],
      ),
    );
    if (ok == true) await _ubah(RecipeStatus.rejected, alasan: c.text.trim());
  }

  Future<void> _hapus() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus resep ini?'),
        content: const Text('Resep yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await DataService.instance.deleteRecipe(widget.resep.id);
      messenger.showSnackBar(const SnackBar(content: Text('Resep dihapus.')));
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  Widget _tombolGaris(String label, VoidCallback aksi) => SizedBox(
        height: 56,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: Colors.black54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _busy ? null : aksi,
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: AppText.body)),
        ),
      );

  /// Tombol aksi admin di bawah layar, tergantung status resep.
  Widget? _barAdmin(Recipe r) {
    if (!widget.adminMode) return null;
    Widget kiri;
    Widget kanan;
    if (r.status == RecipeStatus.pending) {
      kiri = _tombolGaris('Tolak', _tolak);
      kanan = PrimaryButton(
          label: 'Setujui',
          loading: _busy,
          onPressed: () => _ubah(RecipeStatus.approved));
    } else if (r.status == RecipeStatus.approved) {
      kiri = _tombolGaris('Hapus', _hapus);
      kanan = PrimaryButton(
          label: 'Tarik',
          loading: _busy,
          onPressed: () => _ubah(RecipeStatus.rejected,
              alasan: 'Ditarik oleh admin'));
    } else {
      kiri = _tombolGaris('Hapus', _hapus);
      kanan = PrimaryButton(
          label: 'Setujui',
          loading: _busy,
          onPressed: () => _ubah(RecipeStatus.approved));
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            Expanded(child: kiri),
            const SizedBox(width: 12),
            Expanded(child: kanan),
          ],
        ),
      ),
    );
  }

  Widget _bagian(String judul) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(judul, style: serif(size: AppText.subtitle)),
      );

  @override
  Widget build(BuildContext context) {
    final r = widget.resep;
    final bisaHapus = !widget.adminMode && r.status != RecipeStatus.approved;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          if (bisaHapus)
            IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline),
                onPressed: _hapus),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Text(r.judul, style: serif(size: AppText.title)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text('oleh ${r.namaPembuat}  ·  ±${r.kalori} kkal',
                    style: const TextStyle(color: AppColors.textHint)),
              ),
              if (r.status != RecipeStatus.approved) StatusChip(r.status),
            ],
          ),
          if (r.status == RecipeStatus.rejected && r.alasanTolak.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Alasan ditolak: ${r.alasanTolak}',
                  style: const TextStyle(color: Color(0xFFB5524A))),
            ),
          if (r.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(r.deskripsi, style: const TextStyle(fontSize: AppText.body)),
          ],
          _bagian('Bahan'),
          for (final b in r.bahan)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(fontSize: AppText.body)),
                  Expanded(child: Text(b, style: const TextStyle(fontSize: AppText.body))),
                ],
              ),
            ),
          _bagian('Langkah'),
          for (var i = 0; i < r.langkah.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 28,
                      child: Text('${i + 1}.',
                          style: const TextStyle(
                              fontSize: AppText.body, fontWeight: FontWeight.w700))),
                  Expanded(
                      child:
                          Text(r.langkah[i], style: const TextStyle(fontSize: AppText.body))),
                ],
              ),
            ),
          if (r.sumberUrl.isNotEmpty) ...[
            _bagian('Sumber'),
            SelectableText(r.sumberUrl,
                style: const TextStyle(color: AppColors.sageDark)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: r.sumberUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link disalin.')));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Salin link'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.sageDark),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _barAdmin(r),
    );
  }
}
