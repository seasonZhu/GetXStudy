import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'localized_strings.dart';

/// 自有文案统一入口，不在控制器中缓存已经翻译的界面字符串。
class AppText {
  AppText._();

  static Locale get locale => Get.locale ?? const Locale('zh', 'CN');

  static String t(String key, [Map<String, String> params = const {}]) {
    final language = switch (locale.languageCode) {
      'zh' => 'zh_CN',
      'fr' => 'fr_FR',
      _ => 'en_US',
    };
    final text = LocalizedStrings.catalogs[language]?[key] ??
        LocalizedStrings.catalogs['en_US']![key] ??
        key;
    return text.replaceAllMapped(
        RegExp(r'@(\w+)'), (match) => params[match[1]] ?? match[0]!);
  }

  static String number(num? value) => value == null
      ? '--'
      : NumberFormat.decimalPattern(locale.toString()).format(value);

  static String date(int milliseconds) => DateFormat.yMMMd(locale.toString())
      .format(DateTime.fromMillisecondsSinceEpoch(milliseconds));

  static String seconds(int count) {
    // 法语的 0 和 1 使用单数；中文只有一种数量形式。
    final singular = count == 1 || (locale.languageCode == 'fr' && count == 0);
    return t('duration.seconds_${singular ? 'one' : 'other'}',
        {'count': number(count)});
  }
}
