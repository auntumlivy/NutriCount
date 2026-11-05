import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

/// Kelola resep: tab Menunggu / Disetujui / Ditolak.
class AdminRecipesScreen extends StatefulWidget {
  const AdminRecipesScreen({super.key});

  @override
  State<AdminRecipesScreen> createState() => _AdminRecipesScreenState();
}

class _AdminRecipesScreenState extends State<AdminRecipesScreen> {
  late final Stream<List<Recipe>> _semua =
      DataService.instance.allRecipesStream();

  void _buka(Recipe r) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(resep: r, adminMode: true)));

  Widget _daftar(List<Recipe> list, String status, String kosong) {
    final isi = list.where((r) => r.status == status).toList();
    if (isi.isEmpty) {
      return EmptyState(icon: Icons.inbox_outlined, text: kosong);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      itemCount: isi.length,
      itemBuilder: (_, i) =>
          RecipeCard(resep: isi[i], tampilStatus: true, onTap: () => _buka(isi[i])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: StreamBuilder<List<Recipe>>(
        stream: _semua,
        builder: (context, snap) {
          final list = snap.data ?? const <Recipe>[];
          int n(String s) => list.where((r) => r.status == s).length;
          Widget isi(Widget Function() bangun) {
            if (snap.hasError) {
              return EmptyState(
                  icon: Icons.error_outline,
                  text: 'Gagal memuat resep.\n${snap.error}');
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return bangun();
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text('Kelola Resep',
                  style: serif(size: AppText.section)),
              bottom: TabBar(
                labelColor: AppColors.textDark,
                indicatorColor: AppColors.sageDark,
                tabs: [
                  Tab(text: 'Menunggu (${n(RecipeStatus.pending)})'),
                  Tab(text: 'Disetujui (${n(RecipeStatus.approved)})'),
                  Tab(text: 'Ditolak (${n(RecipeStatus.rejected)})'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: AppColors.sage,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const RecipeFormScreen(adminMode: true))),
            ),
            body: TabBarView(
              children: [
                isi(() => _daftar(list, RecipeStatus.pending,
                    'Tidak ada resep yang menunggu.')),
                isi(() => _daftar(list, RecipeStatus.approved,
                    'Belum ada resep yang disetujui.')),
                isi(() => _daftar(
                    list, RecipeStatus.rejected, 'Tidak ada resep yang ditolak.')),
              ],
            ),
          );
        },
      ),
    );
  }
}
