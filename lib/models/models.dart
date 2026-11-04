/// Model murni (tanpa dependensi Firebase).
class BmiRecord {
  final String id;
  final int usia;
  final String gender; // 'L' / 'P'
  final double tinggi;
  final double berat;
  final double bmi;
  final String kategori;
  final double kalori;
  final DateTime tanggal;

  BmiRecord({
    this.id = '',
    required this.usia,
    required this.gender,
    required this.tinggi,
    required this.berat,
    required this.bmi,
    required this.kategori,
    required this.kalori,
    required this.tanggal,
  });
}

class FoodLog {
  final String id;
  final String nama;
  final int kalori;
  final String waktu; // Sarapan / Lunch / Dinner / Snack
  final String hari; // yyyy-MM-dd
  final DateTime tanggal;

  FoodLog({
    this.id = '',
    required this.nama,
    required this.kalori,
    required this.waktu,
    required this.hari,
    required this.tanggal,
  });
}

class FoodItem {
  final String nama;
  final String emoji;
  final int kalori; // estimasi per porsi
  final String? id; // terisi untuk makanan buatan sendiri
  const FoodItem(this.nama, this.emoji, this.kalori, {this.id});
}
