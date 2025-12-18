import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Simple cubit to manage app light/dark theme mode.
class ThemeCubit extends Cubit<ThemeMode> {
  // Start in light mode by default
  ThemeCubit() : super(ThemeMode.dark);

  void toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
