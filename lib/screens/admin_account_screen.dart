import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';

/// Akun admin: info singkat + keluar.
class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final _fs = DataService.instance;
  late final Stream<Map<String, dynamic>?> _userS = _fs.userStream();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _userS,
        builder: (context, snap) {
          final nama = ((snap.data?['nama'] ?? '') as String).trim();
          final email = ((snap.data?['email'] ?? '') as String).trim();
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [AppColors.sageDark, AppColors.sage],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(nama.isEmpty ? 'Admin' : nama,
                  textAlign: TextAlign.center,
                  style: serif(size: AppText.title)),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textHint)),
              ],
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('ADMIN',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppText.small,
                          letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.fieldGrey,
                    borderRadius: BorderRadius.circular(14)),
                child: const Text(
                    'Role admin diatur di Firebase Console (koleksi users, field role). '
                    'Hanya akun dengan role "admin" yang bisa membuka halaman ini.',
                    style: TextStyle(
                        color: AppColors.textHint, fontSize: AppText.small)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: Colors.black, width: 0.8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _fs.keluar(),
                  child: const Text('Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppText.body)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
