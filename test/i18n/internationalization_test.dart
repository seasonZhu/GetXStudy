import 'dart:convert';
import 'dart:io';
import 'package:getx_study/example_app/stream_app.dart';
import 'package:getx_study/example_app/rx_dart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/language_service.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/enum/main_tag_type.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'package:getx_study/i18n/app_text.dart';
import 'package:getx_study/i18n/localized_strings.dart';
import 'package:getx_study/pages/common/empty_view.dart';
import 'package:getx_study/pages/common/error_view.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/pages/common/loading_view.dart';
import 'package:getx_study/pages/home/view/search_text_field.dart';
import 'package:getx_study/pages/my/controller/login_controller.dart';
import 'package:getx_study/pages/my/controller/register_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/pages/my/view/language_setting_page.dart';
import 'package:getx_study/pages/my/view/login_page.dart';
import 'package:getx_study/pages/my/view/register_page.dart';
import 'package:getx_study/pages/my/view/theme_setting_page.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/resource/app_resources.dart';
import 'package:getx_study/pages/launch/welcome_page.dart';

/// 测试中在 pump 时重建，避免 GetX 的 reassemble 引起帧重入。
class _LocaleBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  // ignore: must_call_super
  Future<void> performReassemble() async {
    buildOwner!.reassemble(rootElement!);
  }
}

