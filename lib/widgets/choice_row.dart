import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChoiceOption {
  final String value;
  final String label;
  const ChoiceOption(this.value, this.label);
}

/// صف اختيارات (شبه chips) - اختيار واحد مع إمكانية إلغاء الاختيار بالضغط تاني
class ChoiceRow extends StatelessWidget {
  final List<ChoiceOption> options;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final Color activeColor;

  const ChoiceRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.activeColor = AppColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isOn = o.value == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(isOn ? null : o.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOn ? activeColor : AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isOn ? activeColor : AppColors.line),
            ),
            child: Text(
              o.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isOn ? Colors.white : AppColors.inkSoft,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
