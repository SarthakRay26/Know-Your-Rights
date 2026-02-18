import 'package:flutter/material.dart';

/// Supported locales and their display names.
/// Centralized here so adding a new language only requires editing this file.
class AppLocales {
  static const supported = [
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
  ];

  /// Human-readable labels for the language selection screen.
  static const Map<String, String> displayNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
  };

  static String displayName(String code) => displayNames[code] ?? code;
}
