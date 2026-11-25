import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// بطاقة قسم بعنوان وأيقونة (زي كروت الموقع)
class SectionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 9),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle != null) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
