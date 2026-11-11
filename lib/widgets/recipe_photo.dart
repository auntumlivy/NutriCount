import 'dart:convert';
import 'package:flutter/material.dart';

/// Menampilkan foto resep dari base64.
/// Tidak menampilkan apa-apa kalau foto kosong atau rusak.
class RecipePhoto extends StatelessWidget {
  final String foto;
  final double height;
  final double radius;

  const RecipePhoto({
    super.key,
    required this.foto,
    this.height = 200,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (foto.isEmpty) return const SizedBox.shrink();
    try {
      final bytes = base64Decode(foto);
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.memory(
          bytes,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}