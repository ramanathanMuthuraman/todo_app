import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light; // or ThemeMode.system if you like
  static const _prefKey = 'theme_mode_v1';

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> loadInitialTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);

    switch (stored) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      case 'system':
        _mode = ThemeMode.system;
        break;
      default:
        _mode = ThemeMode.light; // fallback
    }

    notifyListeners(); // tell listeners that mode is ready
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();

    String value;
    switch (_mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString(_prefKey, value);
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
    _saveThemeMode();
  }

  void toggle() {
    if (_mode == ThemeMode.dark) {
      setMode(ThemeMode.light);
    } else {
      setMode(ThemeMode.dark);
    }
  }
}

class ThemeControllerProvider extends InheritedNotifier<ThemeController> {
  const ThemeControllerProvider({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null, 'No ThemeControllerProvider found in context');
    return provider!.notifier!;
  }
}
