import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class BmiUtils {
  static double hitungBmi(double kg, double cm) => kg / pow(cm / 100, 2);

  static String kategori(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obesitas';
  }

  static Color warna(String kategori) {
    switch (kategori) {
      case 'Underweight':
        return AppColors.underweight;
      case 'Overweight':
        return AppColors.overweight;
      case 'Obesitas':
        return AppColors.obesitas;
      default:
        return AppColors.normal;
    }
  }

  /// Kebutuhan kalori harian (Mifflin-St Jeor, aktivitas ringan),
  /// disesuaikan dengan kategori BMI.
  static double kaloriHarian({
    required double berat,
    required double tinggi,
    required int usia,
    required bool pria,
    required String kategori,
  }) {
    final bmr = 10 * berat + 6.25 * tinggi - 5 * usia + (pria ? 5 : -161);
    var tdee = bmr * 1.375;
    if (kategori == 'Underweight') tdee += 300;
    if (kategori == 'Overweight') tdee -= 300;
    if (kategori == 'Obesitas') tdee -= 500;
    return tdee;
  }

  /// Rentang berat ideal (BMI 18,5 - 24,9).
  static (double, double) beratIdeal(double cm) {
    final m2 = pow(cm / 100, 2).toDouble();
    return (18.5 * m2, 24.9 * m2);
  }

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String fmtTanggal(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String fmt1(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

  static String fmtKg(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  /// Hitung usia dari string dd/MM/yyyy.
  static int? usiaDariTanggal(String dob) {
    final p = dob.split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]), m = int.tryParse(p[1]), y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    final now = DateTime.now();
    var age = now.year - y;
    if (now.month < m || (now.month == m && now.day < d)) age--;
    return age;
  }

  static List<FoodItem> makananUntuk(String kategori) {
    switch (kategori) {
      case 'Underweight':
        return const [
          FoodItem('Nasi Ayam Goreng', '🍗', 450),
          FoodItem('Alpukat', '🥑', 240),
          FoodItem('Susu Full Cream', '🥛', 150),
          FoodItem('Roti Selai Kacang', '🍞', 300),
          FoodItem('Pisang', '🍌', 105),
          FoodItem('Telur Dadar', '🍳', 190),
          FoodItem('Kentang Panggang', '🥔', 160),
          FoodItem('Kacang Almond', '🥜', 170),
          FoodItem('Smoothie Pisang Susu', '🥤', 250),
          FoodItem('Nasi Uduk Telur', '🍚', 420),
          FoodItem('Keju', '🧀', 110),
          FoodItem('Bubur Ayam', '🥣', 350),
        ];
      case 'Overweight':
        return const [
          FoodItem('Dada Ayam Rebus', '🍗', 165),
          FoodItem('Sayur Bening', '🥣', 50),
          FoodItem('Telur Rebus', '🥚', 78),
          FoodItem('Apel', '🍎', 95),
          FoodItem('Oatmeal', '🥣', 150),
          FoodItem('Pepes Ikan', '🐟', 180),
          FoodItem('Salad Sayur', '🥗', 80),
          FoodItem('Brokoli Kukus', '🥦', 55),
          FoodItem('Tahu Kukus', '🍲', 90),
          FoodItem('Pepaya', '🍈', 60),
          FoodItem('Timun', '🥒', 16),
          FoodItem('Yogurt Plain', '🥛', 100),
        ];
      case 'Obesitas':
        return const [
          FoodItem('Salad Sayur', '🥗', 80),
          FoodItem('Brokoli Kukus', '🥦', 55),
          FoodItem('Dada Ayam Rebus', '🍗', 165),
          FoodItem('Tahu Kukus', '🍲', 90),
          FoodItem('Pepaya', '🍈', 60),
          FoodItem('Timun', '🥒', 16),
          FoodItem('Telur Rebus', '🥚', 78),
          FoodItem('Sup Sayur', '🥣', 60),
          FoodItem('Bayam Rebus', '🥬', 40),
          FoodItem('Semangka', '🍉', 45),
          FoodItem('Jeruk', '🍊', 60),
          FoodItem('Ikan Kukus', '🐟', 140),
        ];
      default:
        return const [
          FoodItem('Nasi Merah + Ikan', '🐟', 400),
          FoodItem('Tempe Panggang', '🍢', 125),
          FoodItem('Sayur Bening Bayam', '🥬', 50),
          FoodItem('Telur Rebus', '🥚', 78),
          FoodItem('Pisang', '🍌', 105),
          FoodItem('Salad Buah', '🍓', 120),
          FoodItem('Gado-gado', '🥗', 300),
          FoodItem('Soto Ayam', '🍲', 250),
          FoodItem('Pepes Ikan', '🐟', 180),
          FoodItem('Tahu Kukus', '🍲', 90),
          FoodItem('Jeruk', '🍊', 60),
          FoodItem('Yogurt Plain', '🥛', 100),
        ];
    }
  }

  static const _ekstra = <FoodItem>[
    FoodItem('Nasi Putih', '🍚', 260),
    FoodItem('Ayam Goreng', '🍗', 260),
    FoodItem('Tempe Goreng', '🍢', 80),
    FoodItem('Tahu Goreng', '🍢', 70),
    FoodItem('Ikan Goreng', '🐟', 200),
    FoodItem('Nasi Goreng', '🍛', 330),
    FoodItem('Mie Instan Goreng', '🍜', 380),
    FoodItem('Mie Ayam', '🍜', 420),
    FoodItem('Bakso', '🍜', 300),
    FoodItem('Seblak', '🍲', 350),
    FoodItem('Gorengan (Bakwan)', '🥟', 80),
    FoodItem('Pecel', '🥗', 250),
    FoodItem('Lontong Sayur', '🍲', 300),
    FoodItem('Roti Tawar (2 lembar)', '🍞', 150),
    FoodItem('Kopi Susu', '☕', 120),
    FoodItem('Es Teh Manis', '🧋', 100),
    FoodItem('Kentang Goreng', '🍟', 310),
    FoodItem('Biskuit', '🍪', 130),
    FoodItem('Cokelat', '🍫', 150),
    FoodItem('Es Krim', '🍨', 200),
  ];

  /// Daftar lengkap makanan yang bisa dipilih saat mencatat (A-Z, tanpa duplikat).
  static List<FoodItem> get katalog {
    final map = <String, FoodItem>{};
    for (final k in ['Underweight', 'Normal', 'Overweight', 'Obesitas']) {
      for (final f in makananUntuk(k)) {
        map.putIfAbsent(f.nama, () => f);
      }
    }
    for (final f in _ekstra) {
      map.putIfAbsent(f.nama, () => f);
    }
    return map.values.toList()..sort((a, b) => a.nama.compareTo(b.nama));
  }
}
