PANDUAN LENGKAP: HUBUNGKAN NUTRICOUNT KE FIREBASE (TANPA flutterfire configure)

Isi paket:
- lib/main.dart : entry point aplikasi
- lib/recipes/ : seluruh kode fitur (login, resep pengguna, admin)
- firestore.rules : aturan keamanan Firestore

Tidak ada file bawaan project kamu yang tertimpa, karena semua kode fitur ada di folder lib/recipes.

======================================================================
LANGKAH 1. DAFTARKAN APLIKASI ANDROID DI FIREBASE
======================================================================
1. Buka project android/app/build.gradle.kts (atau build.gradle).
   Cari baris applicationId, contoh: applicationId = "com.example.nutricount"
   Catat nilainya persis (ini nama package).
2. Buka console.firebase.google.com, pilih project nutricount.
3. Klik ikon roda gigi di sebelah Project Overview, pilih Project settings.
4. Di tab General, gulir ke "Your apps". Kalau belum ada aplikasi Android,
   klik ikon Android (robot hijau) atau "Add app".
5. Isi "Android package name" dengan applicationId tadi. HARUS SAMA PERSIS.
   Nickname boleh dikosongkan. SHA-1 boleh dikosongkan.
6. Klik Register app, lalu Download google-services.json.
7. Salin file itu ke folder:  D:\nutricount\android\app\
   Hasil akhir: D:\nutricount\android\app\google-services.json
8. Klik Next sampai selesai. Langkah Gradle di console tidak perlu diikuti,
   kita lakukan di langkah 2.

======================================================================
LANGKAH 2. EDIT FILE GRADLE (ANDROID)
======================================================================
Buka folder android di Android Studio (Project view, mode Project atau Android).
Cari dulu file mana yang kamu punya. Project Flutter baru memakai CARA A.
Project lama memakai CARA B. Ikuti hanya satu.

CARA A. Kalau ada file android/settings.gradle.kts atau android/settings.gradle
yang berisi blok "plugins { ... id("com.android.application") version ... }"

A1. Di android/settings.gradle.kts, di dalam blok plugins, tambahkan satu baris:

    id("com.google.gms.google-services") version "4.4.2" apply false

    Contoh hasil akhir:
    plugins {
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
        id("com.android.application") version "8.7.0" apply false
        id("org.jetbrains.kotlin.android") version "1.8.22" apply false
        id("com.google.gms.google-services") version "4.4.2" apply false
    }

    (Kalau file-nya settings.gradle berformat Groovy, tulis:
     id "com.google.gms.google-services" version "4.4.2" apply false)

A2. Di android/app/build.gradle.kts, di blok plugins paling atas, tambahkan:

    id("com.google.gms.google-services")

    Contoh hasil akhir:
    plugins {
        id("com.android.application")
        id("kotlin-android")
        id("dev.flutter.flutter-gradle-plugin")
        id("com.google.gms.google-services")
    }

    (Format Groovy, android/app/build.gradle:  id 'com.google.gms.google-services')
    Plugin ini harus ditaruh sesudah plugin com.android.application.

CARA B. Kalau tidak ada blok plugins di settings.gradle, tapi android/build.gradle
berisi blok "buildscript { dependencies { ... } }"

B1. Di android/build.gradle, di dalam buildscript > dependencies, tambahkan:

    classpath 'com.google.gms:google-services:4.4.2'

B2. Di android/app/build.gradle, di bagian paling bawah file, tambahkan:

    apply plugin: 'com.google.gms.google-services'

A3 / B3 (kedua cara). Atur minSdk minimal 23.
Di android/app/build.gradle.kts, bagian android > defaultConfig, cari minSdk.
Ubah menjadi:   minSdk = 23
(Format Groovy:  minSdkVersion 23)
Kalau sudah angka 23 atau lebih, biarkan.

======================================================================
LANGKAH 3. IZIN MEMBUKA LINK (ANDROID 11 KE ATAS)
======================================================================
Buka android/app/src/main/AndroidManifest.xml.
Tambahkan blok berikut di dalam tag <manifest>, sejajar dengan <application>
(letakkan sebelum tag <application>):

    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW"/>
            <data android:scheme="https"/>
        </intent>
    </queries>

Pastikan juga ada baris izin internet. Kalau belum ada, tambahkan di atas <application>:

    <uses-permission android:name="android.permission.INTERNET"/>

======================================================================
LANGKAH 4. TAMBAH PACKAGE FLUTTER
======================================================================
Di terminal Android Studio (folder D:\nutricount), jalankan:

    flutter pub add firebase_core firebase_auth cloud_firestore url_launcher
    flutter pub get

Kalau muncul error versi SDK, jalankan "flutter upgrade" lalu ulangi.

