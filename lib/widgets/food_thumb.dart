import 'package:flutter/material.dart';
import '../data/resep_bawaan.dart';
import '../services/cloudinary_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import 'recipe_widgets.dart';

/// Kotak gambar makanan (dipakai di daftar pilih makanan dan di Beranda).
/// Urutan: [foto] (resep komunitas) -> foto rekomendasi (kFotoMakanan) -> emoji.
class FoodThumb extends StatelessWidget {
  final String nama;
  final String? foto;
  final double size;
  final double radius;

  const FoodThumb({
    super.key,
    required this.nama,
    this.foto,
    this.size = 56,
    this.radius = 14,
  });

  static final Map<String, String> _emoji = {
    for (final f in BmiUtils.katalog) f.nama: f.emoji,
  };

  @override
  Widget build(BuildContext context) {
    final url =
    (foto != null && foto!.isNotEmpty) ? foto! : (kFotoMakanan[nama] ?? '');

    final cadangan = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: AppColors.sageLight.withOpacity(0.55),
      child: Text(_emoji[nama] ?? '🍽️',
          style: TextStyle(fontSize: size * 0.45)),
    );

    Widget isi;
    if (url.isEmpty) {
      isi = cadangan;
    } else if (url.startsWith('http')) {
      isi = Image.network(
        CloudinaryService.thumb(url, width: (size * 3).round()),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : cadangan,
        errorBuilder: (_, __, ___) => cadangan,
      );
    } else {
      // foto lama berformat base64
      isi = RecipePhoto(data: url, width: size, height: size, radius: 0);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: isi),
    );
  }
}