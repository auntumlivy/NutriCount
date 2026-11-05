import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import 'app_widgets.dart';

/// Bar kategori BMI: underweight | Normal | overweight | obesitas
/// dengan penanda posisi nilai BMI.
class BmiIndicator extends StatelessWidget {
  final double? bmi;
  const BmiIndicator({super.key, this.bmi});

  static const _flex = [85, 65, 50, 100]; // skala BMI 10 - 40
  static const _names = ['underweight', 'Normal', 'overweight', 'obesitas'];
  static const _colors = [
    AppColors.underweight,
    AppColors.normal,
    AppColors.overweight,
    AppColors.obesitas
  ];

  List<Widget> _row(Widget Function(int) build, Widget divider) {
    final out = <Widget>[];
    for (var i = 0; i < 4; i++) {
      if (i > 0) out.add(divider);
      out.add(Expanded(flex: _flex[i], child: build(i)));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final kat = bmi == null ? null : BmiUtils.kategori(bmi!);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _row(
            (i) {
              final aktif = kat != null &&
                  kat.toLowerCase() == _names[i].toLowerCase();
              return Text(_names[i],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  // Ukuran sama untuk semua label; kategori aktif dibedakan
                  // lewat ketebalan dan warna, bukan ukuran.
                  style: serif(
                      size: AppText.caption,
                      weight: aktif ? FontWeight.w700 : FontWeight.w400,
                      color: aktif ? AppColors.textDark : AppColors.textHint));
            },
            const SizedBox(width: 4),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth;
          final pos = bmi == null ? null : ((bmi!.clamp(10, 40) - 10) / 30) * w;
          return SizedBox(
            height: 34,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: _row(
                        (i) => Container(color: _colors[i].withOpacity(0.7)),
                        Container(width: 4, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                if (pos != null)
                  Positioned(
                    left: pos - 9,
                    top: 5,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.textDark, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        if (bmi != null) ...[
          const SizedBox(height: 8),
          Text('BMI ${BmiUtils.fmt1(bmi!)} • $kat',
              style: serif(size: AppText.small, weight: FontWeight.w400)),
        ],
      ],
    );
  }
}
