import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:minimal_music_player/core/theme/dark_mode.dart';
import 'package:minimal_music_player/core/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAssistiveTouchEnabled = false;
  bool get isAssistiveTouchEnabled => _isAssistiveTouchEnabled;
  late final Box _settingsBox;

  ThemeMode get themeMode => _themeMode;
  ThemeData get lightTheme => lightMode;
  ThemeData get darkTheme => darkMode;
  ThemeData get themeData {
    if (_themeMode == ThemeMode.dark) return darkMode;
    if (_themeMode == ThemeMode.light) return lightMode;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? darkMode : lightMode;
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _initTheme();
  }

  void _initTheme() {
    _settingsBox = Hive.box('session');
    final savedMode = _settingsBox.get('themeMode', defaultValue: 'system');
    _isAssistiveTouchEnabled = _settingsBox.get('assistiveTouch', defaultValue: false);
    switch (savedMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    final modeString = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';
    _settingsBox.put('themeMode', modeString);
    notifyListeners();
  }

  void toggleAssistiveTouch() {
    _isAssistiveTouchEnabled = !_isAssistiveTouchEnabled;
    _settingsBox.put('assistiveTouch', _isAssistiveTouchEnabled);
    notifyListeners();
  }

  void toggleTheme() {
    if (isDarkMode) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

