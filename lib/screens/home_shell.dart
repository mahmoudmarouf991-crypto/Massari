import 'package:flutter/material.dart';
import '../services/hijri_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'calendar_screen.dart';
import 'meds_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

const _weekdaysAr = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
const _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

class HomeShell extends StatefulWidget {
  final StorageService storage;
  final NotificationService notifications;
  const HomeShell({super.key, required this.storage, required this.notifications});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tabIndex = 0;
  int rebuildKey = 0;
  final today = DateTime.now();

  String get _gregLabel {
    final idx = (today.weekday % 7 + 1) % 7; // السبت = 0
    return '${_weekdaysAr[idx]}، ${today.day} ${_monthsAr[today.month - 1]} ${today.year}م';
  }

  String get _hijriLabel {
    final h = HijriService.fromGregorian(today, adjust: widget.storage.getHijriAdjust());
    return '${h.day} ${kHijriMonths[h.month - 1]} ${h.year}هـ';
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(key: ValueKey('today$rebuildKey'), storage: widget.storage, today: today),
      MedsScreen(
        key: ValueKey('meds$rebuildKey'),
        storage: widget.storage,
        notifications: widget.notifications,
        today: today,
      ),
      ReportsScreen(key: ValueKey('reports$rebuildKey'), storage: widget.storage, today: today),
      CalendarScreen(key: ValueKey('cal$rebuildKey'), storage: widget.storage, today: today),
      SettingsScreen(
        key: ValueKey('settings$rebuildKey'),
        storage: widget.storage,
        onReset: () => setState(() => rebuildKey++),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, Color(0xFF137A4E)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🕌', style: TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('مساري',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text(_gregLabel,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFFDBE2F7))),
                  Text(_hijriLabel,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(index: tabIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (i) => setState(() => tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'اليوم'),
          BottomNavigationBarItem(icon: Icon(Icons.medication_outlined), label: 'الأدوية'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'التقارير'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'التقويم'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
