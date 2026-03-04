import 'package:endimata/common/theme/theme_event.dart';
import 'package:endimata/common/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'isDarkTheme';

  ThemeBloc() : super(const ThemeState(ThemeMode.light)) {
    on<LoadThemeEvent>(_onLoad);
    on<ToggleThemeEvent>(_onToggle);

    add(LoadThemeEvent());
  }

  Future<void> _onLoad(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> _onToggle(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newIsDark = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newIsDark);
    emit(ThemeState(newIsDark ? ThemeMode.dark : ThemeMode.light));
  }
}
