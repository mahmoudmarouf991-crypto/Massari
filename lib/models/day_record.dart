/// حالة الصلاة الواحدة
enum PrayerStatus { jamaa, fardi, qada, lam }

extension PrayerStatusX on PrayerStatus {
  String get label {
    switch (this) {
      case PrayerStatus.jamaa:
        return 'جماعة';
      case PrayerStatus.fardi:
        return 'فردي';
      case PrayerStatus.qada:
        return 'قضاء';
      case PrayerStatus.lam:
        return 'لم أصل';
    }
  }

  static PrayerStatus? fromName(String? n) {
    if (n == null) return null;
    for (final v in PrayerStatus.values) {
      if (v.name == n) return v;
    }
    return null;
  }
}

enum QuranAmount { quarter, half, juz }

extension QuranAmountX on QuranAmount {
  String get label {
    switch (this) {
      case QuranAmount.quarter:
        return 'ربع';
      case QuranAmount.half:
        return 'نصف';
      case QuranAmount.juz:
        return 'جزء';
    }
  }

  double get juzValue {
    switch (this) {
      case QuranAmount.quarter:
        return 0.25;
      case QuranAmount.half:
        return 0.5;
      case QuranAmount.juz:
        return 1.0;
    }
  }

  static QuranAmount? fromName(String? n) {
    if (n == null) return null;
    for (final v in QuranAmount.values) {
      if (v.name == n) return v;
    }
    return null;
  }
}

/// سجل يوم واحد من المتابعة
class DayRecord {
  Map<String, PrayerStatus?> prayers;
  QuranAmount? quran;
  String? rstudy; // seerah|sahaba|fiqh|other
  String rstudyNote;
  int sport; // دقائق
  String? fasting; // monThu|whiteDays|other
  String? goodDeed; // help|sadaqa|zakat|other
  String goodDeedNote;
  String notes;

  DayRecord({
    Map<String, PrayerStatus?>? prayers,
    this.quran,
    this.rstudy,
    this.rstudyNote = '',
    this.sport = 0,
    this.fasting,
    this.goodDeed,
    this.goodDeedNote = '',
    this.notes = '',
  }) : prayers = prayers ??
            {
              'fajr': null,
              'dhuhr': null,
              'asr': null,
              'maghrib': null,
              'isha': null,
            };

  /// عدد الصلوات المؤداة (جماعة أو فردي)
  int get prayersDoneCount =>
      prayers.values.where((v) => v == PrayerStatus.jamaa || v == PrayerStatus.fardi).length;

  bool get isEmpty =>
      prayers.values.every((v) => v == null) &&
      quran == null &&
      rstudy == null &&
      sport == 0 &&
      fasting == null &&
      goodDeed == null;

  /// نسبة التزام اليوم (0..1) أو null لو مفيش بيانات
  double? get score {
    if (isEmpty) return null;
    double s = (prayersDoneCount / 5) * 0.4;
    if (quran != null) s += 0.15;
    if (rstudy != null) s += 0.15;
    if (sport > 0) s += 0.1;
    if (fasting != null) s += 0.1;
    if (goodDeed != null) s += 0.1;
    return s.clamp(0, 1).toDouble();
  }

  Map<String, dynamic> toJson() => {
        'prayers': prayers.map((k, v) => MapEntry(k, v?.name)),
        'quran': quran?.name,
        'rstudy': rstudy,
        'rstudyNote': rstudyNote,
        'sport': sport,
        'fasting': fasting,
        'goodDeed': goodDeed,
        'goodDeedNote': goodDeedNote,
        'notes': notes,
      };

  factory DayRecord.fromJson(Map<String, dynamic> j) {
    final prayersJson = (j['prayers'] as Map?)?.cast<String, dynamic>() ?? {};
    return DayRecord(
      prayers: {
        'fajr': PrayerStatusX.fromName(prayersJson['fajr']),
        'dhuhr': PrayerStatusX.fromName(prayersJson['dhuhr']),
        'asr': PrayerStatusX.fromName(prayersJson['asr']),
        'maghrib': PrayerStatusX.fromName(prayersJson['maghrib']),
        'isha': PrayerStatusX.fromName(prayersJson['isha']),
      },
      quran: QuranAmountX.fromName(j['quran'] as String?),
      rstudy: j['rstudy'] as String?,
      rstudyNote: j['rstudyNote'] as String? ?? '',
      sport: j['sport'] as int? ?? 0,
      fasting: j['fasting'] as String?,
      goodDeed: j['goodDeed'] as String?,
      goodDeedNote: j['goodDeedNote'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
    );
  }
}

class PrayerInfo {
  final String key;
  final String name;
  const PrayerInfo(this.key, this.name);
}

const List<PrayerInfo> kPrayers = [
  PrayerInfo('fajr', 'الفجر'),
  PrayerInfo('dhuhr', 'الظهر'),
  PrayerInfo('asr', 'العصر'),
  PrayerInfo('maghrib', 'المغرب'),
  PrayerInfo('isha', 'العشاء'),
];
