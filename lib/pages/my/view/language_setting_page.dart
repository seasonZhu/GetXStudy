import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSettingPage extends StatelessWidget {
  const LanguageSettingPage({super.key});

  static const _languages = {
    '简体中文': Locale('zh', 'CN'),
    'English': Locale('en', 'US'),
    'Français': Locale('fr', 'FR'),
  };

  @override
  Widget build(BuildContext context) {
    final languages = _languages.entries.toList();
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('language_setting'.tr),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListView.separated(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            return ListTile(
              title: Text(language.key),
              trailing: Get.locale?.languageCode == language.value.languageCode
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                await Get.updateLocale(language.value);
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(
            indent: 15,
            height: 0.5,
          ),
        ),
      ),
    );
  }
}
