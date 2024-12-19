import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'package:getx_study/pages/my/controller/theme_controller.dart';

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({Key? key}) : super(key: key);

  final dataSource = ThemeType.values;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("主题颜色"),
      ),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(dataSource[index].title),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  themeController.switchTheme(dataSource[index]);
                });
          },
          separatorBuilder: (context, index) {
            return const Divider(
              indent: 15,
              height: 0.5,
            );
          },
          itemCount: dataSource.length),
    );
  }
}
