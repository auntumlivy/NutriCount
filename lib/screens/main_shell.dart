import 'package:flutter/material.dart';
import 'bmi_calculator_screen.dart';
import 'food_recommendation_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    BmiCalculatorScreen(),
    FoodRecommendationScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.monitor_weight_outlined),
              selectedIcon: Icon(Icons.monitor_weight),
              label: 'BMI'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Makanan'),
          NavigationDestination(
              icon: Icon(Icons.show_chart),
              selectedIcon: Icon(Icons.show_chart),
              label: 'Riwayat'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}
