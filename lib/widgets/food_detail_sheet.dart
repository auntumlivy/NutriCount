import 'package:flutter/material.dart';
import '../data/resep_bawaan.dart';
import '../models/models.dart';
import '../screens/recipe_detail_screen.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import 'app_widgets.dart';
import 'recipe_widgets.dart';

/// Popup detail makanan: kalori, kategori yang cocok, resep, dan
/// resep komunitas yang terkait.
Future<void> showFoodDetail(
  BuildContext context, {
  required String nama,
  required String emoji,
  int? kalori,
}) {
  FoodItem? item;
  for (final f in BmiUtils.katalog) {
    if (f.nama == nama) {
      item = f;
      break;
    }
  }
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => _FoodDetail(
        nama: nama,
        emoji: item?.emoji ?? emoji,
        kalori: item?.kalori ?? kalori,
        scroll: scroll,
      ),
    ),
  );
}

class _FoodDetail extends StatefulWidget {
  final String nama;
  final String emoji;
  final int? kalori;
  final ScrollController scroll;
  const _FoodDetail(
      {required this.nama,
      required this.emoji,
      required this.kalori,
      required this.scroll});

  @override
  State<_FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<_FoodDetail> {
  late final Stream<List<Recipe>> _komunitas =
      DataService.instance.approvedRecipesStream();

  static const _abaikan = {
    'nasi', 'goreng', 'rebus', 'kukus', 'panggang', 'sayur', 'plain',
    'full', 'cream', 'instan', 'lembar', 'dengan', 'bening',
  };

  List<Recipe> _terkait(List<Recipe> semua) {
    final kunci = widget.nama
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.length >= 4 && !_abaikan.contains(w))
        .toList();
    return semua.where((r) {
      final j = r.judul.toLowerCase();
      return j.contains(widget.nama.toLowerCase()) ||
          kunci.any((k) => j.contains(k));
    }).toList();
  }

  Widget _bagian(String judul) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(judul, style: serif(size: AppText.subtitle)),
      );

  @override
  Widget build(BuildContext context) {
    final resep = cariResepBawaan(widget.nama);
    final cocok = [
      for (final k in const ['Underweight', 'Normal', 'Overweight', 'Obesitas'])
        if (BmiUtils.makananUntuk(k).any((f) => f.nama == widget.nama)) k
    ];

    return ListView(
      controller: widget.scroll,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
                color: AppColors.fieldGrey,
                borderRadius: BorderRadius.circular(3)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.sageLight.withOpacity(0.55),
                borderRadius: BorderRadius.circular(24)),
            child: Text(widget.emoji, style: const TextStyle(fontSize: 56)),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.nama,
            textAlign: TextAlign.center, style: serif(size: AppText.title)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: AppColors.circleBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text(
                  widget.kalori == null ? '-' : '±${widget.kalori} kkal',
                  style: serif(size: AppText.display)),
              const SizedBox(height: 4),
              Text(resep == null ? 'estimasi per porsi' : 'per ${resep.porsi}',
                  style: const TextStyle(color: AppColors.textHint)),
            ],
          ),
        ),
        if (cocok.isNotEmpty) ...[
          _bagian('Cocok untuk'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in cocok)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: BmiUtils.warna(k),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(k,
                      style: const TextStyle(
                          fontSize: AppText.small,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
        if (resep != null) ...[
          _bagian('Bahan'),
          for (final b in resep.bahan)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(b)),
                ],
              ),
            ),
          _bagian('Cara membuat'),
          for (var i = 0; i < resep.langkah.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 28,
                      child: Text('${i + 1}.',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(child: Text(resep.langkah[i])),
                ],
              ),
            ),
        ] else ...[
          _bagian('Resep'),
          const Text(
              'Resep untuk makanan ini belum tersedia. Lihat resep komunitas di bawah atau kirim resepmu sendiri lewat tombol Resep Komunitas.',
              style: TextStyle(color: AppColors.textHint)),
        ],
        const SizedBox(height: 12),
        const Text('Kalori adalah perkiraan dan bisa berbeda tergantung porsi dan cara memasak.',
            style: TextStyle(
                color: AppColors.textHint, fontSize: AppText.caption)),
        StreamBuilder<List<Recipe>>(
          stream: _komunitas,
          builder: (context, snap) {
            final list = _terkait(snap.data ?? const []);
            if (list.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bagian('Resep dari komunitas'),
                for (final r in list)
                  RecipeCard(
                    resep: r,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(resep: r))),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
