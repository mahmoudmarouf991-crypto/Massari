class Region {
  final String name;
  final double lat;
  final double lng;
  const Region(this.name, this.lat, this.lng);
}

class Country {
  final String name;
  final int tz; // فرق التوقيت عن UTC بالساعات
  final List<Region> regions;
  const Country(this.name, this.tz, this.regions);
}

/// قائمة دول ومحافظات مختصرة (قابلة للتوسعة)
const List<Country> kCountries = [
  Country('مصر', 2, [
    Region('القاهرة', 30.0444, 31.2357),
    Region('الإسكندرية', 31.2001, 29.9187),
    Region('أسيوط', 27.1809, 31.1837),
    Region('أسوان', 24.0889, 32.8998),
    Region('المنصورة', 31.0409, 31.3785),
  ]),
  Country('السعودية', 3, [
    Region('الرياض', 24.7136, 46.6753),
    Region('مكة المكرمة', 21.4225, 39.8262),
    Region('المدينة المنورة', 24.4672, 39.6024),
    Region('جدة', 21.4858, 39.1925),
    Region('الدمام', 26.4207, 50.0888),
  ]),
  Country('الإمارات', 4, [
    Region('دبي', 25.2048, 55.2708),
    Region('أبوظبي', 24.4539, 54.3773),
    Region('الشارقة', 25.3463, 55.4209),
  ]),
  Country('قطر', 3, [
    Region('الدوحة', 25.2854, 51.5310),
  ]),
  Country('الكويت', 3, [
    Region('مدينة الكويت', 29.3759, 47.9774),
  ]),
  Country('الأردن', 3, [
    Region('عمّان', 31.9454, 35.9284),
    Region('إربد', 32.5556, 35.8500),
  ]),
  Country('العراق', 3, [
    Region('بغداد', 33.3152, 44.3661),
    Region('البصرة', 30.5085, 47.7804),
  ]),
  Country('المغرب', 1, [
    Region('الرباط', 34.0209, -6.8416),
    Region('الدار البيضاء', 33.5731, -7.5898),
  ]),
  Country('الجزائر', 1, [
    Region('الجزائر العاصمة', 36.7538, 3.0588),
  ]),
  Country('السودان', 2, [
    Region('الخرطوم', 15.5007, 32.5599),
  ]),
];
