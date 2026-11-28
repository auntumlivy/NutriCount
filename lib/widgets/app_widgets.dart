import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/resep_bawaan.dart';
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

/// Kartu makanan dengan foto real (otomatis fallback ke emoji jika offline/gagal load).
class FoodCard extends StatelessWidget {
  final String nama;
  final String emoji;
  final int? kalori;
  final double size;
  final String foto;

  const FoodCard(
      {super.key,
        required this.nama,
        required this.emoji,
        this.kalori,
        this.size = 140});

  @override
  Widget build(BuildContext context) {
    final fotoUrl = kFotoMakanan[nama];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          showFoodDetail(context, nama: nama, emoji: emoji, kalori: kalori),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.sageLight.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian Foto Makanan Real
            Expanded(
              child: fotoUrl != null
                  ? Image.network(
                fotoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.sageLight.withOpacity(0.35),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.sageDark,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _emojiFallback(),
              )
                  : _emojiFallback(),
            ),
            // Bagian Judul & Kalori di Bawah Foto
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: serif(
                      size: size < 110 ? AppText.caption : AppText.body,
                    ),
                  ),
                  if (kalori != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '±$kalori kkal',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: AppText.small,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emojiFallback() {
    return Container(
      color: AppColors.sageLight.withOpacity(0.55),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}

/// Header berwarna di bagian atas halaman (judul, subjudul, ikon).
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const PageHeader({super.key, required this.title, this.subtitle, this.icon});

  Widget _lingkaran(double ukuran, double opacity) => Container(
    width: ukuran,
    height: ukuran,
    decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity), shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    final atas = MediaQuery.of(context).padding.top; // tinggi status bar
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.sageLight, AppColors.sage],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -30, child: _lingkaran(130, 0.18)),
          Positioned(right: 70, bottom: -45, child: _lingkaran(90, 0.12)),
          Padding(
            padding: EdgeInsets.fromLTRB(24, atas + 18, 24, 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: serif(size: AppText.title)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!,
                            style: TextStyle(
                                fontSize: AppText.small,
                                color: AppColors.textDark.withOpacity(0.75))),
                      ],
                    ],
                  ),
                ),
                if (icon != null)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        shape: BoxShape.circle),
                    child: Icon(icon, color: AppColors.textDark),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Halaman dengan header berwarna di atas, isi di bawahnya.
/// [tampilHeader] = false -> tanpa header (misalnya saat halaman dibuka
/// lewat Navigator.push dan sudah punya AppBar).
class HeaderPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool tampilHeader;
  final Widget child;

  const HeaderPage({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tampilHeader = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!tampilHeader) return SafeArea(child: child);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: title, subtitle: subtitle, icon: icon),
          Expanded(child: child),
        ],
      ),
    );
  }
}