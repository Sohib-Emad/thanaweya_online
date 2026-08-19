import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// Provides light and dark [ThemeData] for the application.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => LightTheme.data;
  static ThemeData get darkTheme => DarkTheme.data;
}
