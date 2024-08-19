import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;
  bool _isNightMode;

  ThemeProvider(bool isNightMode)
      : _isNightMode = isNightMode,
        _themeData = isNightMode ? nightTheme : dayTheme;

  ThemeData get themeData => _themeData;

  bool get isNightMode => _isNightMode;

  void toggleTheme() async {
    _isNightMode = !_isNightMode;
    _themeData = _isNightMode ? nightTheme : dayTheme;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNightMode', _isNightMode);

    notifyListeners();
  }
}
