import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_strings.dart';

/// Language Provider - Manages app language (English/Kinyarwanda)
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = AppStrings.languageEnglish;

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  // Load saved language preference
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage =
          prefs.getString('language') ?? AppStrings.languageEnglish;
      notifyListeners();
    } catch (e) {
      _currentLanguage = AppStrings.languageEnglish;
    }
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', languageCode);
      } catch (e) {
        // Handle error silently
      }
    }
  }

  // Toggle between English and Kinyarwanda
  Future<void> toggleLanguage() async {
    if (_currentLanguage == AppStrings.languageEnglish) {
      await setLanguage(AppStrings.languageKinyarwanda);
    } else {
      await setLanguage(AppStrings.languageEnglish);
    }
  }

  // Check if current language is English
  bool get isEnglish => _currentLanguage == AppStrings.languageEnglish;

  // Check if current language is Kinyarwanda
  bool get isKinyarwanda => _currentLanguage == AppStrings.languageKinyarwanda;

  // Get localized string
  String getLocalizedString(String key) {
    return AppStrings.getLocalizedString(key, _currentLanguage);
  }
}
