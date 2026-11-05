import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import 'app_widgets.dart';

/// Dialog isi manual: tambah (Create) atau ubah (Update) catatan makanan.
/// [simpanKeDaftar] = true -> makanan juga disimpan ke daftar pilihan pribadi.
/// Mengembalikan true jika tersimpan.
Future<bool> showFoodDialog(
  BuildContext context, {
  required String waktu,
  FoodLog? existing,
  String? namaAwal,
  bool simpanKeDaftar = false,
}) async {
  final nama = TextEditingController(text: existing?.nama ?? namaAwal ?? '');
  final kal = TextEditingController(text: existing?.kalori.toString() ?? '');
  final fs = DataService.instance;

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
              decoration: const InputDecoration(hintText: 'Kalori (kkal)')),
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
              final now = DateTime.now();
              if (simpanKeDaftar) {
                unawaited(
                    fs.addCustomFood(nama.text.trim(), k).catchError((_) {}));
              }
              unawaited(fs
                  .addFood(FoodLog(
                    nama: nama.text.trim(),
                    kalori: k,
                    waktu: waktu,
                    hari: BmiUtils.dayKey(now),
                    tanggal: now,
                  ))
                  .catchError((_) {}));
            } else {
              unawaited(
                  fs.updateFood(existing.id, nama.text.trim(), k).catchError((_) {}));
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

/// Bottom sheet daftar makanan: pilih salah satu, atau tambah makanan sendiri.
Future<void> showPilihMakananSheet(BuildContext context,
    {required String waktu}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => _PilihMakananSheet(waktu: waktu),
  );
}

class _PilihMakananSheet extends StatefulWidget {
  final String waktu;
  const _PilihMakananSheet({required this.waktu});

  @override
  State<_PilihMakananSheet> createState() => _PilihMakananSheetState();
}

class _PilihMakananSheetState extends State<_PilihMakananSheet> {
  final _fs = DataService.instance;
  final _cari = TextEditingController();
  late final Stream<List<FoodItem>> _customS = _fs.customFoodsStream();
  final _katalog = BmiUtils.katalog;
  String _q = '';

  void _catat(FoodItem f) {
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    unawaited(_fs
        .addFood(FoodLog(
          nama: f.nama,
          kalori: f.kalori,
          waktu: widget.waktu,
          hari: BmiUtils.dayKey(now),
          tanggal: now,
        ))
        .catchError((_) {}));
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
        content: Text('${f.nama} ditambahkan ke ${widget.waktu}.'),
        duration: const Duration(seconds: 2)));
  }

  Future<void> _tambahSendiri() async {
    final ok = await showFoodDialog(context,
        waktu: widget.waktu,
        namaAwal: _cari.text.trim(),
        simpanKeDaftar: true);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final tinggi =
        math.min(mq.size.height * 0.85, mq.size.height - mq.viewInsets.bottom - 60);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SizedBox(
        height: tinggi,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: StreamBuilder<List<FoodItem>>(
            stream: _customS,
            builder: (context, snap) {
              final custom = snap.data ?? [];
              final q = _q.toLowerCase();
              bool cocok(FoodItem f) => f.nama.toLowerCase().contains(q);
              final tampil = [
                ...custom.where(cocok),
                ..._katalog.where(cocok),
              ];

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
                  const SizedBox(height: 8),
                  Expanded(
                    child: tampil.isEmpty
                        ? Center(
                            child: Text(
                                'Makanan tidak ditemukan.\nTambahkan sendiri di bawah.',
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: AppColors.textHint)),
                          )
                        : ListView.builder(
                            itemCount: tampil.length,
                            itemBuilder: (_, i) {
                              final f = tampil[i];
                              final milikSendiri = f.id != null;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Text(f.emoji,
                                    style: const TextStyle(fontSize: AppText.display)),
                                title: Text(f.nama),
                                subtitle: Text(
                                    '±${f.kalori} kkal${milikSendiri ? ' • buatanmu' : ''}'),
                                onTap: () => _catat(f),
                                trailing: milikSendiri
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppColors.textHint),
                                        onPressed: () =>
                                            _fs.deleteCustomFood(f.id!),
                                      )
                                    : null,
                              );
                            },
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
          ),
        ),
      ),
    );
  }
}
