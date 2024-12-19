import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:getx_study/account_manager/account_service.dart';
import 'package:getx_study/enum/theme_type.dart';
import '../../common/themes.dart';

class ThemeController extends GetxController {
  var currentTheme = AppThemes.lightTheme.obs;

  void switchTheme(ThemeType type) async {
    switch (type) {
      case ThemeType.light:
        currentTheme.value = AppThemes.lightTheme;
        break;
      case ThemeType.dark:
        currentTheme.value = AppThemes.darkTheme;
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
    restartApp();
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

  // 重启应用的方法
  Future<void> restartApp() async {
    if (Get.context != null) {
        Phoenix.rebirth(Get.context!);
    }
  }
}
