import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/enum/my.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'package:getx_study/i18n/localized_strings.dart';
import 'package:getx_study/pages/my/view/language_setting_page.dart';
import 'package:getx_study/pages/my/view/theme_setting_page.dart';
import 'package:getx_study/routes/routes.dart';

// GetX 切换语言使用 reassemble；自动测试中交由下一次 pump 重建，避免测试帧重入。
class _SettingsTestBinding extends AutomatedTestWidgetsFlutterBinding {
  // 此处特意替换会调度热重载帧的父类实现，组件重建由测试 pump 驱动。
  @override
  // ignore: must_call_super
  Future<void> performReassemble() async {
    buildOwner!.reassemble(rootElement!);
  }
}

class _ThemeService extends ThemeService {
  ThemeType? selected;

  @override
  void switchTheme(ThemeType type) {
    selected = type;
    rxCurrentThemeType.value = type;
  }
}

void main() {
  _SettingsTestBinding();
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('切换主题不再联动语言', (tester) async {
    final service = Get.put<ThemeService>(_ThemeService()) as _ThemeService;
    await tester.pumpWidget(GetCupertinoApp(
      locale: const Locale('zh', 'CN'),
      translations: LocalizedStrings(),
      home: const ThemeSettingPage(),
    ));
    for (final type in ThemeType.values) {
      await tester.tap(find.text(type.title));
      await tester.pumpAndSettle();
      expect(service.selected, type);
      expect(Get.locale, const Locale('zh', 'CN'));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('语言页切换三种语言且不修改主题', (tester) async {
    final service = Get.put<ThemeService>(_ThemeService()) as _ThemeService;
    await tester.pumpWidget(GetCupertinoApp(
      locale: const Locale('zh', 'CN'),
      translations: LocalizedStrings(),
      home: const LanguageSettingPage(),
    ));
    for (final language in {
      'English': const Locale('en', 'US'),
      'Français': const Locale('fr', 'FR'),
      '简体中文': const Locale('zh', 'CN'),
    }.entries) {
      await tester.tap(find.text(language.key));
      await tester.pumpAndSettle();
      expect(Get.locale, language.value);
      expect(find.text('language_setting'.tr), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(service.selected, isNull);
      expect(service.rxCurrentThemeType.value, ThemeType.light);
    }
    expect(tester.takeException(), isNull);
  });

  test('游客与登录菜单均提供独立入口及路由', () {
    for (final items in [
      Extension.visitorDataSource,
      Extension.userDataSource
    ]) {
      expect(items, containsAll([My.themeSetting, My.languageSetting]));
    }
    expect(My.languageSetting.path, Routes.languageSetting);
    expect(
        Routes.routePage
            .singleWhere((page) => page.name == Routes.languageSetting)
            .page(),
        isA<LanguageSettingPage>());
  });
}
