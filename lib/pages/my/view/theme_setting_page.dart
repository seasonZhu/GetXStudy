import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_study/theme/theme_controller.dart';

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("主题颜色"),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: themeController.toggleThemeMode,
              child: const Text('Toggle Light/Dark Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => themeController.switchTheme(0),
              child: const Text('Switch to Blue Theme'),
            ),
            ElevatedButton(
              onPressed: () => themeController.switchTheme(1),
              child: const Text('Switch to Green Theme'),
            ),
            ElevatedButton(
              onPressed: () => themeController.switchTheme(2),
              child: const Text('Switch to Red Theme'),
            ),
          ],
        ),
      ),
    );
  }
}
