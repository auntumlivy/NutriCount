import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

/// Beranda admin: ringkasan resep + antrean yang perlu ditinjau.
class AdminHomeScreen extends StatefulWidget {
  final VoidCallback onLihatSemua;
  const AdminHomeScreen({super.key, required this.onLihatSemua});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _fs = DataService.instance;
  late final Stream<List<Recipe>> _semua = _fs.allRecipesStream();
  late final Stream<Map<String, dynamic>?> _userS = _fs.userStream();

  void _buka(Recipe r) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(resep: r, adminMode: true)));

  Widget _stat(String label, int nilai, Color warna, IconData ikon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: warna.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(ikon, color: AppColors.textDark),
            const SizedBox(height: 10),
            Text('$nilai', style: serif(size: AppText.display)),
            Text(label, style: const TextStyle(fontSize: AppText.small)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Recipe>>(
        stream: _semua,
        builder: (context, snap) {
          if (snap.hasError) {
            return EmptyState(
                icon: Icons.error_outline,
                text: 'Gagal memuat data.\n${snap.error}');
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          int n(String s) => list.where((r) => r.status == s).length;
          final pending = list
              .where((r) => r.status == RecipeStatus.pending)
              .toList()
            ..sort((a, b) => a.dibuat.compareTo(b.dibuat));

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                      colors: [AppColors.sageDark, AppColors.sage],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PANEL ADMIN',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppText.caption,
                                  letterSpacing: 2)),
                          const SizedBox(height: 6),
                          StreamBuilder<Map<String, dynamic>?>(
                            stream: _userS,
                            builder: (_, u) {
                              final nama =
                                  ((u.data?['nama'] ?? '') as String).trim();
                              return Text(
                                  nama.isEmpty ? 'Halo, Admin' : 'Halo, $nama',
                                  style: serif(
                                      size: AppText.title,
                                      color: Colors.white));
                            },
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.admin_panel_settings,
                        size: 48, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                _stat('Menunggu', n(RecipeStatus.pending), AppColors.overweight,
                    Icons.hourglass_bottom),
                const SizedBox(width: 12),
                _stat('Disetujui', n(RecipeStatus.approved), AppColors.normal,
                    Icons.check_circle_outline),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _stat('Ditolak', n(RecipeStatus.rejected), AppColors.obesitas,
                    Icons.cancel_outlined),
                const SizedBox(width: 12),
                _stat('Total resep', list.length, AppColors.circleBlue,
                    Icons.menu_book_outlined),
              ]),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                      child: Text('Perlu Ditinjau',
                          style: serif(size: AppText.subtitle))),
                  if (pending.length > 5)
                    TextButton(
                        onPressed: widget.onLihatSemua,
                        child: const Text('Lihat semua')),
                ],
              ),
              const SizedBox(height: 10),
              if (pending.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Tidak ada resep yang menunggu. Semua sudah ditinjau.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textHint)),
                )
              else
                for (final r in pending.take(5))
                  RecipeCard(resep: r, onTap: () => _buka(r)),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Tambah Resep Baru',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const RecipeFormScreen(adminMode: true))),
              ),
            ],
          );
        },
      ),
    );
  }
}
