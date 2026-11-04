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

  Widget _bagian(String judul) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(judul, style: serif(size: 18)),
      );

  @override
  Widget build(BuildContext context) {
    final r = widget.resep;
    final adminAksi = widget.adminMode && r.status == RecipeStatus.pending;
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
          Text(r.judul, style: serif(size: 26)),
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
            Text(r.deskripsi, style: const TextStyle(fontSize: 16)),
          ],
          _bagian('Bahan'),
          for (final b in r.bahan)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(b, style: const TextStyle(fontSize: 16))),
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
                              fontSize: 16, fontWeight: FontWeight.w700))),
                  Expanded(
                      child:
                          Text(r.langkah[i], style: const TextStyle(fontSize: 16))),
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
      bottomNavigationBar: adminAksi
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textDark,
                            side: const BorderSide(color: Colors.black54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _busy ? null : _tolak,
                          child: const Text('Tolak',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 17)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                          label: 'Setujui',
                          loading: _busy,
                          onPressed: () => _ubah(RecipeStatus.approved)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
