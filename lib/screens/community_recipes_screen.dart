import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

/// Dua tab: "Semua Resep" (yang sudah disetujui) dan "Resep Saya" (+ status).
class CommunityRecipesScreen extends StatefulWidget {
  final int initialTab;
  const CommunityRecipesScreen({super.key, this.initialTab = 0});

  @override
  State<CommunityRecipesScreen> createState() => _CommunityRecipesScreenState();
}

class _CommunityRecipesScreenState extends State<CommunityRecipesScreen> {
  final _fs = DataService.instance;
  late final Stream<List<Recipe>> _semua = _fs.approvedRecipesStream();
  late final Stream<List<Recipe>> _saya = _fs.myRecipesStream();

  void _buka(Recipe r) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(resep: r)));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark),
          title: Text('Resep Komunitas', style: serif(size: 20)),
          bottom: const TabBar(
            labelColor: AppColors.textDark,
            indicatorColor: AppColors.sageDark,
            tabs: [Tab(text: 'Semua Resep'), Tab(text: 'Resep Saya')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.sage,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Kirim Resep'),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RecipeFormScreen())),
        ),
        body: TabBarView(
          children: [
            _RecipeList(
              stream: _semua,
              onTap: _buka,
              kosong: 'Belum ada resep yang disetujui.',
            ),
            _RecipeList(
              stream: _saya,
              onTap: _buka,
              tampilStatus: true,
              kosong: 'Kamu belum mengirim resep.\nTekan "Kirim Resep" untuk mulai.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  final Stream<List<Recipe>> stream;
  final void Function(Recipe) onTap;
  final String kosong;
  final bool tampilStatus;

  const _RecipeList({
    required this.stream,
    required this.onTap,
    required this.kosong,
    this.tampilStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recipe>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(
              icon: Icons.error_outline,
              text: 'Gagal memuat resep.\n${snap.error}');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) {
          return EmptyState(icon: Icons.menu_book_outlined, text: kosong);
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
          itemCount: list.length,
          itemBuilder: (_, i) => RecipeCard(
            resep: list[i],
            tampilStatus: tampilStatus,
            onTap: () => onTap(list[i]),
          ),
        );
      },
    );
  }
}
