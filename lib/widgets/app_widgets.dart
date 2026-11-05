import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'food_detail_sheet.dart';

/// Gaya teks serif seperti di wireframe.
TextStyle serif({
  double size = 16,
  FontWeight weight = FontWeight.w700,
  Color color = AppColors.textDark,
  double? spacing,
}) =>
    GoogleFonts.libreBaskerville(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

/// Label huruf kapital + kolom isian abu-abu (layar Login/Sign Up/Profil).
class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final bool readOnly;
  final TextInputType? keyboard;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.readOnly = false,
    this.keyboard,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: serif(
                size: AppText.small,
                weight: FontWeight.w400,
                color: AppColors.textHint,
                spacing: 2.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          readOnly: readOnly,
          keyboardType: keyboard,
          onTap: onTap,
          validator: validator,
          textAlign: TextAlign.center,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton(
      {super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(label),
      ),
    );
  }
}

/// Lingkaran abu-biru untuk skor BMI & kalori (Beranda).
class StatCircle extends StatelessWidget {
  final String value;
  final String? sub;
  final double size;

  const StatCircle({super.key, required this.value, this.sub, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          color: AppColors.circleBlue, shape: BoxShape.circle),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: GoogleFonts.sourceSans3(
                  fontSize: sub == null ? AppText.title : AppText.section,
                  color: Colors.black)),
          if (sub != null)
            Text(sub!,
                style: GoogleFonts.sourceSans3(
                    fontSize: AppText.subtitle, color: Colors.black)),
        ],
      ),
    );
  }
}

/// Tombol + hitam bulat.
class AddCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddCircleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration:
            const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

/// Kartu makanan (emoji sebagai pengganti foto; ganti dengan Image.asset jika punya foto).
class FoodCard extends StatelessWidget {
  final String nama;
  final String emoji;
  final int? kalori;
  final double size;

  const FoodCard(
      {super.key,
      required this.nama,
      required this.emoji,
      this.kalori,
      this.size = 140});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          showFoodDetail(context, nama: nama, emoji: emoji, kalori: kalori),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.sageLight.withOpacity(0.55),
                borderRadius: BorderRadius.circular(18)),
            child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size,
            child: Text(nama,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: serif(
                    size: size < 110 ? AppText.caption : AppText.body)),
          ),
          if (kalori != null)
            Text('±$kalori kkal',
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: AppText.small)),
        ],
      ),
    );
  }
}
