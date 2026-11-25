import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  final StorageService storage;
  final DateTime today;
  const ReportsScreen({super.key, required this.storage, required this.today});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final days = _weekDates(widget.today);
    final all = widget.storage.getAllDays();

    double scoreSum = 0;
    int scoreCount = 0;
    double quranJuz = 0;
    int prayDone = 0;
    int studyDays = 0;
    int sportDays = 0;
    int fastDays = 0;
    int goodDays = 0;
    final prayerCounts = <String, Map<String, int>>{
      for (final p in kPrayers) p.key: {'jamaa': 0, 'fardi': 0, 'qada': 0, 'lam': 0}
    };

    for (final d in days) {
      final key = dateKey(d);
      final r = all[key];
      if (r == null) continue;
      final s = r.score;
      if (s != null) {
        scoreSum += s;
        scoreCount++;
      }
      prayDone += r.prayersDoneCount;
      if (r.quran != null) quranJuz += r.quran!.juzValue;
      if (r.rstudy != null) studyDays++;
      if (r.sport > 0) sportDays++;
      if (r.fasting != null) fastDays++;
      if (r.goodDeed != null) goodDays++;
      for (final p in kPrayers) {
        final st = r.prayers[p.key];
        if (st != null) {
          prayerCounts[p.key]![st.name] = (prayerCounts[p.key]![st.name] ?? 0) + 1;
        }
      }
    }
    final pct = scoreCount == 0 ? 0 : ((scoreSum / scoreCount) * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: pct / 100,
                          strokeWidth: 9,
                          backgroundColor: AppColors.line,
                          valueColor: const AlwaysStoppedAnimation(AppColors.green),
                        ),
                      ),
                      Text('$pct%',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('نسبة الالتزام العامة خلال الأسبوع الحالي',
                      style: TextStyle(color: AppColors.inkSoft)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: [
            _statBox('$quranJuz', 'أجزاء · القرآن'),
            _statBox('$prayDone / ${days.length * 5}', 'صلاة · الصلوات'),
            _statBox('$studyDays', 'أيام · دراسة دينية'),
            _statBox('$sportDays', 'أيام · الرياضة'),
            _statBox('$fastDays', 'أيام · الصيام التطوعي'),
            _statBox('$goodDays', 'أيام · عمل الخير'),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('أداء الصلاة هذا الأسبوع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: kPrayers.map((p) {
                      final c = prayerCounts[p.key]!;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _bar(c['jamaa']!, days.length, AppColors.green),
                            _bar(c['fardi']!, days.length, AppColors.blue),
                            _bar(c['qada']!, days.length, AppColors.amber),
                            _bar(c['lam']!, days.length, AppColors.red),
                            const SizedBox(height: 6),
                            Text(p.name, style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 12,
                  children: [
                    _Legend(color: AppColors.green, label: 'جماعة'),
                    _Legend(color: AppColors.blue, label: 'فردي'),
                    _Legend(color: AppColors.amber, label: 'قضاء'),
                    _Legend(color: AppColors.red, label: 'لم أصل'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar(int count, int total, Color color) {
    final h = count == 0 ? 0.0 : (count / total) * 70 + 4;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      width: 14,
      height: h,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }

  List<DateTime> _weekDates(DateTime today) {
    final idx = (today.weekday % 7 + 1) % 7; // السبت = 0
    final sat = DateTime(today.year, today.month, today.day - idx);
    return List.generate(7, (i) => DateTime(sat.year, sat.month, sat.day + i));
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
      ],
    );
  }
}
