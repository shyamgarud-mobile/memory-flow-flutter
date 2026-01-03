import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';

/// Provider for managing app theme (light/dark/system) and color scheme
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppColorScheme _colorScheme = AppColorScheme.modernProfessional;
  String _fontSize = 'medium';
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  AppColorScheme get colorScheme => _colorScheme;
  String get fontSize => _fontSize;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from saved settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeModeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];

    // Load color scheme
    final colorSchemeIndex = prefs.getInt('colorScheme') ?? 0;
    _colorScheme = AppColorScheme.values[colorSchemeIndex];

    // Load font size
    _fontSize = prefs.getString('fontSize') ?? 'medium';

    _isInitialized = true;
    notifyListeners();
  }

  /// Update theme mode (Light/Dark/System)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  /// Update color scheme
  Future<void> setColorScheme(AppColorScheme scheme) async {
    if (_colorScheme == scheme) return;

    _colorScheme = scheme;
    notifyListeners();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('colorScheme', scheme.index);
  }

  /// Update font size
  Future<void> setFontSize(String size) async {
    if (_fontSize == size) return;

    _fontSize = size;
    notifyListeners();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', size);
  }

  /// Get text scale factor based on font size setting
  double get textScaleFactor {
    switch (_fontSize) {
      case 'small':
        return 0.9;
      case 'large':
        return 1.1;
      case 'medium':
      default:
        return 1.0;
    }
  }
}
