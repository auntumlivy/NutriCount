import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import 'app_widgets.dart';
import 'food_thumb.dart';

/// Gabungkan hari yang dipilih dengan jam sekarang (untuk waktu pencatatan).
DateTime _waktuCatat(DateTime hari) {
  final n = DateTime.now();
  return DateTime(hari.year, hari.month, hari.day, n.hour, n.minute);
}

/// Dialog isi manual: tambah (Create) atau ubah (Update) catatan makanan.
/// [simpanKeDaftar] = true -> makanan juga disimpan ke daftar pilihan pribadi.
/// Mengembalikan true jika tersimpan.
Future<bool> showFoodDialog(
    BuildContext context, {
      required String waktu,
      FoodLog? existing,
      String? namaAwal,
      bool simpanKeDaftar = false,
      DateTime? tanggal,
    }) async {
  final nama = TextEditingController(text: existing?.nama ?? namaAwal ?? '');
  final kal = TextEditingController(text: existing?.kalori.toString() ?? '');
  final fs = DataService.instance;
  final hari = tanggal ?? DateTime.now();

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(existing == null ? 'Tambah makanan ($waktu)' : 'Ubah $waktu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: nama,
              decoration: const InputDecoration(hintText: 'Nama makanan')),
          const SizedBox(height: 12),
          TextField(
              controller: kal,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(hintText: 'Kalori per porsi (kkal)')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textHint))),
        TextButton(
          onPressed: () {
            final k = int.tryParse(kal.text.trim());
            if (nama.text.trim().isEmpty || k == null || k < 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                  content: Text('Isi nama makanan dan kalori dengan benar.')));
              return;
            }
            // Tidak di-await: data langsung tampil dan disinkronkan di latar belakang.
            if (existing == null) {
              if (simpanKeDaftar) {
                unawaited(
                    fs.addCustomFood(nama.text.trim(), k).catchError((_) {}));
              }
              unawaited(fs
                  .addFood(FoodLog(
                nama: nama.text.trim(),
                kalori: k,
                waktu: waktu,
                hari: BmiUtils.dayKey(hari),
                tanggal: _waktuCatat(hari),
              ))
                  .catchError((_) {}));
            } else {
              unawaited(fs
                  .updateFood(existing.id, nama.text.trim(), k)
                  .catchError((_) {}));
            }
            Navigator.pop(ctx, true);
          },
          child: const Text('Simpan',
              style: TextStyle(
                  color: AppColors.sageDark, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Bottom sheet "Pilih makanan": cari, filter (Semua / Rekomendasi / Resep
/// Komunitas), dan tambah makanan sendiri. [sudahAda] = catatan di waktu makan
/// itu, supaya memilih makanan yang sama menambah jumlahnya.
Future<void> showPilihMakananSheet(
    BuildContext context, {
      required String waktu,
      String? bmiKategori,
      DateTime? tanggal,
      List<FoodLog> sudahAda = const [],
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => _PilihMakananSheet(
      waktu: waktu,
      bmiKategori: bmiKategori,
      tanggal: tanggal ?? DateTime.now(),
      sudahAda: sudahAda,
    ),
  );
}

enum _Filter { semua, rekomendasi, resep }

const _namaFilter = {
  _Filter.semua: 'Semua',
  _Filter.rekomendasi: 'Rekomendasi',
  _Filter.resep: 'Resep Komunitas',
};

class _Pilihan {
  final String nama;
  final String emoji;
  final int kalori;
  final String foto;
  final String? idCustom; // terisi untuk makanan buatan sendiri
  final bool resep; // true = dari resep komunitas
  bool get dariAdmin => idCustom == null;

  const _Pilihan({
    required this.nama,
    required this.emoji,
    required this.kalori,
    this.foto = '',
    this.idCustom,
    this.resep = false,
  });
}

class _PilihMakananSheet extends StatefulWidget {
  final String waktu;
  final String? bmiKategori;
  final DateTime tanggal;
  final List<FoodLog> sudahAda;

  const _PilihMakananSheet({
    required this.waktu,
    required this.bmiKategori,
    required this.tanggal,
    required this.sudahAda,
  });

  @override
  State<_PilihMakananSheet> createState() => _PilihMakananSheetState();
}

class _PilihMakananSheetState extends State<_PilihMakananSheet> {
  final _fs = DataService.instance;
  final _cari = TextEditingController();
  late final Stream<List<FoodItem>> _customS = _fs.customFoodsStream();
  late final Stream<List<Recipe>> _resepS = _fs.approvedRecipesStream();
  final _katalog = BmiUtils.katalog;
  String _q = '';
  _Filter _filter = _Filter.semua;

  List<_Pilihan> _susun(List<FoodItem> custom, List<Recipe> resep) {
    final q = _q.toLowerCase();

    final milikku = custom
        .map((f) => _Pilihan(
        nama: f.nama, emoji: f.emoji, kalori: f.kalori, idCustom: f.id))
        .toList();
    final katalog = _katalog
        .map((f) => _Pilihan(nama: f.nama, emoji: f.emoji, kalori: f.kalori))
        .toList();
    final rekom = BmiUtils.makananUntuk(widget.bmiKategori ?? 'Normal')
        .map((f) => _Pilihan(nama: f.nama, emoji: f.emoji, kalori: f.kalori))
        .toList();
    final komunitas = resep
        .map((r) => _Pilihan(
        nama: r.judul,
        emoji: '🍽️',
        kalori: r.kalori,
        foto: r.foto,
        resep: true))
        .toList();

    late final List<_Pilihan> dasar;
    switch (_filter) {
      case _Filter.rekomendasi:
        dasar = rekom;
        break;
      case _Filter.resep:
        dasar = komunitas;
        break;
      case _Filter.semua:
        dasar = [...milikku, ...katalog, ...komunitas];
        break;
    }
    return dasar.where((p) => p.nama.toLowerCase().contains(q)).toList();
  }

  void _catat(_Pilihan p) {
    final messenger = ScaffoldMessenger.of(context);
    final ada = widget.sudahAda.where((f) => f.nama == p.nama).toList();
    if (ada.isNotEmpty) {
      final f = ada.first;
      unawaited(_fs.updateFoodJumlah(f.id, f.jumlah + 1).catchError((_) {}));
    } else {
      unawaited(_fs
          .addFood(FoodLog(
        nama: p.nama,
        kalori: p.kalori,
        foto: p.foto,
        waktu: widget.waktu,
        hari: BmiUtils.dayKey(widget.tanggal),
        tanggal: _waktuCatat(widget.tanggal),
        dariAdmin: p.dariAdmin,
      ))
          .catchError((_) {}));
    }
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
        content: Text('${p.nama} ditambahkan ke ${widget.waktu}.'),
        duration: const Duration(seconds: 2)));
  }

  Future<void> _tambahSendiri() async {
    final ok = await showFoodDialog(context,
        waktu: widget.waktu,
        namaAwal: _cari.text.trim(),
        simpanKeDaftar: true,
        tanggal: widget.tanggal);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  Widget _baris(_Pilihan p) {
    final sub = StringBuffer('±${p.kalori} kkal');
    if (p.resep) sub.write(' • resep komunitas');
    if (p.idCustom != null) sub.write(' • buatanmu');

    return InkWell(
      onTap: () => _catat(p),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            FoodThumb(nama: p.nama, foto: p.foto, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: AppText.body, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(sub.toString(),
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: AppText.small)),
                ],
              ),
            ),
            if (p.idCustom != null)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.textHint),
                onPressed: () => _fs.deleteCustomFood(p.idCustom!),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.add_circle_outline, color: AppColors.sageDark),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final tinggi = math.min(
        mq.size.height * 0.88, mq.size.height - mq.viewInsets.bottom - 60);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SizedBox(
        height: tinggi,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: StreamBuilder<List<FoodItem>>(
            stream: _customS,
            builder: (context, customSnap) {
              return StreamBuilder<List<Recipe>>(
                stream: _resepS,
                builder: (context, resepSnap) {
                  final daftar =
                  _susun(customSnap.data ?? [], resepSnap.data ?? []);

                  return Column(
                    children: [
                      Text('Pilih makanan • ${widget.waktu}',
                          style: serif(size: AppText.subtitle)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cari,
                        onChanged: (v) => setState(() => _q = v.trim()),
                        decoration: const InputDecoration(
                            hintText: 'Cari makanan...',
                            prefixIcon: Icon(Icons.search)),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final f in _Filter.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(_namaFilter[f]!),
                                  selected: _filter == f,
                                  showCheckmark: true,
                                  selectedColor: AppColors.sage,
                                  backgroundColor: AppColors.fieldGrey,
                                  side: BorderSide.none,
                                  onSelected: (_) =>
                                      setState(() => _filter = f),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: daftar.isEmpty
                            ? const Center(
                          child: Text(
                              'Makanan tidak ditemukan.\nTambahkan sendiri di bawah.',
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: AppColors.textHint)),
                        )
                            : ListView.separated(
                          itemCount: daftar.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color:
                              AppColors.sageLight.withOpacity(0.7)),
                          itemBuilder: (_, i) => _baris(daftar[i]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _tambahSendiri,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah makanan sendiri'),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}