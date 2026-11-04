import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'data_service.dart';

Map<String, dynamic> _bmiToMap(BmiRecord r) => {
      'usia': r.usia,
      'gender': r.gender,
      'tinggi': r.tinggi,
      'berat': r.berat,
      'bmi': r.bmi,
      'kategori': r.kategori,
      'kalori': r.kalori,
      'tanggal': Timestamp.fromDate(r.tanggal),
    };

BmiRecord _bmiFromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
  final m = d.data()!;
  return BmiRecord(
    id: d.id,
    usia: (m['usia'] ?? 0).toInt(),
    gender: m['gender'] ?? 'L',
    tinggi: (m['tinggi'] ?? 0).toDouble(),
    berat: (m['berat'] ?? 0).toDouble(),
    bmi: (m['bmi'] ?? 0).toDouble(),
    kategori: m['kategori'] ?? 'Normal',
    kalori: (m['kalori'] ?? 0).toDouble(),
    tanggal: (m['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

Map<String, dynamic> _logToMap(FoodLog f) => {
      'nama': f.nama,
      'kalori': f.kalori,
      'waktu': f.waktu,
      'hari': f.hari,
      'tanggal': Timestamp.fromDate(f.tanggal),
    };

FoodLog _logFromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
  final m = d.data()!;
  return FoodLog(
    id: d.id,
    nama: m['nama'] ?? '',
    kalori: (m['kalori'] ?? 0).toInt(),
    waktu: m['waktu'] ?? 'Snack',
    hari: m['hari'] ?? '',
    tanggal: (m['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

Recipe _recipeFromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
  final m = d.data()!;
  return Recipe(
    id: d.id,
    judul: m['judul'] ?? '',
    deskripsi: m['deskripsi'] ?? '',
    bahan: List<String>.from(m['bahan'] ?? const []),
    langkah: List<String>.from(m['langkah'] ?? const []),
    kalori: (m['kalori'] ?? 0).toInt(),
    sumberUrl: m['sumberUrl'] ?? '',
    uid: m['uid'] ?? '',
    namaPembuat: m['namaPembuat'] ?? 'Anonim',
    status: m['status'] ?? RecipeStatus.pending,
    alasanTolak: m['alasanTolak'] ?? '',
    dibuat: (m['dibuat'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

/// Penyimpanan di Firebase Firestore (dipakai oleh lib/main_firebase.dart):
/// users/{uid}
/// users/{uid}/bmi_records/{id}
/// users/{uid}/food_logs/{id}
/// users/{uid}/custom_foods/{id}
/// recipes/{id}   (resep komunitas, ada field status: pending/approved/rejected)
class FirestoreService implements DataService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);
  CollectionReference<Map<String, dynamic>> get _bmi =>
      _userDoc.collection('bmi_records');
  CollectionReference<Map<String, dynamic>> get _logs =>
      _userDoc.collection('food_logs');
  CollectionReference<Map<String, dynamic>> get _custom =>
      _userDoc.collection('custom_foods');

  @override
  bool get adaAkun => true;

  @override
  Future<void> keluar() => FirebaseAuth.instance.signOut();

  // ---------- USER ----------
  @override
  Future<Map<String, dynamic>?> getUser() async =>
      (await _userDoc.get()).data();

  @override
  Stream<Map<String, dynamic>?> userStream() =>
      _userDoc.snapshots().map((d) => d.data());

  @override
  Future<void> updateUser(Map<String, dynamic> data) =>
      _userDoc.set(data, SetOptions(merge: true));

  // ---------- BMI ----------
  @override
  Future<void> addBmi(BmiRecord r) => _bmi.add(_bmiToMap(r));

  @override
  Stream<List<BmiRecord>> bmiStream() => _bmi
      .orderBy('tanggal', descending: true)
      .snapshots()
      .map((s) => s.docs.map(_bmiFromDoc).toList());

  @override
  Future<void> updateBmi(String id, Map<String, dynamic> data) =>
      _bmi.doc(id).update(data);

  @override
  Future<void> deleteBmi(String id) => _bmi.doc(id).delete();

  // ---------- CATATAN MAKANAN ----------
  @override
  Future<void> addFood(FoodLog f) => _logs.add(_logToMap(f));

  @override
  Future<void> updateFood(String id, String nama, int kalori) =>
      _logs.doc(id).update({'nama': nama, 'kalori': kalori});

  @override
  Future<void> deleteFood(String id) => _logs.doc(id).delete();

  @override
  Stream<List<FoodLog>> foodsByDay(String hari) => _logs
      .where('hari', isEqualTo: hari)
      .snapshots()
      .map((s) => s.docs.map(_logFromDoc).toList());

  @override
  Stream<List<FoodLog>> foodsSince(DateTime since) {
    final start = DateTime(since.year, since.month, since.day);
    return _logs
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map((s) => s.docs.map(_logFromDoc).toList());
  }

  // ---------- MAKANAN BUATAN SENDIRI ----------
  @override
  Future<void> addCustomFood(String nama, int kalori) =>
      _custom.add({'nama': nama, 'kalori': kalori, 'dibuat': Timestamp.now()});

  @override
  Stream<List<FoodItem>> customFoodsStream() => _custom.snapshots().map((s) =>
      s.docs
          .map((d) => FoodItem(
                (d.data()['nama'] ?? '') as String,
                '🍽️',
                ((d.data()['kalori'] ?? 0) as num).toInt(),
                id: d.id,
              ))
          .toList());

  @override
  Future<void> deleteCustomFood(String id) => _custom.doc(id).delete();

  // ---------- RESEP KOMUNITAS ----------
  CollectionReference<Map<String, dynamic>> get _recipes =>
      _db.collection('recipes');

  // Diurutkan di sisi aplikasi supaya tidak butuh composite index Firestore.
  Stream<List<Recipe>> _recipeStream(Query<Map<String, dynamic>> q,
          {bool terbaruDulu = true}) =>
      q.snapshots().map((s) {
        final list = s.docs.map(_recipeFromDoc).toList();
        list.sort((a, b) => terbaruDulu
            ? b.dibuat.compareTo(a.dibuat)
            : a.dibuat.compareTo(b.dibuat));
        return list;
      });

  @override
  Future<void> submitRecipe(Recipe r) => _recipes.add({
        'judul': r.judul,
        'deskripsi': r.deskripsi,
        'bahan': r.bahan,
        'langkah': r.langkah,
        'kalori': r.kalori,
        'sumberUrl': r.sumberUrl,
        'uid': _uid,
        'namaPembuat': r.namaPembuat,
        'status': RecipeStatus.pending,
        'alasanTolak': '',
        'dibuat': Timestamp.now(),
      });

  @override
  Stream<List<Recipe>> approvedRecipesStream() =>
      _recipeStream(_recipes.where('status', isEqualTo: RecipeStatus.approved));

  @override
  Stream<List<Recipe>> myRecipesStream() =>
      _recipeStream(_recipes.where('uid', isEqualTo: _uid));

  @override
  Stream<List<Recipe>> pendingRecipesStream() => _recipeStream(
      _recipes.where('status', isEqualTo: RecipeStatus.pending),
      terbaruDulu: false);

  @override
  Future<void> setRecipeStatus(String id, String status,
          {String alasan = ''}) =>
      _recipes.doc(id).update({
        'status': status,
        'alasanTolak': status == RecipeStatus.rejected ? alasan : '',
        'ditinjau': Timestamp.now(),
      });

  @override
  Future<void> deleteRecipe(String id) => _recipes.doc(id).delete();
}
