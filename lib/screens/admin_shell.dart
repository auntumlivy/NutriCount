import 'package:flutter/material.dart';
import 'admin_account_screen.dart';
import 'admin_home_screen.dart';
import 'admin_recipes_screen.dart';

/// Kerangka halaman admin (beranda, kelola resep, akun).
/// Terpisah dari MainShell milik pengguna.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          AdminHomeScreen(onLihatSemua: () => setState(() => _index = 1)),
          const AdminRecipesScreen(),
          const AdminAccountScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Resep'),
          NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: 'Akun'),
        ],
      ),
    );
  }
}
