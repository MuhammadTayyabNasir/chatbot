// lib/presentation/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The Notifier for our theme state.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Initialize with the system's default theme.
  ThemeNotifier() : super(ThemeMode.system);

  // Method to toggle between light and dark mode.
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// The StateNotifierProvider that the UI will interact with.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});