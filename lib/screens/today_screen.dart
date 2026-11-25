import 'package:flutter/material.dart';
import '../data/locations.dart';
import '../models/day_record.dart';
import '../services/prayer_times_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/choice_row.dart';
import '../widgets/prayer_sheet.dart';
import '../widgets/section_card.dart';

class TodayScreen extends StatefulWidget {
  final StorageService storage;
  final DateTime today;
  const TodayScreen({super.key, required this.storage, required this.today});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late DayRecord record;
  SelectedLocation? location;
  DayPrayerTimes? times;
  Country? selectedCountry;
  Region? selectedRegion;
  final notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    record = widget.storage.getDay(widget.today);
    notesCtrl.text = record.notes;
    location = widget.storage.getLocation();
    _recomputeTimes();
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  void _recomputeTimes() {
    if (location == null) {
      times = null;
    } else {
      times = PrayerTimesService.compute(
          widget.today, location!.lat, location!.lng, location!.tz);
    }
  }

  Future<void> _persist() async {
    await widget.storage.saveDay(widget.today, record);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  Future<void> _pickPrayer(PrayerInfo p) async {
    final result = await showPrayerSheet(context,
        prayerName: p.name, current: record.prayers[p.key]);
    if (result != record.prayers[p.key]) {
      setState(() => record.prayers[p.key] = result);
      await _persist();
      _toast('تم الحفظ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildPrayerTimesCard(),
        const SizedBox(height: 14),
        _buildPrayersCard(),
        const SizedBox(height: 14),
        SectionCard(
          icon: '📗',
          title: 'الدراسة الدينية',
          subtitle: 'ماذا درست اليوم؟',
          child: ChoiceRow(
            options: const [
              ChoiceOption('seerah', 'سيرة نبوية'),
              ChoiceOption('sahaba', 'سير الصحابة'),
              ChoiceOption('fiqh', 'فقه'),
              ChoiceOption('other', 'أخرى'),
            ],
            selected: record.rstudy,
            onChanged: (v) async {
              setState(() => record.rstudy = v);
              await _persist();
              _toast('تم الحفظ');
            },
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          icon: '📖',
          title: 'القرآن',
          subtitle: 'ما الذي قرأته اليوم؟',
          child: ChoiceRow(
            options: const [
              ChoiceOption('quarter', 'ربع'),
              ChoiceOption('half', 'نصف'),
              ChoiceOption('juz', 'جزء'),
            ],
            selected: record.quran?.name,
            onChanged: (v) async {
              setState(() => record.quran = QuranAmountX.fromName(v));
              await _persist();
              _toast('تم الحفظ');
            },
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          icon: '🌙',
          title: 'الصيام التطوعي',
          subtitle: 'هل صمت اليوم؟',
          child: ChoiceRow(
            activeColor: AppColors.gold,
            options: const [
              ChoiceOption('monThu', 'الاثنين/الخميس'),
              ChoiceOption('whiteDays', 'الأيام البيض'),
              ChoiceOption('other', 'تطوع آخر'),
            ],
            selected: record.fasting,
            onChanged: (v) async {
              setState(() => record.fasting = v);
              await _persist();
              _toast('تم الحفظ');
            },
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          icon: '💚',
          title: 'عمل الخير',
          subtitle: 'هل قمت بعمل خير اليوم؟',
          child: ChoiceRow(
            options: const [
              ChoiceOption('help', 'مساعدة الغير'),
              ChoiceOption('sadaqa', 'الصدقة'),
              ChoiceOption('zakat', 'الزكاة'),
              ChoiceOption('other', 'أخرى'),
            ],
            selected: record.goodDeed,
            onChanged: (v) async {
              setState(() => record.goodDeed = v);
              await _persist();
              _toast('تم الحفظ');
            },
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          icon: '🏃',
          title: 'الرياضة',
          subtitle: 'هل مارست الرياضة اليوم؟',
          child: Row(
            children: [
              Switch(
                value: record.sport > 0,
                activeTrackColor: AppColors.green,
                onChanged: (v) async {
                  setState(() => record.sport = v ? 15 : 0);
                  await _persist();
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  setState(() => record.sport = (record.sport - 5).clamp(0, 300).toInt());
                  await _persist();
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${record.sport} دقيقة',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () async {
                  setState(() => record.sport = (record.sport + 5).clamp(0, 300).toInt());
                  await _persist();
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          icon: '✏️',
          title: 'ملاحظات اليوم',
          subtitle: 'اختياري',
          child: TextField(
            controller: notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface2,
              hintText: 'اكتب ما تود...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line)),
            ),
            onChanged: (v) {
              record.notes = v;
              _persist();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesCard() {
    return SectionCard(
      icon: '🧭',
      title: 'مواقيت الصلاة',
      subtitle: location?.label ?? 'حدد موقعك',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (times != null)
            Row(
              children: kPrayers.map((p) {
                final t = times!.asMap[p.key];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        Text(p.name,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                        const SizedBox(height: 4),
                        Text(t?.formatted ?? '--:--',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Country>(
                  value: selectedCountry,
                  isExpanded: true,
                  decoration: _ddDecoration('الدولة'),
                  items: kCountries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (c) => setState(() {
                    selectedCountry = c;
                    selectedRegion = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<Region>(
                  key: ValueKey(selectedCountry?.name),
                  value: selectedRegion,
                  isExpanded: true,
                  decoration: _ddDecoration('المحافظة'),
                  items: (selectedCountry?.regions ?? [])
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                      .toList(),
                  onChanged: (r) async {
                    if (r == null || selectedCountry == null) return;
                    final loc = SelectedLocation(
                        label: '${r.name}، ${selectedCountry!.name}',
                        lat: r.lat,
                        lng: r.lng,
                        tz: selectedCountry!.tz);
                    await widget.storage.saveLocation(loc);
                    setState(() {
                      selectedRegion = r;
                      location = loc;
                      _recomputeTimes();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _ddDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11), borderSide: BorderSide.none),
      );

  Widget _buildPrayersCard() {
    return SectionCard(
      icon: '🕋',
      title: 'الصلاة',
      subtitle: 'اضغط على كل صلاة لتحديدها',
      child: Row(
        children: kPrayers.map((p) {
          final status = record.prayers[p.key];
          Color bg = AppColors.surface2;
          Color fg = AppColors.inkSoft;
          if (status == PrayerStatus.jamaa || status == PrayerStatus.fardi) {
            bg = AppColors.green;
            fg = Colors.white;
          } else if (status == PrayerStatus.qada) {
            bg = AppColors.amber;
            fg = Colors.white;
          } else if (status == PrayerStatus.lam) {
            bg = AppColors.red;
            fg = Colors.white;
          }
          return Expanded(
            child: GestureDetector(
              onTap: () => _pickPrayer(p),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Text(p.name,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: bg,
                      child: status == null
                          ? null
                          : Icon(Icons.check, size: 14, color: fg),
                    ),
                    const SizedBox(height: 4),
                    Text(status?.label ?? '',
                        style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
