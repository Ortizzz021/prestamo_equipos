import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _semilla = Color(0xFF1565C0);

  static ThemeData get claro => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _semilla),
        useMaterial3: true,
      );

  static ThemeData get oscuro => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _semilla,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
