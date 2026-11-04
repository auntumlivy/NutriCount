import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  static const _batas = Duration(seconds: 20);

  Future<void> login(String email, String password) async {
    await _auth
        .signInWithEmailAndPassword(email: email.trim(), password: password)
        .timeout(_batas);
  }

  Future<void> signUp({
    required String nama,
    required String email,
    required String password,
    required String tglLahir,
  }) async {
    final cred = await _auth
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password)
        .timeout(_batas);
    try {
      await _db.collection('users').doc(cred.user!.uid).set({
        'nama': nama.trim(),
        'email': email.trim(),
        'tglLahir': tglLahir,
        'role': 'user', // admin: ubah manual di Firebase Console
        'targetBerat': null,
        'dibuat': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      // Database belum siap / koneksi lambat: lanjut saja, akan tersinkron nanti.
    }
  }

  Future<void> logout() => _auth.signOut();

  static String pesanError(Object e) {
    if (e is TimeoutException) {
      return 'Koneksi terlalu lama. Cek internet di emulator/HP, lalu coba lagi.';
    }
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau password salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar.';
        case 'weak-password':
          return 'Password minimal 6 karakter.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet.';
      }
      return e.message ?? 'Terjadi kesalahan.';
    }
    return 'Terjadi kesalahan: $e';
  }
}
