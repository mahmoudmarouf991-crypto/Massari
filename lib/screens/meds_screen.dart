import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/reminder_sheet.dart';

class MedsScreen extends StatefulWidget {
  final StorageService storage;
  final NotificationService notifications;
  final DateTime today;
  const MedsScreen({
    super.key,
    required this.storage,
    required this.notifications,
    required this.today,
  });

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  late List<Reminder> reminders;
  late Set<int> taken;

  @override
  void initState() {
    super.initState();
    reminders = widget.storage.getReminders();
    taken = widget.storage.getTaken(widget.today);
  }

  Future<void> _addOrEdit([Reminder? existing]) async {
    final id = existing?.id ?? await widget.storage.takeNextReminderId();
    if (!mounted) return;
    final r = await showReminderSheet(context, existing: existing, id: id);
    if (r == null) return;
    setState(() {
      final i = reminders.indexWhere((x) => x.id == r.id);
      if (i >= 0) {
        reminders[i] = r;
      } else {
        reminders.add(r);
      }
    });
    await widget.storage.saveReminders(reminders);
    await widget.notifications.requestPermissions();
    await widget.notifications.schedule(r);
  }

  Future<void> _toggleTaken(Reminder r, bool v) async {
    setState(() {
      if (v) {
        taken.add(r.id);
      } else {
        taken.remove(r.id);
      }
    });
    await widget.storage.setTaken(widget.today, taken);
  }

  Future<void> _toggleEnabled(Reminder r, bool v) async {
    setState(() => r.enabled = v);
    await widget.storage.saveReminders(reminders);
    await widget.notifications.schedule(r);
  }

  Future<void> _delete(Reminder r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التذكير'),
        content: Text('حذف تذكير "${r.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    await widget.notifications.cancel(r.id);
    setState(() {
      reminders.removeWhere((x) => x.id == r.id);
      taken.remove(r.id);
    });
    await widget.storage.saveReminders(reminders);
    await widget.storage.setTaken(widget.today, taken);
  }

  @override
  Widget build(BuildContext context) {
    final todays = reminders
        .where((r) => r.enabled && r.appliesOn(widget.today))
        .toList()
      ..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    final doneCount = todays.where((r) => taken.contains(r.id)).length;
    final all = [...reminders]..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('💊', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    const Text('جرعات اليوم',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Text('$doneCount / ${todays.length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                if (todays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text('مفيش جرعات النهارده. أضف أول تذكير ⬇️',
                          style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                    ),
                  ),
                ...todays.map((r) {
                  final done = taken.contains(r.id);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.green,
                    value: done,
                    onChanged: (v) => _toggleTaken(r, v ?? false),
                    title: Text(
                      '${r.type.emoji} ${r.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? AppColors.muted : AppColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      r.note.isEmpty ? r.timeLabel : '${r.timeLabel} · ${r.note}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Text('⏰', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('كل التذكيرات',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 6),
                ...all.map((r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => _addOrEdit(r),
                      title: Text('${r.type.emoji} ${r.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${r.timeLabel} · ${r.daysLabel}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: r.enabled,
                            activeTrackColor: AppColors.green,
                            onChanged: (v) => _toggleEnabled(r, v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.red),
                            onPressed: () => _delete(r),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _addOrEdit(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة تذكير جديد'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await widget.notifications.requestPermissions();
                    await widget.notifications.showTest();
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('إرسال إشعار تجريبي'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'التطبيق بيفكّرك بالمواعيد اللي أنت بتحددها بس، ومش بيدّي نصايح علاجية. '
          'التزم بجرعات طبيبك أو الصيدلي.',
          style: TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ],
    );
  }
}
