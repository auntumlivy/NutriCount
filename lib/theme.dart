import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna diambil dari wireframe (hijau sage + abu-abu).
class AppColors {
  static const sageLight = Color(0xFFCDD5AE); // judul, logo
  static const sage = Color(0xFFAEB693); // tombol
  static const sageDark = Color(0xFF8F9877);
  static const fieldGrey = Color(0xFFEBEBEB); // input
  static const textDark = Color(0xFF4A4A4A);
  static const textHint = Color(0xFF8A8A8A);
  static const circleBlue = Color(0xFFC9D1DB); // lingkaran skor/kalori
  static const underweight = Color(0xFFB7D3E8);
  static const normal = Color(0xFFCDD5AE);
  static const overweight = Color(0xFFEFD9A3);
  static const obesitas = Color(0xFFE6B3A8);
}

/// Skala ukuran font. Pakai ini supaya ukuran teks konsisten di semua layar.
class AppText {
  static const double caption = 12; // keterangan kecil
  static const double small = 14; // teks pendukung
  static const double body = 16; // teks utama
  static const double subtitle = 18; // judul bagian
  static const double section = 20; // judul AppBar
  static const double title = 24; // judul layar
  static const double display = 28; // angka besar
  static const double hero = 36; // judul Login
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      primary: AppColors.sage,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
  final tt = GoogleFonts.sourceSans3TextTheme(base.textTheme).apply(
    bodyColor: AppColors.textDark,
    displayColor: AppColors.textDark,
  );
  return base.copyWith(
    textTheme: tt.copyWith(
      bodyLarge: tt.bodyLarge?.copyWith(fontSize: AppText.body),
      bodyMedium: tt.bodyMedium?.copyWith(fontSize: AppText.body),
      bodySmall: tt.bodySmall?.copyWith(fontSize: AppText.small),
      labelLarge: tt.labelLarge?.copyWith(fontSize: AppText.body),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldGrey,
      hintStyle: const TextStyle(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.sage,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.sourceSans3(
            fontSize: AppText.body, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.sageLight,
    ),
  );
}
