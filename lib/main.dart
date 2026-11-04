import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'theme.dart';

/// Versi tampilan saja: tanpa Firebase, tanpa login.
/// Data contoh ada di lib/services/local_service.dart (_isiDataContoh).
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
