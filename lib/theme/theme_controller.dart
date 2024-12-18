import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'themes.dart';

class ThemeController extends GetxController {
  var currentTheme = AppThemes.lightTheme.obs;

  void changeTheme(String color, bool isDarkMode) {
    switch (color) {
      case 'blue':
        currentTheme.value = AppThemes.blueLightTheme;
        break;
      case 'green':
        currentTheme.value = AppThemes.greenLightTheme;
        break;
      case 'red':
        currentTheme.value = AppThemes.redLightTheme;
        break;
      case 'dark':
        currentTheme.value = isDarkMode ? AppThemes.darkTheme: AppThemes.lightTheme;
        break;
    }
  }

  void switchTheme(int index) {
    var isDarkMode = currentTheme.value.brightness == Brightness.dark;
    switch (index) {
      case 0:
        changeTheme('blue', isDarkMode);
        break;
      case 1:
        changeTheme('green', isDarkMode);
        break;
      case 2:
        changeTheme('red', isDarkMode);
        break;
      case 3:
        changeTheme('dark', isDarkMode);
        break;
    }
  }

  void toggleThemeMode() {
    var isDarkMode = currentTheme.value.brightness == Brightness.dark;
    changeTheme("dark", !isDarkMode);
  }
}
