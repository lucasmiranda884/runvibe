import 'package:flutter/material.dart';

final themeModeController = ValueNotifier<ThemeMode>(ThemeMode.system);

void setThemeMode(ThemeMode mode) {
  themeModeController.value = mode;
}
