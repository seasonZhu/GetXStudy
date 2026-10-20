// 生成器仅依赖纯 Dart 词条，允许直接用 dart 执行。
// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:io';
import '../lib/i18n/zh_cn.dart';
import '../lib/i18n/en_us.dart';
import '../lib/i18n/fr_fr.dart';

/// 运行 dart run tool/generate_html_localizations.dart 更新本地 HTML 词条。
void main() {
  final catalogs = {
    for (final entry in {'zh_CN': zhCn, 'en_US': enUs, 'fr_FR': frFr}.entries)
      entry.key.split('_').first: {
        for (final text in entry.value.entries)
          if (text.key.startsWith('html.')) text.key: text.value,
      },
  };
  File('assets/html/localization.js')
      .writeAsStringSync('''// 自动生成；请修改 lib/i18n/ 中的源词条。
const appCatalogs = ${jsonEncode(catalogs)};
let appLanguage = 'en';
window.appText = key => appCatalogs[appLanguage][key] || appCatalogs.en[key] || key;
window.setAppLanguage = language => {
  const code = language.replace('_', '-').split('-')[0];
  appLanguage = appCatalogs[code] ? code : 'en';
  document.documentElement.lang = appLanguage === 'zh' ? 'zh-CN' : appLanguage;
  document.querySelectorAll('[data-i18n]').forEach(element => {
    element.textContent = window.appText(element.dataset.i18n);
  });
};
document.addEventListener('DOMContentLoaded', () => {
  window.setAppLanguage(navigator.language || 'en');
});
''');
}
