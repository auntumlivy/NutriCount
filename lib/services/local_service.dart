import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
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
  final _recipes = _Store<Recipe>();

  Map<String, dynamic> _user = {
    'nama': '',
    'email': '',
    'tglLahir': '',
    'targetBerat': null,
    'role': 'user',
  };
  final _userCtrl = StreamController<Map<String, dynamic>?>.broadcast();

  /// Peran yang sedang "masuk" di mode demo: null (belum pilih), 'user', 'admin'.
  static final ValueNotifier<String?> peran = ValueNotifier<String?>(null);

  /// Mode demo: masuk tanpa Firebase sebagai pengguna atau admin.
  void masukSebagai(String role) {
    _user = {
      ..._user,
      'role': role,
      if (role == 'admin') 'nama': 'Admin Demo',
      if (role == 'admin') 'email': 'admin@demo.local',
    };
    _userCtrl.add(Map.of(_user));
    peran.value = role;
  }

  @override
  bool get adaAkun => false;

  @override
  bool get bisaKeluar => true;

  @override
  Future<void> keluar() async {
    peran.value = null;
  }

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

  // ---------- RESEP KOMUNITAS ----------
  @override
  Future<void> submitRecipe(Recipe r) async {
    _recipes.set([
      r.copyWith(id: _id(), uid: 'lokal', status: RecipeStatus.pending),
      ..._recipes.items,
    ]);
  }

  @override
  Stream<List<Recipe>> approvedRecipesStream() => _recipes.watch().map(
      (l) => l.where((r) => r.status == RecipeStatus.approved).toList());

  @override
  Stream<List<Recipe>> myRecipesStream() => _recipes.watch();

  @override
  Stream<List<Recipe>> pendingRecipesStream() => _recipes
      .watch()
      .map((l) => l.where((r) => r.status == RecipeStatus.pending).toList());

  @override
  Future<void> setRecipeStatus(String id, String status,
      {String alasan = ''}) async {
    _recipes.set(_recipes.items
        .map((r) => r.id == id
            ? r.copyWith(
                status: status,
                alasanTolak: status == RecipeStatus.rejected ? alasan : '')
            : r)
        .toList());
  }

  @override
  Future<void> deleteRecipe(String id) async =>
      _recipes.set(_recipes.items.where((r) => r.id != id).toList());

  // ---------- KHUSUS ADMIN ----------
  @override
  Stream<List<Recipe>> allRecipesStream() => _recipes.watch();

  @override
  Future<void> adminAddRecipe(Recipe r) async {
    _recipes.set([
      r.copyWith(id: _id(), uid: 'lokal', status: RecipeStatus.approved),
      ..._recipes.items,
    ]);
  }
}
