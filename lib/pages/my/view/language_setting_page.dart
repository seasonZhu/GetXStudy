import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/language_service.dart';
import 'package:getx_study/i18n/app_text.dart';

class LanguageSettingPage extends StatelessWidget {
  const LanguageSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LanguageService.find;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('language_setting')),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Obx(() {
          final selected = service.selectedLanguage.value;
          return ListView.separated(
            itemCount: LanguageService.supportedLocales.length + 1,
            itemBuilder: (context, index) {
              final code = index == 0 ? null :
                  LanguageService.supportedLocales[index - 1].languageCode;
              return ListTile(
                title: Text(index == 0 ? AppText.t('language.system') :
                    LanguageService.languageNames[index - 1]),
                trailing: selected == code ? const Icon(Icons.check) : null,
                onTap: () => service.select(code),
              );
            },
            separatorBuilder: (context, index) => const Divider(indent: 15, height: 0.5),
          );
        }),
      ),
    );
  }
}
