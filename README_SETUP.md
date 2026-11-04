# NutriCount – Setup

## Mode sekarang: LOKAL (tanpa Firebase, tanpa login)
1. Ganti folder `lib/` project Flutter dengan isi zip ini.
2. Di `pubspec.yaml` cukup butuh `google_fonts` dan `fl_chart`
   (lihat `pubspec_dependencies.yaml`; paket firebase tidak dipakai di mode ini).
3. `flutter pub get`, lalu `flutter run`.
Catatan: data tersimpan di memori, jadi hilang saat aplikasi ditutup.

## Nanti: mode Firebase (Login + Sign Up + database)
1. Pastikan paket firebase di `pubspec.yaml` terpasang.
2. Buat project Firebase: aktifkan Authentication (Email/Password) dan Firestore, tempel `firestore.rules`.
3. `flutterfire configure` -> menghasilkan `lib/firebase_options.dart`.
4. Pindahkan isi `lib/main_firebase.dart` ke `lib/main.dart` (atau `flutter run -t lib/main_firebase.dart`).
5. Android: `minSdkVersion` minimal 23.

Struktur Firestore:
- users/{uid}                    -> nama, email, tglLahir, targetBerat
- users/{uid}/bmi_records/{id}   -> usia, gender, tinggi, berat, bmi, kategori, kalori, tanggal
- users/{uid}/food_logs/{id}     -> nama, kalori, waktu, hari, tanggal
- users/{uid}/custom_foods/{id}  -> nama, kalori, dibuat
