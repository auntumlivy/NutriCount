import '../models/models.dart';
import 'local_service.dart';

/// Antarmuka penyimpanan data. Layar hanya memakai [DataService.instance].
///  - Mode lokal (default, tanpa Firebase): [LocalService]
///  - (Firebase sudah dihapus)
abstract class DataService {
  static DataService instance = LocalService();

  bool get adaAkun;
  Future<void> keluar();

  Future<Map<String, dynamic>?> getUser();
  Stream<Map<String, dynamic>?> userStream();
  Future<void> updateUser(Map<String, dynamic> data);

  Future<void> addBmi(BmiRecord r);
  Stream<List<BmiRecord>> bmiStream();
  Future<void> updateBmi(String id, Map<String, dynamic> data);
  Future<void> deleteBmi(String id);

  Future<void> addFood(FoodLog f);
  Future<void> updateFood(String id, String nama, int kalori);
  Future<void> deleteFood(String id);
  Stream<List<FoodLog>> foodsByDay(String hari);
  Stream<List<FoodLog>> foodsSince(DateTime since);

  Future<void> addCustomFood(String nama, int kalori);
  Stream<List<FoodItem>> customFoodsStream();
  Future<void> deleteCustomFood(String id);
}
