import 'package:flutter/material.dart';

class AppColors {
  static const black      = Color(0xFF1A1A1A);
  static const cream      = Color(0xFFFFFCF0);
  static const green      = Color(0xFF2BCC71);
  static const yellow     = Color(0xFFFFE500);
  static const orange     = Color(0xFFFF6B35);
  static const teal       = Color(0xFF00C2B2);
  static const purple     = Color(0xFF7C3AED);
  static const red        = Color(0xFFFF3B5C);
  static const cardYellow = Color(0xFFFFFBD1);
  static const cardGreen  = Color(0xFFE0FFF0);
  static const cardOrange = Color(0xFFFFEEE5);
  static const cardBlue   = Color(0xFFE6F4FF);
}

class AppTheme {
  static const _border = BorderSide(color: AppColors.black, width: 2.5);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      secondary: AppColors.orange,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.green,
      secondary: AppColors.orange,
      surface: AppColors.cream,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.black,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.black),
        actionsIconTheme: IconThemeData(color: AppColors.black),
        shape: Border(bottom: BorderSide(color: AppColors.black, width: 3)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: _border,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey.shade300;
            }
            return AppColors.yellow;
          }),
          foregroundColor: WidgetStatePropertyAll(AppColors.black),
          overlayColor: WidgetStatePropertyAll(
              AppColors.black.withAlpha(20)),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: _border,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: _border,
          foregroundColor: AppColors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: _border,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: _border,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.black, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.red, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.red, width: 3),
        ),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: AppColors.black),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: AppColors.black, width: 1.5)),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.black,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.yellow, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.yellow,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.black),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.black,
        thickness: 1.5,
      ),
    );
  }
}
