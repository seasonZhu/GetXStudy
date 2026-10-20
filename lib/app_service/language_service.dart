import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言偏好独立于账户和主题，null 表示跟随系统。
class LanguageService extends GetxService with WidgetsBindingObserver {
  static const preferenceKey = 'app.language';
  static const supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('fr', 'FR'),
  ];
  static const languageNames = ['简体中文', 'English', 'Français'];
  static LanguageService get find => Get.find<LanguageService>();

  final selectedLanguage = RxnString();
  final effectiveLocale = const Locale('en', 'US').obs;
  SharedPreferences? _preferences;
  Future<void> _pendingWrite = Future.value();

  static Locale resolve(Iterable<Locale>? locales) {
    for (final locale in locales ?? const <Locale>[]) {
      for (final supported in supportedLocales) {
        if (locale.languageCode == supported.languageCode) return supported;
      }
    }
    return const Locale('en', 'US');
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<LanguageService> init() async {
    _preferences = await SharedPreferences.getInstance();
    final stored = _preferences!.get(preferenceKey);
    selectedLanguage.value =
        supportedLocales.any((l) => l.languageCode == stored)
            ? stored as String
            : null;
    await initializeDateFormatting();
    final locale = _resolveSelection();
    effectiveLocale.value = locale;
    Get.locale = locale;
    return this;
  }

  Locale _resolveSelection() => selectedLanguage.value == null
      ? resolve(PlatformDispatcher.instance.locales)
      : resolve([Locale(selectedLanguage.value!)]);

  Future<void> select(String? languageCode) async {
    assert(languageCode == null ||
        supportedLocales.any((l) => l.languageCode == languageCode));
    selectedLanguage.value = languageCode;
    final locale = _resolveSelection();
    // 按选择顺序排队落盘，避免快速切换时旧偏好最后写入。
    final write = _pendingWrite.then((_) async {
      final preferences =
          _preferences ??= await SharedPreferences.getInstance();
      if (languageCode == null) {
        await preferences.remove(preferenceKey);
      } else {
        await preferences.setString(preferenceKey, languageCode);
      }
    });
    _pendingWrite = write.catchError((Object _) {});
    await _applyLocale(locale);
    await write;
  }

  Future<void> _applyLocale(Locale locale) async {
    // 先同步全局语言，再通知 HTML 等订阅者读取当前语言。
    Get.locale = locale;
    effectiveLocale.value = locale;
    if (Get.context == null) return;
    // 更新现有元素树，不重建导航器或业务控制器。
    await Get.updateLocale(locale);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (selectedLanguage.value != null) return;
    final locale = resolve(locales);
    _applyLocale(locale);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
