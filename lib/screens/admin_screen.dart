import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';
import 'recipe_detail_screen.dart';

/// Panel admin: antrean resep yang menunggu persetujuan.
/// Cuma tampil kalau field `role` di dokumen user = "admin"
/// (diubah manual di Firebase Console). Penjagaan sebenarnya ada di
/// firestore.rules, bukan di sini.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late final Stream<Map<String, dynamic>?> _userS =
      DataService.instance.userStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text('Panel Admin', style: serif(size: 20)),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _userS,
        builder: (context, snap) {
          if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.data?['role'] != 'admin') {
            return const EmptyState(
                icon: Icons.lock_outline,
                text: 'Halaman ini khusus admin.');
          }
          return const _PendingList();
        },
      ),
    );
  }
}

class _PendingList extends StatefulWidget {
  const _PendingList();

  @override
  State<_PendingList> createState() => _PendingListState();
}

class _PendingListState extends State<_PendingList> {
  late final Stream<List<Recipe>> _stream =
      DataService.instance.pendingRecipesStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recipe>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(
              icon: Icons.error_outline,
              text: 'Gagal memuat antrean.\n${snap.error}');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) {
          return const EmptyState(
              icon: Icons.check_circle_outline,
              text: 'Tidak ada resep yang menunggu.\nSemua sudah ditinjau.');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: list.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('${list.length} resep menunggu persetujuan',
                    style: const TextStyle(color: AppColors.textHint)),
              );
            }
            final r = list[i - 1];
            return RecipeCard(
              resep: r,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          RecipeDetailScreen(resep: r, adminMode: true))),
            );
          },
        );
      },
    );
  }
}
