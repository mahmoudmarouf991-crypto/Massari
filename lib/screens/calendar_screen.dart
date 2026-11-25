import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

const _weekdaysAr = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
const _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

class CalendarScreen extends StatefulWidget {
  final StorageService storage;
  final DateTime today;
  const CalendarScreen({super.key, required this.storage, required this.today});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int year;
  late int month; // 1..12

  @override
  void initState() {
    super.initState();
    year = widget.today.year;
    month = widget.today.month;
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.storage.getAllDays();
    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = (first.weekday % 7 + 1) % 7; // السبت = 0

    int complete = 0;
    int weak = 0;

    final cells = <Widget>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final key = dateKey(date);
      final r = all[key];
      final score = r?.score;
      Color bg = AppColors.surface2;
      Color fg = AppColors.muted;
      if (score != null) {
        if (score >= 0.85) {
          bg = AppColors.green;
          fg = Colors.white;
          complete++;
        } else if (score >= 0.55) {
          bg = AppColors.blue;
          fg = Colors.white;
        } else {
          bg = AppColors.amber;
          fg = Colors.white;
          weak++;
        }
      }
      final isToday = year == widget.today.year &&
          month == widget.today.month &&
          d == widget.today.day;
      cells.add(Container(
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isToday ? AppColors.navy : AppColors.line,
              width: isToday ? 2 : 1),
        ),
        child: Text('$d',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(() {
                        month--;
                        if (month < 1) {
                          month = 12;
                          year--;
                        }
                      }),
                    ),
                    Text('${_monthsAr[month - 1]} $year',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(() {
                        month++;
                        if (month > 12) {
                          month = 1;
                          year++;
                        }
                      }),
                    ),
                  ],
                ),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  childAspectRatio: 1.6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _weekdaysAr
                      .map((w) => Center(
                          child: Text(w,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.bold))))
                      .toList(),
                ),
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cells,
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 12,
                  children: [
                    _LegendDot(color: AppColors.green, label: 'ممتاز'),
                    _LegendDot(color: AppColors.blue, label: 'جيد'),
                    _LegendDot(color: AppColors.amber, label: 'ضعيف'),
                    _LegendDot(color: AppColors.surface2, label: 'لم يكتمل'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _monthStat('$complete', 'يوم مكتمل')),
            const SizedBox(width: 10),
            Expanded(child: _monthStat('$weak', 'أيام تحتاج اهتمام')),
          ],
        ),
      ],
    );
  }

  Widget _monthStat(String value, String label) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
