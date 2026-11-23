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
  final int kalori; // kalori PER PORSI
  final int jumlah; // jumlah porsi (default 1)
  final String foto; // URL foto (kosong = pakai foto rekomendasi / emoji)
  final String waktu; // Sarapan / Lunch / Dinner / Snack
  final String hari; // yyyy-MM-dd
  final DateTime tanggal;

  FoodLog({
    this.id = '',
    required this.nama,
    required this.kalori,
    this.jumlah = 1,
    this.foto = '',
    required this.waktu,
    required this.hari,
    required this.tanggal,
  });

  /// Total kalori = kalori per porsi x jumlah.
  int get total => kalori * jumlah;
}

class FoodItem {
  final String nama;
  final String emoji;
  final int kalori; // estimasi per porsi
  final String? id; // terisi untuk makanan buatan sendiri
  const FoodItem(this.nama, this.emoji, this.kalori, {this.id});
}

/// Status resep kiriman user.
class RecipeStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
}

/// Resep yang dikirim user dan harus disetujui admin dulu.
class Recipe {
  final String id;
  final String judul;
  final String deskripsi;
  final List<String> bahan;
  final List<String> langkah;
  final int kalori; // per porsi
  final String kategoriBMI; // kategori target resep
  final String sumberUrl; // link asal resep (opsional)
  final String foto; // URL foto resep di Cloudinary (opsional)
  final String uid; // pembuat
  final String namaPembuat;
  final String status; // RecipeStatus.*
  final String alasanTolak;
  final DateTime dibuat;

  Recipe({
    this.id = '',
    required this.judul,
    this.deskripsi = '',
    required this.bahan,
    required this.langkah,
    required this.kalori,
    this.kategoriBMI = 'Semua Kategori',
    this.sumberUrl = '',
    this.foto = '',
    this.uid = '',
    this.namaPembuat = 'Anonim',
    this.status = RecipeStatus.pending,
    this.alasanTolak = '',
    required this.dibuat,
  });

  Recipe copyWith({
    String? id,
    String? uid,
    String? status,
    String? alasanTolak,
    String? kategoriBMI,
  }) =>
      Recipe(
        id: id ?? this.id,
        judul: judul,
        deskripsi: deskripsi,
        bahan: bahan,
        langkah: langkah,
        kalori: kalori,
        kategoriBMI: kategoriBMI ?? this.kategoriBMI,
        sumberUrl: sumberUrl,
        foto: foto,
        uid: uid ?? this.uid,
        namaPembuat: namaPembuat,
        status: status ?? this.status,
        alasanTolak: alasanTolak ?? this.alasanTolak,
        dibuat: dibuat,
      );
}
