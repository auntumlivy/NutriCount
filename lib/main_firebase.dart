import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // dihasilkan oleh `flutterfire configure`
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/data_service.dart';
import 'services/firestore_service.dart';
import 'theme.dart';

/// MODE FIREBASE (Login + Sign Up + Firestore).
/// Nanti: ganti isi main.dart dengan file ini, atau jalankan:
///   flutter run -t lib/main_firebase.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DataService.instance = FirestoreService();
  runApp(const NutriCountApp());
}

class NutriCountApp extends StatelessWidget {
  const NutriCountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCount',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return snap.hasData ? const MainShell() : const LoginScreen();
      },
    );
  }
}
