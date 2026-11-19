import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'rrgumdv2';
  static const String uploadPreset = 'nutricount_unsigned';

  /// Unggah gambar ke Cloudinary, mengembalikan URL https.
  static Future<String> uploadImage(XFile image, {String? folder}) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final bytes = await image.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: image.name),
      );
    if (folder != null) request.fields['folder'] = folder;

    final response = await request.send().timeout(const Duration(seconds: 40));
    final body = await response.stream.bytesToString();

    Map<String, dynamic> data;
    try {
      data = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Respons Cloudinary tidak valid (${response.statusCode})');
    }

    if (response.statusCode == 200 && data['secure_url'] != null) {
      return data['secure_url'] as String;
    }
    throw Exception(data['error']?['message'] ?? 'Gagal mengunggah gambar');
  }

  /// Versi ringan dari URL Cloudinary (otomatis diperkecil, dikompres, dan
  /// diubah ke format terbaik). Dipakai untuk menampilkan di daftar.
  static String thumb(String url, {int width = 400}) {
    if (!url.contains('/upload/')) return url;
    return url.replaceFirst(
        '/upload/', '/upload/w_$width,c_fill,q_auto,f_auto/');
  }

  /// URL foto makanan rekomendasi berdasarkan namanya.
  /// Contoh: "Dada Ayam Rebus" -> nutricount/foods/dada-ayam-rebus
  static String fotoMakanan(String nama, {int width = 400}) {
    final slug = nama
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'https://res.cloudinary.com/$cloudName/image/upload/'
        'w_$width,c_fill,q_auto,f_auto/nutricount/foods/$slug';
  }
}