import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'theme.dart';

/// MODE LOKAL (tanpa Firebase, tanpa login). Data tersimpan sementara di memori.
/// Untuk mode Firebase + Login/Sign Up, lihat lib/main_firebase.dart.
void main() {
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
      home: const MainShell(),
    );
  }
}
