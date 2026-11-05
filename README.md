# NutriCount

Aplikasi Flutter untuk memantau BMI dan kalori harian, dengan rekomendasi makanan
dan resep komunitas yang dikurasi admin.

## Fitur

**Pengguna**
- Hitung BMI dan kebutuhan kalori harian, simpan riwayatnya
- Catat makanan per waktu makan (Sarapan, Lunch, Dinner, Snack)
- Rekomendasi makanan sesuai kategori BMI. Ketuk kartu makanan untuk melihat kalori dan resep
- Kirim resep sendiri (boleh dari internet, lengkap dengan link sumber) dan pantau statusnya
- Login dan Sign Up

**Admin** (halaman login, sign up, dan beranda tersendiri)
- Dashboard ringkasan resep
- Setujui atau tolak resep kiriman pengguna, tarik atau hapus resep
- Terbitkan resep langsung

## Menjalankan

```bash
flutter pub add google_fonts fl_chart firebase_core firebase_auth cloud_firestore
flutter run
```

Tanpa konfigurasi Firebase, aplikasi berjalan di **mode demo lokal**: pilih masuk sebagai
pengguna atau admin, data tersimpan sementara di memori.

Untuk Firebase dan cara menjadi admin, lihat [README_SETUP.md](README_SETUP.md).

## Struktur

```
lib/
  main.dart            titik masuk, memilih mode Firebase atau demo
  theme.dart           warna dan skala ukuran font (AppText)
  models/ services/    model data, penyimpanan (Firestore / lokal), auth
  screens/             layar pengguna dan layar admin
  widgets/ data/       komponen UI dan resep bawaan
firestore.rules        aturan keamanan Firestore
```
