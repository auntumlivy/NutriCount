import 'dart:async';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import '../widgets/bmi_indicator.dart';
import 'food_recommendation_screen.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final _fs = DataService.instance;
  final _usia = TextEditingController();
  final _tinggi = TextEditingController();
  final _berat = TextEditingController();

  bool _pria = true;
  bool _saving = false;
  TingkatAktivitas _aktivitas = TingkatAktivitas.ringan;
  TujuanKalori _tujuan = TujuanKalori.mempertahankan;

  // hasil perhitungan
  double? _bmi;
  String? _kategori;
  double? _kalori;
  (double, double)? _ideal;
  BmiRecord? _hasil;

  @override
  void initState() {
    super.initState();
    _muatTerakhir();
  }

  /// Isi kembali isian + hasil dari perhitungan terakhir (tersimpan per akun).
  /// Kalau belum pernah menghitung, isi usia dari tanggal lahir profil.
  Future<void> _muatTerakhir() async {
    final u = await _fs.getUser();
    if (!mounted || u == null) return;

    final k = u['kalkulator'];
    if (k is Map) {
      final usia = (k['usia'] as num?)?.toInt();
      final tinggi = (k['tinggi'] as num?)?.toDouble();
      final berat = (k['berat'] as num?)?.toDouble();
      if (usia != null && tinggi != null && berat != null) {
        _usia.text = '$usia';
        _tinggi.text = BmiUtils.fmtKg(tinggi);
        _berat.text = BmiUtils.fmtKg(berat);
        setState(() {
          _pria = k['pria'] != false;
          _aktivitas = TingkatAktivitas.values.firstWhere(
                  (e) => e.name == k['aktivitas'],
              orElse: () => TingkatAktivitas.ringan);
          _tujuan = TujuanKalori.values.firstWhere(
                  (e) => e.name == k['tujuan'],
              orElse: () => TujuanKalori.mempertahankan);
        });
        _terapkan(usia, tinggi, berat);
        return;
      }
    }

    final dob = u['tglLahir'] as String?;
    final usia =
    (dob == null || dob.isEmpty) ? null : BmiUtils.usiaDariTanggal(dob);
    if (usia != null && _usia.text.isEmpty) _usia.text = '$usia';
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  /// Hitung BMI, kategori, kalori, dan berat ideal, lalu tampilkan hasilnya.
  void _terapkan(int usia, double tinggi, double berat) {
    final bmi = BmiUtils.hitungBmi(berat, tinggi);
    final kat = BmiUtils.kategori(bmi);
    final kal = BmiUtils.kaloriHarian(
      berat: berat,
      tinggi: tinggi,
      usia: usia,
      pria: _pria,
      kategori: kat,
      aktivitas: _aktivitas,
      tujuan: _tujuan,
    );
    setState(() {
      _bmi = bmi;
      _kategori = kat;
      _kalori = kal;
      _ideal = BmiUtils.beratIdeal(tinggi);
      _hasil = BmiRecord(
        usia: usia,
        gender: _pria ? 'L' : 'P',
        tinggi: tinggi,
        berat: berat,
        bmi: bmi,
        kategori: kat,
        kalori: kal,
        tanggal: DateTime.now(),
      );
    });
  }

  void _hitung() {
    FocusScope.of(context).unfocus();
    final usia = int.tryParse(_usia.text.trim());
    final tinggi = _num(_tinggi);
    final berat = _num(_berat);
    if (usia == null || usia <= 0 || tinggi == null || tinggi < 50 ||
        tinggi > 250 || berat == null || berat < 10 || berat > 400) {
      _snack('Isi usia, tinggi (cm), dan berat (kg) dengan benar.');
      return;
    }
    _terapkan(usia, tinggi, berat);

    // Simpan isian terakhir supaya tetap ada setelah logout dan login lagi.
    unawaited(_fs.updateUser({
      'kalkulator': {
        'usia': usia,
        'tinggi': tinggi,
        'berat': berat,
        'pria': _pria,
        'aktivitas': _aktivitas.name,
        'tujuan': _tujuan.name,
      },
    }).catchError((_) {}));
  }

  Future<void> _simpan() async {
    if (_hasil == null) {
      _snack('Tekan "Hitung" terlebih dahulu.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _fs.addBmi(_hasil!);
      _snack('Hasil BMI tersimpan.');
    } catch (e) {
      _snack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _usia.dispose();
    _tinggi.dispose();
    _berat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foods = _kategori == null ? null : BmiUtils.makananUntuk(_kategori!);

    return HeaderPage(
      title: 'BMI',
      subtitle: 'Hitung indeks massa tubuhmu',
      icon: Icons.monitor_weight_outlined,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _field('Usia', _usia, TextInputType.number)),
                const SizedBox(width: 24),
                _genderAvatar(true),
                const SizedBox(width: 10),
                _genderAvatar(false),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: _field('Tinggi (cm)', _tinggi,
                        const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 24),
                Expanded(
                    child: _field('Berat (kg)', _berat,
                        const TextInputType.numberWithOptions(decimal: true))),
              ],
            ),

            const SizedBox(height: 22),

            // Pilihan tingkat aktivitas
            Text('Tingkat Aktivitas', style: serif(size: AppText.body)),
            const SizedBox(height: 8),
            DropdownButtonFormField<TingkatAktivitas>(
              value: _aktivitas,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(
                  value: TingkatAktivitas.sedentari,
                  child: Text('Jarang beraktivitas'),
                ),
                DropdownMenuItem(
                  value: TingkatAktivitas.ringan,
                  child: Text('Aktivitas ringan (1–3 hari/minggu)'),
                ),
                DropdownMenuItem(
                  value: TingkatAktivitas.sedang,
                  child: Text('Aktivitas sedang (3–5 hari/minggu)'),
                ),
                DropdownMenuItem(
                  value: TingkatAktivitas.berat,
                  child: Text('Aktivitas berat (6–7 hari/minggu)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _aktivitas = value;
                  });
                }
              },
            ),

            const SizedBox(height: 18),

            // Pilihan tujuan kalori
            Text('Tujuan Kalori', style: serif(size: AppText.body)),
            const SizedBox(height: 8),
            DropdownButtonFormField<TujuanKalori>(
              value: _tujuan,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(
                  value: TujuanKalori.menurunkan,
                  child: Text('Menurunkan berat badan'),
                ),
                DropdownMenuItem(
                  value: TujuanKalori.mempertahankan,
                  child: Text('Mempertahankan berat badan'),
                ),
                DropdownMenuItem(
                  value: TujuanKalori.menaikkan,
                  child: Text('Menaikkan berat badan'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tujuan = value;
                  });
                }
              },
            ),

            const SizedBox(height: 22),

            Center(
              child: SizedBox(
                width: 140,
                height: 46,
                child: ElevatedButton(
                  onPressed: _hitung,
                  child: const Text('Hitung'),
                ),
              ),
            ),

            const SizedBox(height: 28),
            BmiIndicator(bmi: _bmi),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 140,
                height: 46,
                child: ElevatedButton(
                  onPressed: _saving ? null : _simpan,
                  child: _saving
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                      : const Text('Simpan'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _readonlyRow(
                'Rekomendasi Berat',
                _ideal == null
                    ? ''
                    : '${BmiUtils.fmtKg(_ideal!.$1.roundToDouble())}-${BmiUtils.fmtKg(_ideal!.$2.roundToDouble())} kg'),
            const SizedBox(height: 14),
            _readonlyRow('Rekomendasi Kalori',
                _kalori == null ? '' : '${_kalori!.round()} kkal'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: Text('Rekomendasi Makanan',
                        style: serif(size: AppText.body))),
                if (_kategori != null)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FoodRecommendationScreen(
                            kategori: _kategori!,
                            targetKalori: _kalori,
                          )),
                    ),
                    child: Text('More>',
                        style: serif(size: AppText.body).copyWith(
                            decoration: TextDecoration.underline)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (foods == null)
              const Text('Tekan "Hitung" untuk melihat rekomendasi makanan.',
                  style: TextStyle(color: AppColors.textHint))
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final f in foods.take(3))
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 160, // tinggi pasti supaya Expanded di dalam kartu bisa dihitung
                          child: FoodCard(nama: f.nama, emoji: f.emoji, size: 92),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: serif(size: AppText.body)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: type,
          decoration: const InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
        ),
      ],
    );
  }

  Widget _genderAvatar(bool pria) {
    final selected = _pria == pria;

    // Warna pastel: biru lembut untuk pria, pink lembut untuk wanita
    final bg = pria ? const Color(0xFFCFE3F3) : const Color(0xFFF8D7E3);
    final fg = pria ? const Color(0xFF6A9BC3) : const Color(0xFFD98BAA);

    return GestureDetector(
      onTap: () => setState(() => _pria = pria),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          // yang tidak dipilih dibuat lebih pudar
          color: selected ? bg : bg.withOpacity(0.45),
          borderRadius: BorderRadius.circular(16), // kotak dengan ujung membulat
          border: Border.all(
            color: selected ? fg : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          pria ? Icons.man : Icons.woman,
          color: selected ? fg : fg.withOpacity(0.6),
          size: 36,
        ),
      ),
    );
  }

  Widget _readonlyRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: serif(size: AppText.body))),
        Container(
          width: 140,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.fieldGrey,
              borderRadius: BorderRadius.circular(10)),
          child: Text(value, style: const TextStyle(fontSize: AppText.body)),
        ),
      ],
    );
  }
}