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

  // hasil perhitungan
  double? _bmi;
  String? _kategori;
  double? _kalori;
  (double, double)? _ideal;
  BmiRecord? _hasil;

  @override
  void initState() {
    super.initState();
    // Isi usia otomatis dari tanggal lahir profil.
    _fs.getUser().then((u) {
      final dob = u?['tglLahir'] as String?;
      final usia = dob == null ? null : BmiUtils.usiaDariTanggal(dob);
      if (usia != null && mounted && _usia.text.isEmpty) {
        _usia.text = '$usia';
      }
    });
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

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
    final bmi = BmiUtils.hitungBmi(berat, tinggi);
    final kat = BmiUtils.kategori(bmi);
    final kal = BmiUtils.kaloriHarian(
        berat: berat, tinggi: tinggi, usia: usia, pria: _pria, kategori: kat);
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('BMI', style: serif(size: 30))),
            const SizedBox(height: 24),
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
            Center(
              child: SizedBox(
                width: 140,
                height: 46,
                child: ElevatedButton(
                    onPressed: _hitung, child: const Text('Hitung')),
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
                Expanded(child: Text('Rekomendasi Makanan', style: serif(size: 17))),
                if (_kategori != null)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FoodRecommendationScreen(kategori: _kategori!)),
                    ),
                    child: Text('More>',
                        style: serif(size: 16).copyWith(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final f in foods.take(3))
                    FoodCard(nama: f.nama, emoji: f.emoji, size: 92),
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
        Text(label, style: serif(size: 16)),
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
    final color = pria ? const Color(0xFF1E6FE0) : const Color(0xFFEF6FAE);
    return GestureDetector(
      onTap: () => setState(() => _pria = pria),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.18),
          border: Border.all(
              color: selected ? color : Colors.transparent, width: 3),
        ),
        child: Icon(pria ? Icons.man : Icons.woman, color: color, size: 38),
      ),
    );
  }

  Widget _readonlyRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: serif(size: 17))),
        Container(
          width: 140,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.fieldGrey,
              borderRadius: BorderRadius.circular(10)),
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}
