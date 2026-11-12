import 'package:flutter/material.dart';

/// Centralized color configuration for the entire app.
/// Import this file wherever colors are needed:
/// import 'package:mtl_jewellery/config/app_colors.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── Background ───────────────────────────────────────────────
  /// Pure white background for all screens | #FFFFFF
  static const Color screenBackground = Color(0xFFFFFFFF);

  // ─── App Bar ──────────────────────────────────────────────────
  /// Pure white app bar background | #FFFFFF
  static const Color appBarBackground = Color(0xFFFFFFFF);

  /// Black app bar title text | #000000
  static const Color appBarTitle = Color(0xFF000000);

  /// Black app bar icons | #000000
  static const Color appBarIcons = Color(0xFF000000);

  // ─── Buttons ──────────────────────────────────────────────────
  /// Primary pink button background | #E91E8C
  static const Color buttonPrimary = Color(0xFFFF9800);

  /// White text/icons on pink buttons | #FFFFFF
  static const Color buttonPrimaryForeground = Color(0xFFFFFFFF);

  // ─── Convenience: pre-built ThemeData pieces ──────────────────

  /// Drop this into MaterialApp > theme for instant app-wide coverage.
  static ThemeData get appTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: buttonPrimary),
    useMaterial3: true,

    // All scaffold backgrounds | #FFFFFF
    scaffoldBackgroundColor: screenBackground,

    // All app bars
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarBackground,   // #FFFFFF
      foregroundColor: appBarIcons,         // #000000
      elevation: 0,
      iconTheme: IconThemeData(color: appBarIcons),         // #000000
      actionsIconTheme: IconThemeData(color: appBarIcons),  // #000000
      titleTextStyle: TextStyle(
        color: appBarTitle,                 // #000000
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // ElevatedButton — pink background #E91E8C, white text #FFFFFF
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPrimary,            // #E91E8C
        foregroundColor: buttonPrimaryForeground,  // #FFFFFF
        elevation: 0,
      ),
    ),

    // TextButton — pink text #E91E8C
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: buttonPrimary,  // #E91E8C
      ),
    ),

    // OutlinedButton — pink border and text #E91E8C
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonPrimary,                    // #E91E8C
        side: const BorderSide(color: buttonPrimary),      // #E91E8C
      ),
    ),

    // FloatingActionButton — pink #E91E8C
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: buttonPrimary,            // #E91E8C
      foregroundColor: buttonPrimaryForeground,  // #FFFFFF
    ),
  );
}