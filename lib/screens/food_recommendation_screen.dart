import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import 'community_recipes_screen.dart';

/// Dipakai sebagai tab "Makanan" (tanpa parameter) dan sebagai halaman
/// "More>" dari kalkulator BMI (dengan [kategori]).
class FoodRecommendationScreen extends StatefulWidget {
  final String? kategori;
  final double? targetKalori;

  const FoodRecommendationScreen({
    super.key,
    this.kategori,
    this.targetKalori,
  });

  @override
  State<FoodRecommendationScreen> createState() =>
      _FoodRecommendationScreenState();
}

class _FoodRecommendationScreenState extends State<FoodRecommendationScreen> {
  static const _semuaKategori = ['Underweight', 'Normal', 'Overweight', 'Obesitas'];

  final _fs = DataService.instance;
  late final Stream<List<BmiRecord>> _bmiS = _fs.bmiStream();
  String? _pilih;

  @override
  Widget build(BuildContext context) {
    final dipush = Navigator.canPop(context);

    return Scaffold(
      appBar: dipush
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textDark),
              title: Text('Rekomendasi Makanan', style: serif(size: AppText.section)),
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<List<BmiRecord>>(
          stream: _bmiS,
          builder: (context, snap) {
            final data = snap.data ?? [];
            final latest = data.isEmpty ? null : data.first;
            final aktif =
                _pilih ?? widget.kategori ?? latest?.kategori ?? 'Normal';
            final foods = BmiUtils.makananUntuk(aktif);
            final targetKalori =
                widget.targetKalori ?? latest?.kalori;

            final kaloriSarapan =
                targetKalori == null ? null : targetKalori * 0.25;

            final kaloriSiang =
                targetKalori == null ? null : targetKalori * 0.35;

            final kaloriMalam =
                targetKalori == null ? null : targetKalori * 0.30;

            final kaloriSnack =
                targetKalori == null ? null : targetKalori * 0.10;

            final info = latest == null
                ? 'Belum ada data BMI. Hitung & simpan BMI di tab BMI agar rekomendasi menyesuaikan.'
                : (aktif == latest.kategori
                    ? 'Kategori BMI terakhirmu: $aktif'
                    : 'Menampilkan rekomendasi untuk kategori $aktif');

            return CustomScrollView(
              slivers: [

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.fieldGrey,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kebutuhan Kalori Harian',
                            style: serif(size: AppText.body),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            targetKalori == null
                                ? 'Hitung dan simpan BMI untuk melihat kebutuhan kalori.'
                                : '${targetKalori.round()} kkal / hari',
                            style: serif(size: AppText.title),
                          ),
                          if (targetKalori != null) ...[
                            const Divider(height: 24),
                            _barisKalori('Sarapan (25%)', kaloriSarapan!),
                            _barisKalori('Makan siang (35%)', kaloriSiang!),
                            _barisKalori('Makan malam (30%)', kaloriMalam!),
                            _barisKalori('Camilan (10%)', kaloriSnack!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                if (!dipush)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text('Rekomendasi Makanan', style: serif(size: AppText.title)),
                    ),
                  ),
                if (!dipush)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.sageDark,
                            side: const BorderSide(color: AppColors.sage),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CommunityRecipesScreen())),
                          icon: const Icon(Icons.groups_2_outlined, size: 20),
                          label: const Text('Resep Komunitas'),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Row(
                      children: [
                        for (final k in _semuaKategori)
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
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: BmiUtils.warna(aktif).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(info,
                          textAlign: TextAlign.center,
                          style: serif(size: AppText.small, weight: FontWeight.w400)),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Text('Ketuk makanan untuk melihat resep dan kalorinya.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: AppText.small)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 22,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.66,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => FoodCard(
                        nama: foods[i].nama,
                        emoji: foods[i].emoji,
                        kalori: foods[i].kalori,
                        size: 136,
                      ),
                      childCount: foods.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ); // Scaffold
  } // penutup build()

  // TEMPEL FUNGSI DI SINI
  Widget _barisKalori(String label, double kalori) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: AppText.small),
          ),
          Text(
            '${kalori.round()} kkal',
            style: const TextStyle(
              fontSize: AppText.small,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

} // penutup class