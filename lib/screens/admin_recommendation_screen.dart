import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class AdminRecommendationScreen extends StatefulWidget {
  const AdminRecommendationScreen({super.key});

  @override
  State<AdminRecommendationScreen> createState() =>
      _AdminRecommendationScreenState();
}


class _AdminRecommendationScreenState
    extends State<AdminRecommendationScreen> {
  final _fs = DataService.instance;

Future<void> _formRekomendasi({FoodRecommendation? data}) async {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController(text: data?.nama ?? '');
  final kaloriController = TextEditingController(
    text: data?.kalori.toString() ?? '',
  );

  String kategori = data?.kategori ?? 'Normal';
  String emoji = data?.emoji ?? '🍽️';
  String foto = data?.foto ?? '';
  XFile? gambar;
  bool loading = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pilihGambar() async {
            final picker = ImagePicker();
            final hasil = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );

            if (hasil != null) {
              setDialogState(() => gambar = hasil);
            }
          }

          Future<void> simpan() async {
            if (!formKey.currentState!.validate()) return;

            setDialogState(() => loading = true);

            try {
              if (gambar != null) {
                foto = await CloudinaryService.uploadImage(gambar!);
              }

              final rekomendasi = FoodRecommendation(
                nama: namaController.text.trim(),
                kalori: int.parse(kaloriController.text.trim()),
                kategori: kategori,
                foto: foto,
                emoji: emoji,
              );

              if (data == null) {
                await _fs.addFoodRecommendation(rekomendasi);
              } else {
                await _fs.updateFoodRecommendation(
                  data.id,
                  rekomendasi,
                );
              }

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(
                    data == null
                        ? 'Rekomendasi berhasil ditambahkan'
                        : 'Rekomendasi berhasil diperbarui',
                  ),
                ),
              );
            } catch (e) {
              setDialogState(() => loading = false);

              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('Gagal menyimpan: $e')),
              );
            }
          }

          return AlertDialog(
            title: Text(
              data == null ? 'Tambah Rekomendasi' : 'Edit Rekomendasi',
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama makanan',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Nama makanan wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: kaloriController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kalori (kkal)',
                        ),
                        validator: (v) {
                          final angka = int.tryParse(v ?? '');
                          if (angka == null || angka <= 0) {
                            return 'Masukkan kalori yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: kategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori BMI',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Underweight',
                            child: Text('Underweight'),
                          ),
                          DropdownMenuItem(
                            value: 'Normal',
                            child: Text('Normal'),
                          ),
                          DropdownMenuItem(
                            value: 'Overweight',
                            child: Text('Overweight'),
                          ),
                          DropdownMenuItem(
                            value: 'Obesitas',
                            child: Text('Obesitas'),
                          ),
                        ],
                        onChanged: loading
                            ? null
                            : (v) {
                                if (v != null) {
                                  setDialogState(() => kategori = v);
                                }
                              },
                      ),
                      const SizedBox(height: 16),
                      if (gambar != null)
                        Text('Foto dipilih: ${gambar!.name}')
                      else if (foto.isNotEmpty)
                        Image.network(
                          foto,
                          height: 100,
                          errorBuilder: (_, error, stack) =>
                              const Icon(Icons.broken_image),
                        ),
                      OutlinedButton.icon(
                        onPressed: loading ? null : pilihGambar,
                        icon: const Icon(Icons.image),
                        label: const Text('Pilih Foto Makanan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: loading ? null : simpan,
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );

  namaController.dispose();
  kaloriController.dispose();
}

  Future<void> _hapusRekomendasi(FoodRecommendation r) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rekomendasi'),
        content: Text('Yakin ingin menghapus ${r.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await _fs.deleteFoodRecommendation(r.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Rekomendasi Makanan'),
        actions: [
          IconButton(
            onPressed: () => _formRekomendasi(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Rekomendasi',
          ),
        ],
      ),
      body: StreamBuilder<List<FoodRecommendation>>(
        stream: _fs.allFoodRecommendationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final rekomendasi = snapshot.data ?? [];

          if (rekomendasi.isEmpty) {
            return const Center(
              child: Text('Belum ada rekomendasi makanan.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rekomendasi.length,
            itemBuilder: (context, index) {
              final r = rekomendasi[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: r.foto.isNotEmpty
                      ? Image.network(
                          r.foto,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.restaurant),
                        )
                      : Text(r.emoji, style: const TextStyle(fontSize: 30)),
                  title: Text(r.nama),
                  subtitle: Text(
                    '${r.kalori} kkal • ${r.kategori}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (aksi) {
                      if (aksi == 'edit') {
                        _formRekomendasi(data: r);
                      } else if (aksi == 'hapus') {
                        _hapusRekomendasi(r);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'hapus',
                        child: Text('Hapus'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}