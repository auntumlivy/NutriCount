import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import '../widgets/recipe_widgets.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class CommunityRecipesScreen extends StatefulWidget {
  final int initialTab;
  const CommunityRecipesScreen({super.key, this.initialTab = 0});

  @override
  State<CommunityRecipesScreen> createState() => _CommunityRecipesScreenState();
}

class _CommunityRecipesScreenState extends State<CommunityRecipesScreen> {
  static const _kategori = ['Underweight', 'Normal', 'Overweight', 'Obesitas'];
  final _fs = DataService.instance;
  late final _semua = _fs.approvedRecipesStream();
  late final _saya = _fs.myRecipesStream();
  late final _bmi = _fs.bmiStream();
  String? _pilih;

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
          title: Text('Resep Komunitas', style: serif(size: AppText.section)),
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
        body: SafeArea(
          child: StreamBuilder<List<BmiRecord>>(
            stream: _bmi,
            builder: (context, snap) {
              final data = snap.data ?? [];
              final latest = data.isEmpty ? null : data.first;
              final aktif = _pilih ?? latest?.kategori ?? 'Normal';
              final info = latest == null
                  ? 'Belum ada data BMI. Hitung & simpan BMI di tab BMI agar rekomendasi menyesuaikan.'
                  : aktif == latest.kategori
                  ? 'Kategori BMI terakhirmu: $aktif'
                  : 'Menampilkan resep untuk kategori $aktif';

              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Row(
                      children: [
                        for (final k in _kategori)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(k),
                              selected: aktif == k,
                              selectedColor: BmiUtils.warna(k),
                              backgroundColor: AppColors.fieldGrey,
                              side: BorderSide.none,
                              onSelected: (_) => setState(() => _pilih = k),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BmiUtils.warna(aktif).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(info, textAlign: TextAlign.center,
                          style: serif(size: AppText.small,
                              weight: FontWeight.w400)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Text(
                      'Ketuk resep untuk melihat detail dan kalorinya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textHint,
                          fontSize: AppText.small),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      _RecipeList(stream: _semua, kategori: aktif,
                          onTap: _buka,
                          kosong: 'Belum ada resep yang disetujui.'),
                      _RecipeList(stream: _saya, kategori: aktif,
                          onTap: _buka, tampilStatus: true,
                          kosong: 'Kamu belum mengirim resep.\n'
                              'Tekan "Kirim Resep" untuk mulai.'),
                    ]),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  final Stream<List<Recipe>> stream;
  final String kategori;
  final void Function(Recipe) onTap;
  final String kosong;
  final bool tampilStatus;

  const _RecipeList({
    required this.stream,
    required this.kategori,
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
          return EmptyState(icon: Icons.error_outline,
              text: 'Gagal memuat resep.\n${snap.error}');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final semua = snap.data!;
        if (semua.isEmpty) {
          return EmptyState(icon: Icons.menu_book_outlined, text: kosong);
        }
        final resep = semua.where((r) =>
        r.kategoriBMI == 'Semua Kategori' || r.kategoriBMI == kategori
        ).toList();

        if (resep.isEmpty) {
          return EmptyState(icon: Icons.restaurant_menu_outlined,
              text: 'Belum ada resep untuk kategori $kategori.');
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 22,
            crossAxisSpacing: 16,
            childAspectRatio: 0.66,
          ),
          itemCount: resep.length,
          itemBuilder: (_, i) {
            final r = resep[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.sageLight.withOpacity(0.8)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04),
                          blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: r.foto.isEmpty
                            ? Container(
                          color: AppColors.sageLight.withOpacity(0.55),
                          alignment: Alignment.center,
                          child: const Icon(Icons.restaurant,
                              color: AppColors.sageDark, size: 40),
                        )
                            : LayoutBuilder(
                          builder: (context, c) => SizedBox.expand(
                            child: RecipePhoto(
                              data: r.foto,
                              height: c.maxHeight,
                              radius: 0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(r.judul, maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: serif(size: AppText.body)),
                            const SizedBox(height: 4),
                            Text('±${r.kalori} kkal',
                                style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: AppText.small)),
                            if (tampilStatus) ...[
                              const SizedBox(height: 5),
                              StatusChip(r.status),
                            ],
                            if (tampilStatus &&
                                r.status == RecipeStatus.rejected &&
                                r.alasanTolak.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Alasan: ${r.alasanTolak}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFFB5524A),
                                      fontSize: AppText.caption)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
