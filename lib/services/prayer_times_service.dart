import 'dart:math' as math;

class PrayerTime {
  final int hour;
  final int minute;
  const PrayerTime(this.hour, this.minute);

  String get formatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  double get asDouble => hour + minute / 60.0;
}

class DayPrayerTimes {
  final PrayerTime? fajr;
  final PrayerTime? dhuhr;
  final PrayerTime? asr;
  final PrayerTime? maghrib;
  final PrayerTime? isha;
  const DayPrayerTimes({this.fajr, this.dhuhr, this.asr, this.maghrib, this.isha});

  Map<String, PrayerTime?> get asMap =>
      {'fajr': fajr, 'dhuhr': dhuhr, 'asr': asr, 'maghrib': maghrib, 'isha': isha};
}

/// حساب مواقيت الصلاة فلكيًا (معادلات شمسية قياسية - زاوية الفجر 18°، العشاء 17°)
class PrayerTimesService {
  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;

  static double _julianDate(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        d + b - 1524.5;
  }

  static ({double decl, double eqt}) _sunPosition(double jd) {
    final dNum = jd - 2451545.0;
    double g = (357.529 + 0.98560028 * dNum) % 360;
    if (g < 0) g += 360;
    double q = (280.459 + 0.98564736 * dNum) % 360;
    if (q < 0) q += 360;
    double l = (q + 1.915 * math.sin(_rad(g)) + 0.020 * math.sin(_rad(2 * g))) % 360;
    if (l < 0) l += 360;
    final e = 23.439 - 0.00000036 * dNum;
    double ra = _deg(math.atan2(math.cos(_rad(e)) * math.sin(_rad(l)), math.cos(_rad(l)))) / 15;
    if (ra < 0) ra += 24;
    final decl = _deg(math.asin(math.sin(_rad(e)) * math.sin(_rad(l))));
    double eqt = q / 15 - ra;
    if (eqt > 12) eqt -= 24;
    if (eqt < -12) eqt += 24;
    return (decl: decl, eqt: eqt);
  }

  static double? _hourAngle(double lat, double decl, double angleDeg) {
    final cosH = (-math.sin(_rad(angleDeg)) - math.sin(_rad(lat)) * math.sin(_rad(decl))) /
        (math.cos(_rad(lat)) * math.cos(_rad(decl)));
    if (cosH > 1 || cosH < -1) return null;
    return _deg(math.acos(cosH)) / 15;
  }

  static double? _asrHourAngle(double lat, double decl, double shadowFactor) {
    final angle = _deg(math.atan(1 / (shadowFactor + math.tan(_rad((lat - decl).abs())))));
    final cosH = (math.sin(_rad(angle)) - math.sin(_rad(lat)) * math.sin(_rad(decl))) /
        (math.cos(_rad(lat)) * math.cos(_rad(decl)));
    if (cosH > 1 || cosH < -1) return null;
    return _deg(math.acos(cosH)) / 15;
  }

  static PrayerTime? _toTime(double? h) {
    if (h == null) return null;
    double hh = h % 24;
    if (hh < 0) hh += 24;
    final hour = hh.floor();
    final minute = ((hh - hour) * 60).round();
    return PrayerTime(hour, minute);
  }

  static DayPrayerTimes compute(DateTime date, double lat, double lng, int tz) {
    final jd = _julianDate(date.year, date.month, date.day);
    final pos = _sunPosition(jd);
    final dhuhr = 12 + tz - lng / 15 - pos.eqt;
    final fajrH = _hourAngle(lat, pos.decl, 18);
    final ishaH = _hourAngle(lat, pos.decl, 17);
    final sunH = _hourAngle(lat, pos.decl, 0.833);
    final asrH = _asrHourAngle(lat, pos.decl, 1);
    return DayPrayerTimes(
      fajr: fajrH == null ? null : _toTime(dhuhr - fajrH),
      dhuhr: _toTime(dhuhr),
      asr: asrH == null ? null : _toTime(dhuhr + asrH),
      maghrib: sunH == null ? null : _toTime(dhuhr + sunH),
      isha: ishaH == null ? null : _toTime(dhuhr + ishaH),
    );
  }
}
