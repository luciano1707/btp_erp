import 'package:flutter/material.dart';

abstract final class AppColors {
  static const forest = Color(0xFF174B3A);
  static const lime = Color(0xFFD5EA75);
  static const paper = Color(0xFFF4F5EF);
  static const ink = Color(0xFF24342C);
  static const muted = Color(0xFF68756E);
}

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.forest),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.paper, foregroundColor: AppColors.forest, surfaceTintColor: Colors.transparent),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E5DC))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
    ),
  );
}