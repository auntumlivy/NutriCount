import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/app_widgets.dart';
import '../widgets/food_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _waktuMakan = ['Sarapan', 'Lunch', 'Dinner', 'Snack'];

  final _fs = DataService.instance;
  late final Stream<List<BmiRecord>> _bmiStream = _fs.bmiStream();
  late final Stream<List<FoodLog>> _logStream =
      _fs.foodsByDay(BmiUtils.dayKey(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<BmiRecord>>(
        stream: _bmiStream,
        builder: (context, bmiSnap) {
          final records = bmiSnap.data ?? [];
          final latest = records.isEmpty ? null : records.first;

          return StreamBuilder<List<FoodLog>>(
            stream: _logStream,
            builder: (context, logSnap) {
              final logs = logSnap.data ?? [];
              final consumed = logs.fold<int>(0, (a, b) => a + b.kalori);
              final target = latest?.kalori.round();
              final sisa = target == null ? null : target - consumed;

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Text('NutriCount', style: serif(size: AppText.title)),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text('Skor BMI', style: serif(size: AppText.subtitle)),
                        const SizedBox(height: 8),
                        StatCircle(
                          value:
                              latest == null ? '-' : BmiUtils.fmt1(latest.bmi),
                          size: 124,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Kalori', style: serif(size: AppText.subtitle)),
                          const SizedBox(height: 8),
                          StatCircle(
                              value: target == null ? '-' : '$target',
                              size: 124),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Sisa', style: serif(size: AppText.subtitle)),
                          const SizedBox(height: 8),
                          StatCircle(
                            value: sisa == null ? '-' : '${sisa.abs()}',
                            sub: sisa == null
                                ? null
                                : (sisa >= 0 ? 'LEFT' : 'OVER'),
                            size: 124,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (latest == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                          'Hitung BMI di tab "BMI" lalu simpan untuk melihat target kalori harianmu.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textHint)),
                    ),
                  const SizedBox(height: 32),
                  for (final w in _waktuMakan)
                    _mealSection(w, logs.where((l) => l.waktu == w).toList()),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _mealSection(String waktu, List<FoodLog> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(waktu, style: serif(size: AppText.subtitle))),
              AddCircleButton(
                  onTap: () => showPilihMakananSheet(context, waktu: waktu)),
            ],
          ),
          for (final f in items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(f.nama),
              subtitle: Text('${f.kalori} kkal'),
              onTap: () => showFoodDialog(context, waktu: waktu, existing: f),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.textHint),
                onPressed: () => _fs.deleteFood(f.id),
              ),
            ),
        ],
      ),
    );
  }
}
