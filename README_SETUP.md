# NutriCount: Setup

## 1. Jalankan tanpa Firebase (mode demo)
```
flutter pub add google_fonts fl_chart firebase_core firebase_auth cloud_firestore
flutter run
```
Layar pertama menawarkan **Masuk sebagai Pengguna** atau **Masuk sebagai Admin**.
Data hanya di memori dan hilang saat aplikasi ditutup.

## 2. Sambungkan Firebase (Login, Sign Up, database)
1. Firebase Console: aktifkan **Authentication > Email/Password** dan buat **Firestore Database**.
2. Firestore > **Rules**: tempel isi `firestore.rules`, lalu **Publish**.
3. Di terminal (folder project):
   ```
   firebase login
   dart pub global run flutterfire_cli:flutterfire configure
   ```
   Pilih project, centang Android. Jawab **yes** jika diminta menimpa `lib/firebase_options.dart`.
4. Jalankan ulang app. Sekarang yang muncul layar **Login** pengguna. Tombol "Masuk sebagai Admin" ada di bawahnya.

## 3. Menjadi admin
1. Buka app, **Masuk sebagai Admin > Daftar** (atau daftar biasa lewat Sign Up).
2. Firebase Console > Firestore > koleksi `users` > dokumen akunmu.
3. Ubah field `role` dari `user` menjadi `admin`.
4. Login lewat **Masuk sebagai Admin**. Akun yang belum `admin` akan ditolak.

## Struktur Firestore
- users/{uid}: nama, email, tglLahir, targetBerat, role (user/admin), mintaAdmin
- users/{uid}/bmi_records, food_logs, custom_foods
- recipes/{id}: judul, deskripsi, bahan[], langkah[], kalori, sumberUrl, uid, namaPembuat,
  status (pending/approved/rejected), alasanTolak, dibuat, ditinjau

## Alur resep
Pengguna kirim resep (status `pending`) -> admin Setujui (tampil ke semua pengguna) atau Tolak
(pengguna melihat alasannya di Resep Saya). Admin juga bisa menerbitkan resep langsung.
