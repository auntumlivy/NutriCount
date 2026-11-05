import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import '../widgets/bmi_indicator.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _fs = DataService.instance;
  late final Stream<List<BmiRecord>> _bmiS = _fs.bmiStream();
  late final Stream<Map<String, dynamic>?> _userS = _fs.userStream();
  late final Stream<List<FoodLog>> _logS =
      _fs.foodsSince(DateTime.now().subtract(const Duration(days: 6)));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<BmiRecord>>(
        stream: _bmiS,
        builder: (context, bmiSnap) {
          final records = bmiSnap.data ?? [];
          final latest = records.isEmpty ? null : records.first;
          return StreamBuilder<Map<String, dynamic>?>(
            stream: _userS,
            builder: (context, userSnap) {
              final target = (userSnap.data?['targetBerat'] as num?)?.toDouble();
              return StreamBuilder<List<FoodLog>>(
                stream: _logS,
                builder: (context, logSnap) {
                  final logs = logSnap.data ?? [];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    children: [
                      Text('Riwayat BMI', style: serif(size: AppText.title)),
                      const SizedBox(height: 22),
                      _beratCard(latest, target),
                      const SizedBox(height: 18),
                      _bmiCard(latest),
                      const SizedBox(height: 22),
                      Text('Calories', style: serif(size: AppText.section)),
                      const SizedBox(height: 12),
                      _chart(logs, latest?.kalori),
                      const SizedBox(height: 24),
                      Text('Catatan BMI', style: serif(size: AppText.section)),
                      const SizedBox(height: 8),
                      if (records.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Belum ada riwayat BMI.',
                              style: TextStyle(color: AppColors.textHint)),
                        ),
                      for (final r in records) _recordTile(r),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ---------- Kartu berat badan + tombol edit (Update) ----------
  Widget _beratCard(BmiRecord? latest, double? target) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.textDark, width: 0.8),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Berat Badan', style: serif(size: AppText.body)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        latest == null
                            ? '- kg'
                            : '${BmiUtils.fmtKg(latest.berat)} kg',
                        style: const TextStyle(
                            fontSize: AppText.title, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        target == null
                            ? 'Target - kg'
                            : 'Target ${BmiUtils.fmtKg(target)} kg',
                        style: const TextStyle(
                            fontSize: AppText.title, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _editBerat(latest, target),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_note,
                      color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editBerat(BmiRecord? latest, double? target) async {
    final b = TextEditingController(
        text: latest == null ? '' : BmiUtils.fmtKg(latest.berat));
    final t = TextEditingController(
        text: target == null ? '' : BmiUtils.fmtKg(target));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Ubah berat & target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (latest != null)
              TextField(
                controller: b,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Berat saat ini (kg)'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: t,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Target berat (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textHint))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan',
                  style: TextStyle(
                      color: AppColors.sageDark, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true) return;

    final newB = double.tryParse(b.text.trim().replaceAll(',', '.'));
    final newT = double.tryParse(t.text.trim().replaceAll(',', '.'));
    if (latest != null && newB != null && newB > 0) {
      final bmi = BmiUtils.hitungBmi(newB, latest.tinggi);
      await _fs.updateBmi(latest.id,
          {'berat': newB, 'bmi': bmi, 'kategori': BmiUtils.kategori(bmi)});
    }
    if (newT != null && newT > 0) {
      await _fs.updateUser({'targetBerat': newT});
    }
  }

  // ---------- Kartu BMI ----------
  Widget _bmiCard(BmiRecord? latest) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.textDark, width: 0.8),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BMI', style: serif(size: AppText.subtitle)),
          const SizedBox(height: 10),
          BmiIndicator(bmi: latest?.bmi),
        ],
      ),
    );
  }

  // ---------- Grafik kalori 7 hari ----------
  Widget _chart(List<FoodLog> logs, double? target) {
    final now = DateTime.now();
    final days = List.generate(
        7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));
    final totals = <String, int>{};
    for (final l in logs) {
      totals[l.hari] = (totals[l.hari] ?? 0) + l.kalori;
    }
    final spots = [
      for (var i = 0; i < 7; i++)
        FlSpot(i.toDouble(), (totals[BmiUtils.dayKey(days[i])] ?? 0).toDouble())
    ];
    final maxVal = spots.map((s) => s.y).fold<double>(0, (a, b) => a > b ? a : b);
    final top = [maxVal, target ?? 0, 1000.0].reduce((a, b) => a > b ? a : b);
    final maxY = (top * 1.2 / 500).ceil() * 500.0;

    return SizedBox(
      height: 230,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 8),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            minX: 0,
            maxX: 6,
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(color: AppColors.textDark, width: 2),
                bottom: BorderSide(color: AppColors.textDark, width: 2),
              ),
            ),
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: 500,
                  getTitlesWidget: (v, m) => Text(v.toInt().toString(),
                      style: serif(size: AppText.caption, weight: FontWeight.w400)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i > 6) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${days[i].day}/${days[i].month}',
                          style: const TextStyle(fontSize: AppText.caption)),
                    );
                  },
                ),
              ),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: [
              if (target != null)
                HorizontalLine(
                  y: target,
                  color: AppColors.textDark,
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topCenter,
                    labelResolver: (_) => 'Target',
                    style: serif(size: AppText.caption, weight: FontWeight.w400),
                  ),
                ),
            ]),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: AppColors.sageDark,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                    show: true, color: AppColors.sageLight.withOpacity(0.35)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Daftar riwayat + hapus (Delete) ----------
  Widget _recordTile(BmiRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      decoration: BoxDecoration(
          color: BmiUtils.warna(r.kategori).withOpacity(0.35),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BMI ${BmiUtils.fmt1(r.bmi)} • ${r.kategori}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: AppText.body)),
                Text(
                    '${BmiUtils.fmtTanggal(r.tanggal)} • ${BmiUtils.fmtKg(r.berat)} kg • ${BmiUtils.fmtKg(r.tinggi)} cm',
                    style: const TextStyle(color: AppColors.textHint)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _konfirmasiHapus(r),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(BmiRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Hapus catatan?'),
        content: Text('Catatan BMI ${BmiUtils.fmt1(r.bmi)} akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textHint))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await _fs.deleteBmi(r.id);
  }
}
