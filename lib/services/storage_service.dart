import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_record.dart';
import '../models/reminder.dart';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class SelectedLocation {
  final String label;
  final double lat;
  final double lng;
  final int tz;
  const SelectedLocation({
    required this.label,
    required this.lat,
    required this.lng,
    required this.tz,
  });

  Map<String, dynamic> toJson() => {'label': label, 'lat': lat, 'lng': lng, 'tz': tz};

  factory SelectedLocation.fromJson(Map<String, dynamic> j) => SelectedLocation(
        label: j['label'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        tz: j['tz'] as int,
      );
}

/// طبقة تخزين بسيطة فوق SharedPreferences
class StorageService {
  static const _dayPrefix = 'day_';
  static const _locationKey = 'location';
  static const _hijriAdjustKey = 'hijriAdjust';
  static const _remindersKey = 'reminders';
  static const _nextReminderIdKey = 'reminderNextId';
  static const _takenPrefix = 'taken_';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  DayRecord getDay(DateTime date) {
    final raw = _prefs.getString(_dayPrefix + dateKey(date));
    if (raw == null) return DayRecord();
    try {
      return DayRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return DayRecord();
    }
  }

  Future<void> saveDay(DateTime date, DayRecord record) async {
    await _prefs.setString(_dayPrefix + dateKey(date), jsonEncode(record.toJson()));
  }

  /// يرجع كل السجلات المحفوظة (لحساب التقارير والتقويم)
  Map<String, DayRecord> getAllDays() {
    final result = <String, DayRecord>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_dayPrefix)) {
        final raw = _prefs.getString(key);
        if (raw == null) continue;
        try {
          result[key.substring(_dayPrefix.length)] =
              DayRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {}
      }
    }
    return result;
  }

  SelectedLocation? getLocation() {
    final raw = _prefs.getString(_locationKey);
    if (raw == null) return null;
    try {
      return SelectedLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocation(SelectedLocation loc) async {
    await _prefs.setString(_locationKey, jsonEncode(loc.toJson()));
  }

  int getHijriAdjust() => _prefs.getInt(_hijriAdjustKey) ?? 0;

  Future<void> setHijriAdjust(int v) async {
    await _prefs.setInt(_hijriAdjustKey, v);
  }

  // ---------- التذكيرات (أدوية / فيتامينات / كرياتين) ----------
  List<Reminder> getReminders() {
    final raw = _prefs.getString(_remindersKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReminders(List<Reminder> list) async {
    await _prefs.setString(_remindersKey, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  Future<int> takeNextReminderId() async {
    final id = (_prefs.getInt(_nextReminderIdKey) ?? 0) + 1;
    await _prefs.setInt(_nextReminderIdKey, id);
    return id;
  }

  /// ids التذكيرات اللي اتاخدت في يوم معيّن
  Set<int> getTaken(DateTime date) {
    final list = _prefs.getStringList(_takenPrefix + dateKey(date)) ?? const [];
    return list.map(int.parse).toSet();
  }

  Future<void> setTaken(DateTime date, Set<int> ids) async {
    await _prefs.setStringList(
        _takenPrefix + dateKey(date), ids.map((e) => e.toString()).toList());
  }

  Future<void> resetAll() async {
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(_dayPrefix) || key.startsWith(_takenPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
