import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import '../widgets/food_dialog.dart';
import '../widgets/food_thumb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Maksimal geser ke kemarin / besok (ubah angka ini, misalnya 7 untuk 1 minggu).
  static const _batasHari = 14;

  static const _waktuMakan = ['Sarapan', 'Lunch', 'Dinner', 'Snack'];
  static const _ikonWaktu = {
    'Sarapan': Icons.free_breakfast_outlined,
    'Lunch': Icons.lunch_dining_outlined,
    'Dinner': Icons.dinner_dining_outlined,
    'Snack': Icons.cookie_outlined,
  };

  static const _namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  final _fs = DataService.instance;
  late final Stream<List<BmiRecord>> _bmiStream = _fs.bmiStream();
  late final Stream<Map<String, dynamic>?> _userStream = _fs.userStream();

  int _offset = 0; // 0 = hari ini, -1 = kemarin, 1 = besok
  late Stream<List<FoodLog>> _logStream =
  _fs.foodsByDay(BmiUtils.dayKey(DateTime.now()));

  DateTime get _tanggal {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + _offset);
  }
  /// Nama makanan katalog admin (untuk menangani catatan lama
  /// yang tersimpan sebelum field dariAdmin ada).
  static final _namaKatalog = {
    for (final k in BmiUtils.katalog) k.nama.toLowerCase(),
  };

  /// Makanan dari admin tidak boleh diubah kalorinya oleh user.
  /// Makanan input user sendiri (seperti kimbab) boleh diedit.
  bool _bisaDiedit(FoodLog f) =>
      !f.dariAdmin && !_namaKatalog.contains(f.nama.trim().toLowerCase());
  void _geser(int delta) {
    final baru = (_offset + delta).clamp(-_batasHari, _batasHari).toInt();
    if (baru == _offset) return;
    setState(() {
      _offset = baru;
      _logStream = _fs.foodsByDay(BmiUtils.dayKey(_tanggal));
    });
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateUtils.dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: sekarang.subtract(const Duration(days: _batasHari)),
      lastDate: sekarang.add(const Duration(days: _batasHari)),
    );
    if (d == null) return;
    _geser(DateUtils.dateOnly(d).difference(sekarang).inDays - _offset);
  }

  String _labelTanggal() {
    final t = _tanggal;
    final tgl = '${t.day} ${_namaBulan[t.month - 1]}';
    if (_offset == 0) return 'Hari ini, $tgl';
    if (_offset == -1) return 'Kemarin, $tgl';
    if (_offset == 1) return 'Besok, $tgl';
    return '${_namaHari[t.weekday - 1]}, $tgl';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _userStream,
      builder: (context, userSnap) {
        final nama = ((userSnap.data?['nama'] as String?) ?? '').trim();

        return HeaderPage(
          title: nama.isEmpty ? 'Welcome' : 'Welcome, $nama',
          subtitle: 'NutriCount • pantau kalori harianmu',
          icon: Icons.eco, // logo daun NutriCount
          child: StreamBuilder<List<BmiRecord>>(
            stream: _bmiStream,
            builder: (context, bmiSnap) {
              final records = bmiSnap.data ?? [];
              final latest = records.isEmpty ? null : records.first;

              return StreamBuilder<List<FoodLog>>(
                stream: _logStream,
                builder: (context, logSnap) {
                  final logs = logSnap.data ?? [];
                  final konsumsi = logs.fold<int>(0, (a, b) => a + b.total);
                  final target = latest?.kalori.round();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      _barisTanggal(),
                      const SizedBox(height: 8),
                      _KalorGauge(target: target, konsumsi: konsumsi),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _kotakInfo(
                              'Skor BMI',
                              latest == null ? '-' : BmiUtils.fmt1(latest.bmi),
                              latest == null
                                  ? AppColors.fieldGrey
                                  : BmiUtils.warna(latest.kategori)
                                  .withValues(alpha: 0.6),
                              sub: latest?.kategori,
                            ),
                          ),
                          const SizedBox(width: 14), // jarak antar kotak
                          Expanded(
                            child: _kotakInfo(
                              'Goal',
                              target == null ? '-' : '$target kkal',
                              AppColors.sageLight.withValues(alpha: 0.6),
                              sub: 'Dimakan: $konsumsi kkal',
                            ),
                          ),
                        ],
                      ),
                      if (latest == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Text(
                              'Hitung BMI di tab "BMI" lalu simpan untuk melihat target kalori harianmu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textHint)),
                        ),
                      const SizedBox(height: 24),
                      for (final w in _waktuMakan)
                        _mealCard(
                          w,
                          logs.where((l) => l.waktu == w).toList(),
                          latest?.kategori,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ---------- Pemilih tanggal: < Hari ini, 22 Nov > ----------
  Widget _barisTanggal() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _offset > -_batasHari ? () => _geser(-1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pilihTanggal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.sageDark),
                    const SizedBox(width: 8),
                    Text(_labelTanggal(), style: serif(size: AppText.subtitle)),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: _offset < _batasHari ? () => _geser(1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (_offset != 0)
          TextButton(
            onPressed: () => _geser(-_offset),
            child: const Text('Kembali ke hari ini',
                style: TextStyle(color: AppColors.sageDark)),
          ),
      ],
    );
  }

  Widget _kotakInfo(String label, String value, Color warna, {String? sub}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: warna, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: AppText.small,
                  color: AppColors.textDark.withValues(alpha: 0.75))),
          const SizedBox(height: 2),
          Text(value, style: serif(size: AppText.subtitle)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: AppText.caption,
                    color: AppColors.textDark.withValues(alpha: 0.7))),
          ],
        ],
      ),
    );
  }

  // ---------- Kartu waktu makan (Sarapan / Lunch / Dinner / Snack) ----------
  Widget _mealCard(String waktu, List<FoodLog> items, String? bmiKategori) {
    final subtotal = items.fold<int>(0, (a, b) => a + b.total);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sageLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: AppColors.sageLight.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(_ikonWaktu[waktu], color: AppColors.sageDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(waktu, style: serif(size: AppText.subtitle)),
                      if (items.isNotEmpty)
                        Text('$subtotal kkal',
                            style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: AppText.small)),
                    ],
                  ),
                ),
                AddCircleButton(
                  onTap: () => showPilihMakananSheet(
                    context,
                    waktu: waktu,
                    bmiKategori: bmiKategori,
                    tanggal: _tanggal,
                    sudahAda: items,
                  ),
                ),
              ],
            ),
          ),
          for (final f in items) _itemRow(f, waktu),
        ],
      ),
    );
  }

  // ---------- Satu makanan: gambar, nama, kkal, - jumlah +, hapus ----------
  Widget _itemRow(FoodLog f, String waktu) {
    final bisaEdit = _bisaDiedit(f);

    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: AppColors.sageLight.withValues(alpha: 0.6))),
      ),
      child: InkWell(
        onTap: bisaEdit
            ? () => showFoodDialog(context,
            waktu: waktu, existing: f, tanggal: _tanggal)
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              FoodThumb(nama: f.nama, foto: f.foto, size: 52),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                        f.jumlah > 1
                            ? '${f.total} kkal  (${f.kalori} × ${f.jumlah})'
                            : '${f.kalori} kkal',
                        style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: AppText.small)),
                  ],
                ),
              ),
              _tombolJumlah(Icons.remove,
                  f.jumlah > 1 ? () => _fs.updateFoodJumlah(f.id, f.jumlah - 1) : null),
              SizedBox(
                width: 28,
                child: Text('${f.jumlah}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              _tombolJumlah(Icons.add,
                  f.jumlah < 99 ? () => _fs.updateFoodJumlah(f.id, f.jumlah + 1) : null),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline,
                    size: 22, color: AppColors.textHint),
                onPressed: () => _fs.deleteFood(f.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tombolJumlah(IconData ikon, VoidCallback? onTap) {
    final aktif = onTap != null;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: aktif ? AppColors.sageDark : AppColors.fieldGrey,
              width: 1.5),
        ),
        child: Icon(ikon,
            size: 16,
            color: aktif ? AppColors.sageDark : AppColors.fieldGrey),
      ),
    );
  }
}

