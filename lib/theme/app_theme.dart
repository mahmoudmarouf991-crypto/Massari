import 'package:flutter/material.dart';

/// ألوان وتصميم التطبيق - مطابقة لنسخة الويب
class AppColors {
  static const navy = Color(0xFF101C3D);
  static const navy2 = Color(0xFF1B2B56);
  static const bg = Color(0xFFEEF1F7);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF5F7FB);
  static const ink = Color(0xFF101C3D);
  static const inkSoft = Color(0xFF5B6684);
  static const muted = Color(0xFF93A0BD);
  static const line = Color(0xFFE4E8F2);
  static const green = Color(0xFF1FA971);
  static const greenSoft = Color(0xFFE3F7EE);
  static const amber = Color(0xFFE2933B);
  static const red = Color(0xFFDF5A5A);
  static const blue = Color(0xFF3F7DE0);
  static const gold = Color(0xFFC9A24A);
  static const purple = Color(0xFF8B6FD8);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.navy,
        secondary: AppColors.green,
        surface: AppColors.surface,
      ),
      cardColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
