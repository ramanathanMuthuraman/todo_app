import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for defaultTargetPlatform

class AppTheme {
  // Choose a seed color based on platform (adaptive colors)
  static Color _platformSeedColor() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return Colors.indigo; // iOS-style blue
      case TargetPlatform.android:
        return Colors.blue; // Material blue
      case TargetPlatform.macOS:
        return Colors.teal;
      case TargetPlatform.windows:
        return Colors.deepPurple;
      case TargetPlatform.linux:
        return Colors.green;
      case TargetPlatform.fuchsia:
        return Colors.pink;
    }
  }

  // LIGHT THEME
  static ThemeData lightTheme() {
    final seed = _platformSeedColor();

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ).copyWith(
          // You can override specific colors here:
          primary: seed,
          tertiary: Colors.orange,
          surface: const Color(0xFFF5F5F5),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // DARK THEME
  static ThemeData darkTheme() {
    final seed = _platformSeedColor();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(surface: const Color(0xFF1E1E1E));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
