import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color_manager.dart';
import 'font_manager.dart';

class ThemeManager {
  // ─── Light Theme ────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: FontConstants.fontFamily,
    primaryColor: ColorManager.primaryColor,
    scaffoldBackgroundColor: ColorManager.backgroundColor,

    appBarTheme: const AppBarTheme(
      backgroundColor: ColorManager.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.fontColor,
        fontSize: 20,
        fontWeight: FontWeightManager.bold,
      ),
      iconTheme: IconThemeData(color: ColorManager.fontColor),
    ),

    cardColor: ColorManager.cardLight,

    colorScheme: const ColorScheme.light(
      primary: ColorManager.primaryColor,
      secondary: ColorManager.goldColor,
      surface: ColorManager.surfaceLight,
      onPrimary: ColorManager.white,
      onSecondary: ColorManager.black,
      onSurface: ColorManager.fontColor,
      error: ColorManager.red,
      onError: ColorManager.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.surfaceLight,
      hintStyle: const TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.gray,
        fontWeight: FontWeightManager.regular,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: ColorManager.gray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorManager.gray.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: ColorManager.primaryColor),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.fontColor,
        fontSize: 16,
        fontWeight: FontWeightManager.regular,
      ),
      bodyMedium: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.gray,
        fontSize: 14,
        fontWeight: FontWeightManager.regular,
      ),
      titleLarge: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.fontColor,
        fontSize: 20,
        fontWeight: FontWeightManager.bold,
      ),
      labelLarge: TextStyle(
        fontFamily: FontConstants.fontFamily,
        fontWeight: FontWeightManager.medium,
      ),
    ),
  );

  // ─── Dark Theme ──────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: FontConstants.fontFamily,
    primaryColor: ColorManager.primaryDarkColor,
    scaffoldBackgroundColor: ColorManager.backgroundDarkColor,

    appBarTheme: const AppBarTheme(
      backgroundColor: ColorManager.backgroundDarkColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.white,
        fontSize: 20,
        fontWeight: FontWeightManager.bold,
      ),
      iconTheme: IconThemeData(color: ColorManager.goldColor),
    ),

    cardColor: ColorManager.cardDark,

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorManager.cardDark,
      hintStyle: const TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.gray,
        fontWeight: FontWeightManager.regular,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: ColorManager.primaryDarkColor),
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: ColorManager.primaryDarkColor,
      secondary: ColorManager.goldColor,
      surface: ColorManager.surfaceDarkColor,
      onPrimary: ColorManager.black,
      onSecondary: ColorManager.black,
      onSurface: ColorManager.white,
      error: ColorManager.red,
      onError: ColorManager.white,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.white,
        fontSize: 16,
        fontWeight: FontWeightManager.regular,
      ),
      bodyMedium: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.gray,
        fontSize: 14,
        fontWeight: FontWeightManager.regular,
      ),
      titleLarge: TextStyle(
        fontFamily: FontConstants.fontFamily,
        color: ColorManager.white,
        fontSize: 20,
        fontWeight: FontWeightManager.bold,
      ),
      labelLarge: TextStyle(
        fontFamily: FontConstants.fontFamily,
        fontWeight: FontWeightManager.medium,
      ),
    ),
  );

  static ThemeData getTheme() {
    return lightTheme;
  }
}
