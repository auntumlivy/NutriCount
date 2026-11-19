
import 'dart:convert';
import 'package:flutter/material.dart';

/// Menampilkan foto resep dari URL Cloudinary atau Base64 lama.
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

    final isUrl =
        foto.startsWith('https://') || foto.startsWith('http://');

    Widget gambar;

    if (isUrl) {
      gambar = Image.network(
        foto,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) =>
            const SizedBox.shrink(),
      );
    } else {
      try {
        final bytes = base64Decode(foto);
        gambar = Image.memory(
          bytes,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) =>
              const SizedBox.shrink(),
        );
      } catch (_) {
        return const SizedBox.shrink();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: gambar,
    );
  }
}
