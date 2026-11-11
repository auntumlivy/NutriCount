import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // dibuat oleh `flutterfire configure`
import 'screens/admin_shell.dart';
import 'screens/demo_gate.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/data_service.dart';
import 'services/firestore_service.dart';
import 'theme.dart';

/// Jika Firebase sudah dikonfigurasi -> Login/Sign Up + Firestore.
/// Jika belum -> mode demo lokal (pilih masuk sebagai pengguna atau admin).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseSiap = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    DataService.instance = FirestoreService();
    firebaseSiap = true;
  } catch (e) {
    debugPrint('Firebase belum siap, memakai mode demo lokal: $e');
  }
  runApp(NutriCountApp(firebaseSiap: firebaseSiap));
}

class NutriCountApp extends StatelessWidget {
  final bool firebaseSiap;
  const NutriCountApp({super.key, required this.firebaseSiap});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCount',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: firebaseSiap ? const AuthGate() : const DemoGate(),
    );
  }
}

class _Memuat extends StatelessWidget {
  const _Memuat();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

/// Belum login -> LoginScreen. Sudah login -> RoleGate.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Memuat();
        }
        final user = snap.data;
        if (user == null) return const LoginScreen();
        return RoleGate(key: ValueKey(user.uid));
      },
    );
  }
}

/// Memilih tampilan sesuai field `role` di dokumen users/{uid}:
/// "admin" -> AdminShell, selain itu -> MainShell (pengguna).
class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  late final Stream<Map<String, dynamic>?> _userS =
      DataService.instance.userStream();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _userS,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const _Memuat();
        }
        return snap.data?['role'] == 'admin'
            ? const AdminShell()
            : const MainShell();
      },
    );
  }
}
