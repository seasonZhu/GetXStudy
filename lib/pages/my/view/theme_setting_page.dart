import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/enum/theme_type.dart';
import 'package:getx_study/app_service/theme_service.dart';

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({super.key});

  final dataSource = ThemeType.values;

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.find;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text("theme_setting".tr),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(dataSource[index].title),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    themeService.switchTheme(dataSource[index]);
                  });
            },
            separatorBuilder: (context, index) {
              return const Divider(
                indent: 15,
                height: 0.5,
              );
            },
            itemCount: dataSource.length),
      ),
    );
  }
}