/// Setengah lingkaran kalori: warna terisi dari kiri ke kanan.
///  - kuning: masih kurang dari goal
///  - hijau : sudah pas / mendekati goal
///  - merah : kelebihan kalori
class _KalorGauge extends StatelessWidget {
  final int? target;
  final int konsumsi;

  const _KalorGauge({required this.target, required this.konsumsi});

  static const _merah = Color(0xFFE57373);
  static const _kuning = Color(0xFFF2C94C);
  static const _hijau = Color(0xFF7BC47F);

  /// Batas rasio kalori dimakan / goal. Ubah sesuai kebutuhan.
  static const _batasPas = 0.85; // di bawah ini = kurang (kuning)
  static const _batasLebih = 1.05; // di atas ini = kelebihan (merah)

  @override
  Widget build(BuildContext context) {
    final ada = target != null && target! > 0;
    final rasio = ada ? konsumsi / target! : 0.0;

    Color warna;
    String status;
    if (!ada) {
      warna = AppColors.fieldGrey;
      status = 'Hitung BMI dulu untuk melihat target';
    } else if (rasio > _batasLebih) {
      warna = _merah;
      status = 'Kelebihan kalori';
    } else if (rasio >= _batasPas) {
      warna = _hijau;
      status = 'Sudah pas, mendekati goal';
    } else {
      warna = _kuning;
      status = 'Masih kurang dari goal';
    }

    final sisa = ada ? target! - konsumsi : null;
    final progress = ada ? (rasio > 1 ? 1.0 : rasio) : 0.0;

    return LayoutBuilder(builder: (context, box) {
      final w = math.min(box.maxWidth, 340.0);
      final h = w / 2 + 14;
      return Column(
        children: [
          SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, nilai, __) => CustomPaint(
                        painter: _GaugePainter(progress: nilai, color: warna)),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(sisa != null && sisa < 0 ? 'Lebih' : 'Sisa',
                          style: serif(
                              size: AppText.body, weight: FontWeight.w400)),
                      Text(sisa == null ? '-' : '${sisa.abs()}',
                          style: serif(size: 38)),
                      const Text('kkal',
                          style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: AppText.small)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(20)),
            child: Text(status,
                style: const TextStyle(
                    fontSize: AppText.small, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    });
  }
}

class _GaugePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  const _GaugePainter({required this.progress, required this.color});

  static const _tebal = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Lingkaran penuh; hanya setengah atasnya yang digambar.
    final rect = Rect.fromLTWH(
        _tebal / 2, _tebal / 2, size.width - _tebal, size.width - _tebal);

    final jalur = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _tebal
      ..strokeCap = StrokeCap.round
      ..color = AppColors.fieldGrey;
    canvas.drawArc(rect, math.pi, math.pi, false, jalur);

    if (progress > 0) {
      final isi = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _tebal
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, math.pi, math.pi * progress, false, isi);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}