======================================================================
LANGKAH 5. SALIN KODE FITUR
======================================================================
Salin dari paket ke project (D:\nutricount\lib):
- folder  recipes   ->  D:\nutricount\lib\recipes
- file    main.dart  ->  D:\nutricount\lib\main.dart (backup main.dart lama dulu)

Backup main.dart lama dulu kalau masih dibutuhkan.

======================================================================
LANGKAH 6. PUBLISH ATURAN FIRESTORE
======================================================================
1. Firebase console, Build, Firestore Database, tab Rules.
2. Hapus isi editor, tempel seluruh isi firestore.rules, klik Publish.
3. Pastikan Authentication, Sign-in method, Email/Password berstatus Enabled.

======================================================================
LANGKAH 7. JALANKAN
======================================================================
    flutter clean
    flutter pub get
    flutter run

Build pertama bisa 3 sampai 10 menit karena mengunduh Firebase SDK. Itu normal.

======================================================================
LANGKAH 8. BUAT KODE ADMIN DAN AKUN ADMIN
======================================================================
Aplikasi punya halaman masuk dan daftar yang terpisah untuk pengguna dan admin.
Daftar admin dilindungi kode rahasia yang kamu isi sendiri di Firebase.

1. Firebase console, Firestore Database, tab Data.
2. Klik Start collection, isi Collection ID: config, Next.
3. Document ID: admin
4. Tambah field: nama code, tipe string, nilai berupa kode rahasia kamu
   (pakai kode panjang dan sulit ditebak). Klik Save.
5. Pastikan rules sudah dipublish (langkah 6).
6. Di aplikasi: layar awal, pilih Admin, ketuk "Belum punya akun? Daftar",
   isi nama, email, password, dan kode admin yang tadi. Setelah berhasil kamu
   langsung masuk ke beranda admin.

Cara lain (manual): daftar sebagai pengguna biasa, lalu di Firestore koleksi users,
buka dokumen akunmu dan ubah field role menjadi admin. Setelah itu masuk lewat
halaman Masuk Admin.

Admin lain bisa diatur dari tab Pengguna di halaman admin.

======================================================================
LANGKAH 9. ISI DATA CONTOH DAN UJI ALUR
======================================================================
1. Masuk sebagai admin. Di tab Ringkasan, tekan "Isi data contoh (10 resep)".
   Resep contoh langsung disetujui dan tampil di beranda pengguna.
   Data bisa diubah atau ditambah langsung di Firebase console, koleksi recipes.
2. Keluar, lalu daftar sebagai pengguna (layar awal, pilih Pengguna).
3. Di beranda pengguna ada kotak rekomendasi makanan. Ketuk satu kotak untuk
   melihat kalori dan resepnya.
4. Tekan Tambah resep, isi form, kirim. Resep masuk ke Resep Saya dengan status menunggu.
5. Masuk sebagai admin, tab Menunggu, tekan Setujui atau Tolak.

Akun admin tidak bisa masuk lewat halaman pengguna, dan sebaliknya.

======================================================================
LANGKAH 10. GABUNGKAN KE APLIKASI UTAMA (SETELAH LANGKAH 9 BERHASIL)
======================================================================
Di main.dart milikmu, sebelum runApp, pastikan ada:

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

dan tambahkan import:

    import 'package:firebase_core/firebase_core.dart';
    import 'recipes/pages/auth_gate.dart';

Lalu jadikan AuthGate sebagai halaman awal:

    home: const AuthGate(),

Kalau aplikasimu sudah punya halaman beranda sendiri (misalnya BMI atau rekomendasi),
kirim main.dart dan file halamannya supaya bisa digabungkan dengan benar.

======================================================================
ERROR UMUM DAN SOLUSINYA
======================================================================
- "No matching client found for package name": applicationId di build.gradle
  berbeda dengan package name di google-services.json. Samakan, unduh ulang
  google-services.json, atau daftarkan aplikasi Android baru di Firebase.
- "File google-services.json is missing": file belum ada di android/app/.
- "Plugin com.google.gms.google-services was not found": baris di settings.gradle
  (cara A) atau classpath (cara B) belum ditambahkan.
- "[core/no-app] No Firebase App": google-services.json tidak terbaca atau
  Firebase.initializeApp() belum dipanggil.
- "permission-denied": rules belum dipublish, atau akun belum login.
- "minSdkVersion 21 cannot be smaller than version 23": naikkan minSdk ke 23.
- Gradle gagal mengunduh: cek koneksi internet, lalu jalankan flutter clean dan ulangi.

Kalau ada error lain, salin pesan error dari bagian paling atas yang berisi
kata "What went wrong" atau "FAILURE", lalu kirim.
