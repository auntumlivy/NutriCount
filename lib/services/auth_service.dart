import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  static const _batas = Duration(seconds: 20);

  Future<void> login(String email, String password) async {
    await _auth
        .signInWithEmailAndPassword(email: email.trim(), password: password)
        .timeout(_batas);
  }

  Future<void> kirimResetPassword(String email) async {
    await _auth
        .sendPasswordResetEmail(email: email.trim())
        .timeout(_batas);
  }

  /// Masuk dengan akun Google. Mengembalikan false jika user membatalkan pop-up.
  Future<bool> loginDenganGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false; // User menutup pop-up pilih akun

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential).timeout(_batas);
    final user = cred.user;

    if (user != null) {
      try {
        final docRef = _db.collection('users').doc(user.uid);
        final docSnap = await docRef.get().timeout(const Duration(seconds: 8));
        if (!docSnap.exists) {
          final namaDefault = (user.displayName ?? '').trim().isNotEmpty
              ? user.displayName!.trim()
              : (user.email ?? 'Pengguna').split('@').first;
          await docRef.set({
            'nama': namaDefault,
            'email': user.email ?? '',
            'tglLahir': '',
            'role': 'user',
            'targetBerat': null,
            'dibuat': FieldValue.serverTimestamp(),
          }).timeout(const Duration(seconds: 8));
        }
      } on TimeoutException {
        // Database lambat: user tetap masuk, dokumen bisa dilengkapi nanti.
      }
    }
    return true;
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
        'role': 'user', // jadikan admin: ubah field role manual di Firebase Console
        'targetBerat': null,
        'dibuat': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      // Database belum siap / koneksi lambat: lanjut saja, akan tersinkron nanti.
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

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
        case 'account-exists-with-different-credential':
          return 'Email sudah terdaftar dengan metode login lain.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      }
      return e.message ?? 'Terjadi kesalahan.';
    }
    return 'Terjadi kesalahan: $e';
  }
}