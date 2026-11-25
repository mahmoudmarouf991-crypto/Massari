import 'package:flutter/material.dart';
import '../models/day_record.dart';
import '../theme/app_theme.dart';

/// بوتوم شيت لاختيار حالة صلاة معيّنة
Future<PrayerStatus?> showPrayerSheet(
  BuildContext context, {
  required String prayerName,
  required PrayerStatus? current,
}) {
  return showModalBottomSheet<PrayerStatus?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      PrayerStatus? selected = current;
      return StatefulBuilder(
        builder: (ctx, setState) {
          Widget option(PrayerStatus s, String label, IconData icon) {
            final isSel = selected == s;
            return ListTile(
              leading: Icon(icon, color: isSel ? AppColors.green : AppColors.muted),
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? AppColors.green : Colors.transparent,
                  border: Border.all(
                      color: isSel ? AppColors.green : AppColors.line, width: 2),
                ),
              ),
              onTap: () => setState(() => selected = s),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(prayerName,
                          style:
                              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx, current),
                      ),
                    ],
                  ),
                  option(PrayerStatus.jamaa, 'جماعة', Icons.groups),
                  option(PrayerStatus.fardi, 'فردي', Icons.person),
                  option(PrayerStatus.qada, 'قضاء', Icons.schedule),
                  option(PrayerStatus.lam, 'لم أصل', Icons.close),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(ctx, selected),
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
