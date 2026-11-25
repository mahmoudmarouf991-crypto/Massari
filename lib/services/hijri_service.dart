/// تحويل ميلادي <-> هجري (خوارزمية تقويمية قياسية تقريبية)
class HijriDate {
  final int year;
  final int month; // 1..12
  final int day;
  const HijriDate(this.year, this.month, this.day);
}

const List<String> kHijriMonths = [
  'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
  'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
];

class HijriService {
  static int gregorianToJD(int y, int m, int d) {
    return ((1461 * (y + 4800 + (m - 14) ~/ 12)) ~/ 4) +
        ((367 * (m - 2 - 12 * ((m - 14) ~/ 12))) ~/ 12) -
        ((3 * ((y + 4900 + (m - 14) ~/ 12) ~/ 100)) ~/ 4) +
        d - 32075;
  }

  static HijriDate fromGregorian(DateTime date, {int adjust = 0}) {
    final jd = gregorianToJD(date.year, date.month, date.day) + adjust;
    int l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = (((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719)) +
        ((l ~/ 5670) * ((43 * l) ~/ 15238));
    l = l -
        (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) -
        ((j ~/ 16) * ((15238 * j) ~/ 43)) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }

  static bool isRamadan(HijriDate h) => h.month == 9;
}
