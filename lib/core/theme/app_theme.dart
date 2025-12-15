import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.primaryColorValue),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(AppConstants.backgroundColorValue),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static const Color primaryColor = Color(AppConstants.primaryColorValue);
  static const Color secondaryColor = Color(AppConstants.secondaryColorValue);
  static const Color accentColor = Color(AppConstants.accentColorValue);
  static const Color backgroundColor = Color(AppConstants.backgroundColorValue);
  static const Color surfaceColor = Color(AppConstants.surfaceColorValue);
  static const Color textColorDark = Color(AppConstants.textColorDarkValue);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(AppConstants.primaryColorValue), Color(AppConstants.secondaryColorValue)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(AppConstants.secondaryColorValue), Color(AppConstants.accentColorValue)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