void main() {
  _LocaleBinding();
  setUp(() {
    Get.testMode = true;
    Get.locale = null;
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    Get.reset();
    Get.locale = null;
  });

  test('三语词条完整、非空且参数一致', () {
    final catalogs = LocalizedStrings.catalogs;
    final keys = catalogs['en_US']!.keys.toSet();
    Set<String> parameters(String value) =>
        RegExp(r'@(\w+)').allMatches(value).map((match) => match[1]!).toSet();
    for (final catalog in catalogs.entries) {
      expect(catalog.value.keys.toSet(), keys, reason: catalog.key);
      for (final key in keys) {
        expect(catalog.value[key]!.trim(), isNotEmpty,
            reason: '$key/${catalog.key}');
        expect(parameters(catalog.value[key]!),
            parameters(catalogs['en_US']![key]!),
            reason: key);
        if (catalog.key != 'zh_CN' && key != 'app.name') {
          expect(
              RegExp(r'[\u4e00-\u9fff]').hasMatch(catalog.value[key]!), isFalse,
              reason: key);
        }
      }
    }
  });

  test('所有直接引用的翻译键都存在', () {
    final pattern = RegExp(r'''AppText\.t\(['"]([^'"]+)['"]''');
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      for (final match in pattern.allMatches(file.readAsStringSync())) {
        final key = match[1]!;
        if (key.contains(r'$')) continue;
        expect(LocalizedStrings.catalogs['en_US'], contains(key),
            reason: '${file.path}: $key');
      }
    }
  });

  test('本地 HTML 的生成词条与应用词条一致', () {
    final source = File('assets/html/localization.js').readAsStringSync();
    final generated =
        jsonDecode(source.split('const appCatalogs = ')[1].split(';\n')[0])
            as Map;
    for (final entry in LocalizedStrings.catalogs.entries) {
      final expected = Map.fromEntries(
          entry.value.entries.where((e) => e.key.startsWith('html.')));
      expect(generated[entry.key.split('_').first], expected);
    }
  });

  test('地区变体匹配与不支持语言回退', () {
    expect(LanguageService.resolve([const Locale('fr', 'CA')]),
        const Locale('fr', 'FR'));
    expect(LanguageService.resolve([const Locale('zh', 'TW')]),
        const Locale('zh', 'CN'));
    expect(LanguageService.resolve([const Locale('en', 'GB')]),
        const Locale('en', 'US'));
    expect(LanguageService.resolve([const Locale('de')]),
        const Locale('en', 'US'));
    expect(LanguageService.resolve([const Locale('de'), const Locale('fr')]),
        const Locale('fr', 'FR'));
    expect(LanguageService.resolve(null), const Locale('en', 'US'));
  });

  for (final stored in [null, 'de', 123, 'fr']) {
    test('启动恢复偏好 $stored，失效偏好使用系统语言', () async {
      SharedPreferences.setMockInitialValues(
          {if (stored != null) LanguageService.preferenceKey: stored});
      final service = await Get.put(LanguageService()).init();
      expect(service.selectedLanguage.value, stored == 'fr' ? 'fr' : null);
      expect(Get.locale, service.effectiveLocale.value);
      if (stored == 'fr') expect(Get.locale, const Locale('fr', 'FR'));
    });
  }

  test('语言偏好持久化、恢复与快速切换顺序', () async {
    final service = await Get.put(LanguageService()).init();
    await Future.wait(
        [service.select('zh'), service.select('en'), service.select('fr')]);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(LanguageService.preferenceKey), 'fr');
    await Get.delete<LanguageService>(force: true);
    final restored = await Get.put(LanguageService()).init();
    expect(restored.effectiveLocale.value, const Locale('fr', 'FR'));
    await restored.select(null);
    expect(preferences.containsKey(LanguageService.preferenceKey), isFalse);
  });

  test('语言通知中的全局语言与事件保持一致', () async {
    final service = await Get.put(LanguageService()).init();
    final observed = <Locale>[];
    final worker = ever(service.effectiveLocale, (locale) {
      expect(AppText.locale, locale);
      observed.add(locale);
    });
    await service.select('zh');
    await service.select('fr');
    worker.dispose();
    expect(observed.last, const Locale('fr', 'FR'));
  });

  test('系统变化仅影响跟随系统模式', () async {
    final service = await Get.put(LanguageService()).init();
    service.didChangeLocales([const Locale('fr', 'CA')]);
    expect(service.effectiveLocale.value, const Locale('fr', 'FR'));
    await service.select('zh');
    service.didChangeLocales([const Locale('en')]);
    expect(service.effectiveLocale.value, const Locale('zh', 'CN'));
    service.didChangeLocales([const Locale('de')]);
    expect(Get.locale, const Locale('zh', 'CN'));
  });

  test('动态摘要、数字、日期和复数随语言变化', () async {
    await Get.put(LanguageService()).init();
    final account = AccountService()
      ..updateCoinSummary(level: 2, rank: 20, points: 1200);
    Get.locale = const Locale('en', 'US');
    expect(account.userInfo, 'Level 2  Rank 20  Points 1,200');
    expect(AppStrings.loginTitle, 'Log in');
    expect(AppText.seconds(1), '1 second');
    expect(AppText.seconds(2), '2 seconds');
    expect(AppText.t('example.error_detail', {'error': r'$@count'}),
        r'Error: $@count');
    final englishDate =
        AppText.date(DateTime(2026, 10, 20).millisecondsSinceEpoch);
    Get.locale = const Locale('fr', 'FR');
    expect(account.userInfo, contains('Niveau 2'));
    expect(AppStrings.loginTitle, 'Se connecter');
    expect(AppText.seconds(0), '0 seconde');
    expect(AppText.seconds(2), '2 secondes');
    expect(AppText.date(DateTime(2026, 10, 20).millisecondsSinceEpoch),
        isNot(englishDate));
  });

  testWidgets('切换语言保留路由、输入、业务状态与主题', (tester) async {
    final service = await Get.put(LanguageService()).init();
    Get.put(ThemeService());
    final account = Get.put(AccountService()..isLogin = true);
    final searchKey = GlobalKey();
    await tester.pumpWidget(Obx(() => GetCupertinoApp(
          locale: service.effectiveLocale.value,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          translations: LocalizedStrings(),
          home: CupertinoPageScaffold(
              child: Material(
                  type: MaterialType.transparency,
                  child: SearchTextField(
                      key: searchKey, keywordCallback: (_) {}))),
        )));
    await tester.enterText(find.byType(CupertinoTextField), 'Flutter 原文');
    final originalSearch = searchKey.currentState;
    final route = ModalRoute.of(tester.element(find.byType(SearchTextField)));
    final navigator = tester.state(find.byType(Navigator).first);
    for (final code in ['zh', 'en', 'fr']) {
      await service.select(code);
      await tester.pumpAndSettle();
      expect(find.text('Flutter 原文'), findsOneWidget);
      expect(searchKey.currentState, same(originalSearch));
      expect(tester.state(find.byType(Navigator).first), same(navigator));
      expect(ModalRoute.of(tester.element(find.byType(SearchTextField))),
          same(route));
      expect(account.isLogin, isTrue);
      expect(ThemeService.find.rxCurrentThemeType.value, ThemeType.light);
      expect(find.text(AppText.t('search.action')), findsOneWidget);
      expect(MainTagType.home.title, AppText.t('home.title'));
      expect(tester.takeException(), isNull);
    }
  });

  for (final stream in [false, true]) {
    testWidgets('${stream ? "Stream" : "RxDart"} 示例切换语言保留计数', (tester) async {
      final service = await Get.put(LanguageService()).init();
      await tester.pumpWidget(GetMaterialApp(
        home: stream ? const StreamExamplePage() : const RxDartExamplePage(),
      ));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      await service.select('fr');
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text(AppText.t(stream ? 'example.stream' : 'example.rxdart')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in LanguageService.supportedLocales) {
    for (final page in [
      'language',
      'theme',
      'login',
      'register',
      'empty',
      'error',
      'loading',
      'article',
      'welcome'
    ]) {
      testWidgets('${locale.languageCode} $page 窄屏大字体无溢出', (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues(
            {LanguageService.preferenceKey: locale.languageCode});
        await Get.put(LanguageService()).init();
        Get.put(ThemeService());
        Get.put(MyRepository());
        Get.put(LoginController());
        Get.put(RegisterController());
        final widget = switch (page) {
          'language' => const LanguageSettingPage(),
          'theme' => const ThemeSettingPage(),
          'login' => const LoginPage(),
          'register' => const RegisterPage(),
          'empty' => const EmptyView(),
          'error' => const ErrorView(),
          'loading' => const LoadingView(),
          'welcome' => const WelcomePage(),
          _ => InfoCell(
              callback: (_) {},
              model: ArticleInfoDatas()
                ..title = 'Article 原文'
                ..author = 'Very long author name'
                ..fresh = true
                ..type = 1),
        };
        await tester.pumpWidget(GetCupertinoApp(
          locale: locale,
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          translations: LocalizedStrings(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Material(type: MaterialType.transparency, child: widget),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
