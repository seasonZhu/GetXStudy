import 'package:get/get.dart';
import 'zh_cn.dart';
import 'en_us.dart';
import 'fr_fr.dart';

class LocalizedStrings extends Translations {
  static const catalogs = <String, Map<String, String>>{
    'zh_CN': zhCn,
    'en_US': enUs,
    'fr_FR': frFr,
  };

  @override
  Map<String, Map<String, String>> get keys => catalogs;
}
