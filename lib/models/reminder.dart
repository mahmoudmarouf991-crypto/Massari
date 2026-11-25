enum ReminderType { medicine, vitamin, creatine }

extension ReminderTypeX on ReminderType {
  String get label {
    switch (this) {
      case ReminderType.medicine:
        return 'دواء';
      case ReminderType.vitamin:
        return 'فيتامين';
      case ReminderType.creatine:
        return 'كرياتين';
    }
  }

  String get emoji {
    switch (this) {
      case ReminderType.medicine:
        return '💊';
      case ReminderType.vitamin:
        return '🍊';
      case ReminderType.creatine:
        return '💪';
    }
  }

  static ReminderType fromName(String? n) {
    for (final v in ReminderType.values) {
      if (v.name == n) return v;
    }
    return ReminderType.medicine;
  }
}

/// ترتيب أيام الأسبوع في الواجهة (السبت أولًا) بقيم DateTime.weekday
const List<int> kWeekdayOrder = [6, 7, 1, 2, 3, 4, 5];
const Map<int, String> kWeekdayShort = {
  6: 'س', 7: 'ح', 1: 'ن', 2: 'ث', 3: 'ر', 4: 'خ', 5: 'ج',
};
const Map<int, String> kWeekdayFull = {
  6: 'السبت', 7: 'الأحد', 1: 'الاثنين', 2: 'الثلاثاء',
  3: 'الأربعاء', 4: 'الخميس', 5: 'الجمعة',
};

/// تذكير دواء / فيتامين / مكمل
class Reminder {
  final int id;
  String name;
  ReminderType type;
  int hour;
  int minute;
  Set<int> days; // قيم DateTime.weekday ؛ فاضي = كل يوم
  String note; // الجرعة أو ملاحظة (يكتبها المستخدم)
  bool enabled;

  Reminder({
    required this.id,
    required this.name,
    required this.type,
    required this.hour,
    required this.minute,
    Set<int>? days,
    this.note = '',
    this.enabled = true,
  }) : days = days ?? <int>{};

  bool appliesOn(DateTime d) => days.isEmpty || days.contains(d.weekday);

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  int get minutesOfDay => hour * 60 + minute;

  String get daysLabel {
    if (days.isEmpty || days.length == 7) return 'يوميًا';
    return kWeekdayOrder.where(days.contains).map((d) => kWeekdayFull[d]!).join('، ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'hour': hour,
        'minute': minute,
        'days': days.toList(),
        'note': note,
        'enabled': enabled,
      };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        type: ReminderTypeX.fromName(j['type'] as String?),
        hour: j['hour'] as int? ?? 8,
        minute: j['minute'] as int? ?? 0,
        days: ((j['days'] as List?) ?? const []).map((e) => e as int).toSet(),
        note: j['note'] as String? ?? '',
        enabled: j['enabled'] as bool? ?? true,
      );
}
