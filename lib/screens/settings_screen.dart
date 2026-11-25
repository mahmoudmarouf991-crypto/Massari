import 'package:flutter/material.dart';
import '../services/hijri_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onReset;
  const SettingsScreen({super.key, required this.storage, required this.onReset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int hijriAdjust;

  @override
  void initState() {
    super.initState();
    hijriAdjust = widget.storage.getHijriAdjust();
  }

  @override
  Widget build(BuildContext context) {
    final h = HijriService.fromGregorian(DateTime.now(), adjust: hijriAdjust);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.navy,
                      child: Text('م', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مستخدم التطبيق',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('بالعلم والعمل نرتقي',
                            style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🌙', style: TextStyle(fontSize: 18)),
                  title: const Text('ضبط التاريخ الهجري'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () async {
                          setState(() => hijriAdjust = (hijriAdjust - 1).clamp(-2, 2).toInt());
                          await widget.storage.setHijriAdjust(hijriAdjust);
                        },
                      ),
                      Text('$hijriAdjust'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          setState(() => hijriAdjust = (hijriAdjust + 1).clamp(-2, 2).toInt());
                          await widget.storage.setHijriAdjust(hijriAdjust);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    'التاريخ الهجري الحالي: ${h.day} ${kHijriMonths[h.month - 1]} ${h.year}هـ',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
                const Divider(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('إعادة تعيين البيانات'),
                          content: const Text(
                              'سيتم حذف جميع البيانات المسجلة. هل أنت متأكد؟'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('إلغاء')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('حذف')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await widget.storage.resetAll();
                        widget.onReset();
                      }
                    },
                    child: const Text('إعادة تعيين كل البيانات'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
