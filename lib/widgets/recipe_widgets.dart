import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/cloudinary_service.dart';
import '../theme.dart';
import 'app_widgets.dart';

/// Label kecil status resep: Menunggu / Disetujui / Ditolak.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    String label = 'Menunggu';
    Color warna = AppColors.overweight;
    if (status == RecipeStatus.approved) {
      label = 'Disetujui';
      warna = AppColors.normal;
    } else if (status == RecipeStatus.rejected) {
      label = 'Ditolak';
      warna = AppColors.obesitas;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
      BoxDecoration(color: warna, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              fontSize: AppText.caption,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
    );
  }
}

/// Foto resep. Mendukung URL Cloudinary (baru) dan base64 (data lama).
class RecipePhoto extends StatefulWidget {
  final String data;
  final double? width;
  final double height;
  final double radius;

  const RecipePhoto({
    super.key,
    required this.data,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<RecipePhoto> createState() => _RecipePhotoState();
}

class _RecipePhotoState extends State<RecipePhoto> {
  Uint8List? _bytes; // hanya untuk foto lama (base64)

  bool get _adalahUrl => widget.data.startsWith('http');

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(covariant RecipePhoto old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) _decode();
  }

  void _decode() {
    if (widget.data.isEmpty || _adalahUrl) {
      _bytes = null;
      return;
    }
    try {
      _bytes = base64Decode(widget.data);
    } catch (_) {
      _bytes = null;
    }
  }

  Widget _kosong() => Container(
    width: widget.width,
    height: widget.height,
    color: AppColors.fieldGrey,
    child: const Icon(Icons.broken_image_outlined,
        color: AppColors.textHint),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    Widget gambar;
    if (_adalahUrl) {
      final w = (widget.width != null && widget.width!.isFinite)
          ? widget.width!
          : 600.0;
      gambar = Image.network(
        CloudinaryService.thumb(widget.data,
            width: (w * 2).round().clamp(200, 1200)),
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.fieldGrey,
          alignment: Alignment.center,
          child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5)),
        ),
        errorBuilder: (_, __, ___) => _kosong(),
      );
    } else if (_bytes != null) {
      gambar = Image.memory(_bytes!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _kosong());
    } else {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: gambar,
    );
  }
}

/// Kartu satu resep di daftar (dengan foto kecil kalau ada).
class RecipeCard extends StatelessWidget {
  final Recipe resep;
  final VoidCallback onTap;
  final bool tampilStatus;

  const RecipeCard({
    super.key,
    required this.resep,
    required this.onTap,
    this.tampilStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.sageLight.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resep.foto.isNotEmpty) ...[
                  RecipePhoto(data: resep.foto, width: 84, height: 84),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(resep.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: serif(size: AppText.body)),
                          ),
                          if (tampilStatus) ...[
                            const SizedBox(width: 8),
                            StatusChip(resep.status),
                          ],
                        ],
                      ),
                      if (resep.deskripsi.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(resep.deskripsi,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 10),
                      Text(
                          'oleh ${resep.namaPembuat}  ·  ±${resep.kalori} kkal',
                          style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: AppText.small)),
                      if (tampilStatus &&
                          resep.status == RecipeStatus.rejected &&
                          resep.alasanTolak.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Alasan: ${resep.alasanTolak}',
                            style: const TextStyle(
                                color: Color(0xFFB5524A),
                                fontSize: AppText.small)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Baris menu dengan ikon + panah (dipakai di Profil).
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuTile(
      {super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.fieldGrey,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.sageDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: AppText.body, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tampilan kosong / pesan (daftar kosong, akses ditolak, error).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.sageLight),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}