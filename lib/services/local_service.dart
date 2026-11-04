import 'dart:async';
import '../models/models.dart';
import '../utils/bmi_utils.dart';
import 'data_service.dart';

class _Store<T> {
  final _ctrl = StreamController<List<T>>.broadcast();
  List<T> items = [];

  void set(List<T> v) {
    items = v;
    _ctrl.add(List.of(v));
  }

  Stream<List<T>> watch() async* {
    yield List.of(items);
    yield* _ctrl.stream;
  }
}

/// Penyimpanan di memori (sementara, hilang saat aplikasi ditutup).
/// Dipakai selama Firebase belum disambungkan.
class LocalService implements DataService {
  int _n = 0;
  String _id() => 'local_${++_n}';

  final _bmi = _Store<BmiRecord>();
  final _logs = _Store<FoodLog>();
  final _custom = _Store<FoodItem>();

  Map<String, dynamic> _user = {
    'nama': 'Ziel',
    'email': '',
    'tglLahir': '15/08/2005',
    'targetBerat': 66.0,
  };
  final _userCtrl = StreamController<Map<String, dynamic>?>.broadcast();

  LocalService() {
    _isiDataContoh();
  }

  /// Data contoh supaya semua layar langsung terisi saat aplikasi dijalankan.
  void _isiDataContoh() {
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);

    // Riwayat BMI: 5 catatan, tiap 7 hari, berat turun pelan-pelan.
    const tinggi = 170.0;
    const beratList = [69.5, 70.8, 72.1, 73.4, 74.6]; // terbaru -> terlama
    final bmiList = <BmiRecord>[];
    for (var i = 0; i < beratList.length; i++) {
      final berat = beratList[i];
      final bmi = BmiUtils.hitungBmi(berat, tinggi);
      final kat = BmiUtils.kategori(bmi);
      bmiList.add(BmiRecord(
        id: _id(),
        usia: 21,
        gender: 'L',
        tinggi: tinggi,
        berat: berat,
        bmi: bmi,
        kategori: kat,
        kalori: BmiUtils.kaloriHarian(
            berat: berat, tinggi: tinggi, usia: 21, pria: true, kategori: kat),
        tanggal: hariIni.subtract(Duration(days: i * 7)).add(
            const Duration(hours: 8)),
      ));
    }
    _bmi.items = bmiList;

    // Catatan makanan 7 hari terakhir.
    const menu = [
      ['Sarapan', 'Bubur Ayam', 350],
      ['Lunch', 'Nasi Merah + Ikan', 400],
      ['Dinner', 'Soto Ayam', 250],
      ['Snack', 'Pisang', 105],
      ['Sarapan', 'Oatmeal', 150],
      ['Lunch', 'Gado-gado', 300],
      ['Dinner', 'Pepes Ikan', 180],
      ['Snack', 'Apel', 95],
      ['Snack', 'Yogurt Plain', 100],
      ['Dinner', 'Tempe Panggang', 125],
    ];
    final logs = <FoodLog>[];
    for (var d = 0; d < 7; d++) {
      final hari = hariIni.subtract(Duration(days: d));
      // hari ini cuma 3 catatan, hari lain 4-5 catatan
      final jumlah = d == 0 ? 3 : 4 + (d % 2);
      for (var k = 0; k < jumlah; k++) {
        final m = menu[(d * 3 + k) % menu.length];
        logs.add(FoodLog(
          id: _id(),
          nama: m[1] as String,
          kalori: m[2] as int,
          waktu: m[0] as String,
          hari: BmiUtils.dayKey(hari),
          tanggal: hari.add(Duration(hours: 7 + k * 4)),
        ));
      }
    }
    _logs.items = logs;
  }

  @override
  bool get adaAkun => false;

  @override
  Future<void> keluar() async {}

  // ---------- USER ----------
  @override
  Future<Map<String, dynamic>?> getUser() async => Map.of(_user);

  @override
  Stream<Map<String, dynamic>?> userStream() async* {
    yield Map.of(_user);
    yield* _userCtrl.stream;
  }

  @override
  Future<void> updateUser(Map<String, dynamic> data) async {
    _user = {..._user, ...data};
    _userCtrl.add(Map.of(_user));
  }

  // ---------- BMI ----------
  @override
  Future<void> addBmi(BmiRecord r) async {
    final baru = BmiRecord(
      id: _id(),
      usia: r.usia,
      gender: r.gender,
      tinggi: r.tinggi,
      berat: r.berat,
      bmi: r.bmi,
      kategori: r.kategori,
      kalori: r.kalori,
      tanggal: r.tanggal,
    );
    final list = [baru, ..._bmi.items]
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    _bmi.set(list);
  }

  @override
  Stream<List<BmiRecord>> bmiStream() => _bmi.watch();

  @override
  Future<void> updateBmi(String id, Map<String, dynamic> data) async {
    _bmi.set(_bmi.items.map((r) {
      if (r.id != id) return r;
      return BmiRecord(
        id: r.id,
        usia: r.usia,
        gender: r.gender,
        tinggi: r.tinggi,
        berat: (data['berat'] as num?)?.toDouble() ?? r.berat,
        bmi: (data['bmi'] as num?)?.toDouble() ?? r.bmi,
        kategori: (data['kategori'] as String?) ?? r.kategori,
        kalori: r.kalori,
        tanggal: r.tanggal,
      );
    }).toList());
  }

  @override
  Future<void> deleteBmi(String id) async =>
      _bmi.set(_bmi.items.where((r) => r.id != id).toList());

  // ---------- CATATAN MAKANAN ----------
  @override
  Future<void> addFood(FoodLog f) async {
    _logs.set([
      ..._logs.items,
      FoodLog(
        id: _id(),
        nama: f.nama,
        kalori: f.kalori,
        waktu: f.waktu,
        hari: f.hari,
        tanggal: f.tanggal,
      ),
    ]);
  }

  @override
  Future<void> updateFood(String id, String nama, int kalori) async {
    _logs.set(_logs.items
        .map((f) => f.id == id
            ? FoodLog(
                id: f.id,
                nama: nama,
                kalori: kalori,
                waktu: f.waktu,
                hari: f.hari,
                tanggal: f.tanggal)
            : f)
        .toList());
  }

  @override
  Future<void> deleteFood(String id) async =>
      _logs.set(_logs.items.where((f) => f.id != id).toList());

  @override
  Stream<List<FoodLog>> foodsByDay(String hari) =>
      _logs.watch().map((l) => l.where((f) => f.hari == hari).toList());

  @override
  Stream<List<FoodLog>> foodsSince(DateTime since) {
    final start = DateTime(since.year, since.month, since.day);
    return _logs
        .watch()
        .map((l) => l.where((f) => !f.tanggal.isBefore(start)).toList());
  }

  // ---------- MAKANAN BUATAN SENDIRI ----------
  @override
  Future<void> addCustomFood(String nama, int kalori) async {
    _custom.set([..._custom.items, FoodItem(nama, '🍽️', kalori, id: _id())]);
  }

  @override
  Stream<List<FoodItem>> customFoodsStream() => _custom.watch();

  @override
  Future<void> deleteCustomFood(String id) async =>
      _custom.set(_custom.items.where((f) => f.id != id).toList());
}
