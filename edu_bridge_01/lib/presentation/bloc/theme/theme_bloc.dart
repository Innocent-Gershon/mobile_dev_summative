import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeEvent { toggleTheme, setLightTheme, setDarkTheme, setSystemTheme }

class ThemeState {
  final ThemeMode themeMode;
  final String themeName;

  const ThemeState({required this.themeMode, required this.themeName});
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system, themeName: 'System')) {
    on<ThemeEvent>(_onThemeEvent);
    _loadTheme();
  }

  void _onThemeEvent(ThemeEvent event, Emitter<ThemeState> emit) async {
    switch (event) {
      case ThemeEvent.setLightTheme:
        emit(const ThemeState(themeMode: ThemeMode.light, themeName: 'Light'));
        await _saveTheme('light');
        break;
      case ThemeEvent.setDarkTheme:
        emit(const ThemeState(themeMode: ThemeMode.dark, themeName: 'Dark'));
        await _saveTheme('dark');
        break;
      case ThemeEvent.setSystemTheme:
        emit(const ThemeState(themeMode: ThemeMode.system, themeName: 'System'));
        await _saveTheme('system');
        break;
      case ThemeEvent.toggleTheme:
        if (state.themeMode == ThemeMode.light) {
          add(ThemeEvent.setDarkTheme);
        } else {
          add(ThemeEvent.setLightTheme);
        }
        break;
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';
    
    switch (theme) {
      case 'light':
        add(ThemeEvent.setLightTheme);
        break;
      case 'dark':
        add(ThemeEvent.setDarkTheme);
        break;
      default:
        add(ThemeEvent.setSystemTheme);
        break;
    }
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }
}