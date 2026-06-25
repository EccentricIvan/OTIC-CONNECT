import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _font = 'PlusJakartaSans';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
        onSurface: Colors.white,
        onSurfaceVariant: const Color(0xCCFFFFFF),
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      hintColor: AppColors.textHint,
      dividerColor: AppColors.border,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: _font,
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    return base.copyWith(
      textTheme: textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700,
          color: Colors.white, height: 1.15, letterSpacing: -0.5,
        ),
        headlineLarge: const TextStyle(
          fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: const TextStyle(
          fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: const TextStyle(
          fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: const TextStyle(
          fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontFamily: _font, fontSize: 16, color: Color(0xCCFFFFFF), height: 1.6,
        ),
        bodyMedium: const TextStyle(
          fontFamily: _font, fontSize: 14, color: Color(0xCCFFFFFF), height: 1.5,
        ),
        labelLarge: const TextStyle(
          fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: const Color(0x22FFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x18FFFFFF)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0x44FFFFFF)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x22FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        hintStyle: const TextStyle(fontFamily: _font, color: Color(0x66FFFFFF), fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF083E3E),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.accent.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 24);
          }
          return const IconThemeData(color: Color(0x99FFFFFF), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.accent,
            );
          }
          return const TextStyle(fontFamily: _font, fontSize: 11, color: Color(0x99FFFFFF));
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x22FFFFFF), thickness: 1, space: 1,
      ),
    );
  }

  static ThemeData get dark => light;
}
