import 'package:flutter/material.dart';
import '../models/models.dart';
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

/// Kartu satu resep di daftar.
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
                Text('oleh ${resep.namaPembuat}  ·  ±${resep.kalori} kkal',
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: AppText.small)),
                if (tampilStatus &&
                    resep.status == RecipeStatus.rejected &&
                    resep.alasanTolak.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Alasan: ${resep.alasanTolak}',
                      style: const TextStyle(
                          color: Color(0xFFB5524A), fontSize: AppText.small)),
                ],
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
