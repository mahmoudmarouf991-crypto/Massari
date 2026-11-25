import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../theme/app_theme.dart';

/// شاشة إضافة / تعديل تذكير. بترجّع Reminder أو null لو اتلغت
Future<Reminder?> showReminderSheet(
  BuildContext context, {
  Reminder? existing,
  required int id,
}) {
  return showModalBottomSheet<Reminder>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => _ReminderForm(existing: existing, id: id),
  );
}

class _ReminderForm extends StatefulWidget {
  final Reminder? existing;
  final int id;
  const _ReminderForm({required this.existing, required this.id});

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  late final TextEditingController nameCtrl;
  late final TextEditingController noteCtrl;
  late ReminderType type;
  late TimeOfDay time;
  late Set<int> days;
  String? error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    nameCtrl = TextEditingController(text: e?.name ?? '');
    noteCtrl = TextEditingController(text: e?.note ?? '');
    type = e?.type ?? ReminderType.medicine;
    time = TimeOfDay(hour: e?.hour ?? 8, minute: e?.minute ?? 0);
    days = {...(e?.days ?? <int>{})};
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      );

  void _selectType(ReminderType t) {
    setState(() {
      type = t;
      if (nameCtrl.text.trim().isEmpty) nameCtrl.text = t.label;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  void _save() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => error = 'اكتب اسم الدواء أو المكمل');
      return;
    }
    Navigator.pop(
      context,
      Reminder(
        id: widget.id,
        name: name,
        type: type,
        hour: time.hour,
        minute: time.minute,
        days: days,
        note: noteCtrl.text.trim(),
        enabled: widget.existing?.enabled ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(widget.existing == null ? 'إضافة تذكير' : 'تعديل التذكير',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ReminderType.values.map((t) {
                  final on = t == type;
                  return ChoiceChip(
                    label: Text('${t.emoji} ${t.label}'),
                    selected: on,
                    selectedColor: AppColors.greenSoft,
                    onSelected: (_) => _selectType(t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: _dec('الاسم', hint: 'مثال: فيتامين د'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: _dec('الجرعة / ملاحظة (اختياري)',
                    hint: 'مثال: حبة بعد الأكل'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text('الموعد: $timeLabel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('الأيام (من غير اختيار = كل يوم)',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: kWeekdayOrder.map((d) {
                  return FilterChip(
                    label: Text(kWeekdayShort[d]!),
                    selected: days.contains(d),
                    selectedColor: AppColors.greenSoft,
                    onSelected: (v) => setState(() {
                      if (v) {
                        days.add(d);
                      } else {
                        days.remove(d);
                      }
                    }),
                  );
                }).toList(),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
              ],
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _save,
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
