import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/local_service.dart';
import '../theme.dart';
import '../widgets/app_widgets.dart';
import 'admin_shell.dart';
import 'main_shell.dart';

/// Dipakai saat Firebase BELUM tersambung: pilih masuk sebagai pengguna atau
/// admin untuk mencoba kedua tampilan. Data hanya di memori.
class DemoGate extends StatelessWidget {
  const DemoGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: LocalService.peran,
      builder: (context, peran, _) {
        if (peran == 'admin') return const AdminShell();
        if (peran == 'user') return const MainShell();
        return const _PilihPeran();
      },
    );
  }
}

class _PilihPeran extends StatelessWidget {
  const _PilihPeran();

  void _masuk(String role) =>
      (DataService.instance as LocalService).masukSebagai(role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                      color: AppColors.sageLight,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.eco, color: Colors.white, size: 76),
                ),
                const SizedBox(height: 28),
                Text('NutriCount', style: serif(size: AppText.hero)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.overweight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text(
                      'Mode demo: Firebase belum tersambung, data hanya tersimpan sementara. Pilih peran untuk mencoba.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: AppText.small)),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                    label: 'Masuk sebagai Pengguna',
                    onPressed: () => _masuk('user')),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.sageDark),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _masuk('admin'),
                    child: const Text('Masuk sebagai Admin',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: AppText.body)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
