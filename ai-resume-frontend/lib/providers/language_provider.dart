// lib/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _appLocale = Locale('en'); // Default to English

  Locale get appLocale => _appLocale;

  LanguageProvider() {
    _loadLocale();
  }

  // Load saved locale from preferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? 'en';
    _appLocale = Locale(languageCode);
    notifyListeners();
  }

  // Change and save locale
  Future<void> changeLanguage(Locale newLocale) async {
    if (_appLocale == newLocale) return;

    _appLocale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
    notifyListeners();
  }
}
