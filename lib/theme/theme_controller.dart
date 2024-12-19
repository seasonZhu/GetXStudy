import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/account_manager/account_service.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'themes.dart';

class ThemeController extends GetxController {
  var currentTheme = AppThemes.lightTheme.obs;

  void switchTheme(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        currentTheme.value = AppThemes.lightTheme;
        break;
      case ThemeType.blue:
        currentTheme.value = AppThemes.blueLightTheme;
        break;
      case ThemeType.green:
        currentTheme.value = AppThemes.greenLightTheme;
        break;
      case ThemeType.red:
        currentTheme.value = AppThemes.redLightTheme;
        break;
    }
    saveThemeType(type);
  }

  void _toggleThemeMode() {
    var isDarkMode = currentTheme.value.brightness == Brightness.dark;
    currentTheme.value =
        isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
  }

  void saveThemeType(ThemeType type) {
    // 保存 主题设置
    AccountService.find.saveThemeSetting(type);
  }

  Future<void> getThemeType() async {
    // 获取主题设置
    final type = await AccountService.find.getThemeSetting();
    switchTheme(type);
  }
}
