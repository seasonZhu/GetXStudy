import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 资源管理类 - 从JSON文件加载配置
///
/// 使用方法：
/// ```dart
/// String appName = AppStrings.of(context).app.name;
/// Color primaryColor = AppColors.primary;
/// double padding = AppDimens.paddingMedium;
/// ```
class AppStrings {
  static Map<String, dynamic>? _strings;

  /// 初始化资源（在main函数中调用）
  static Future<void> init() async {
    _strings ??= await _loadJson('assets/config/strings_zh.json');
  }

  /// 获取字符串资源
  static Map<String, dynamic> of(BuildContext context) {
    if (_strings == null) {
      throw Exception('AppStrings 未初始化！请在 main() 中调用 await AppStrings.init()');
    }
    return _strings!;
  }

  /// 直接访问（不依赖context）
  static Map<String, dynamic> get direct {
    if (_strings == null) {
      throw Exception('AppStrings 未初始化！请在 main() 中调用 await AppStrings.init()');
    }
    return _strings!;
  }

  /// 快捷访问方法
  static String get appName => direct['app']['name'];

  // Common
  static String get loading => direct['common']['loading'];
  static String get success => direct['common']['success'];
  static String get error => direct['common']['error'];
  static String get retry => direct['common']['retry'];
  static String get confirm => direct['common']['confirm'];
  static String get cancel => direct['common']['cancel'];
  static String get close => direct['common']['close'];
  static String get next => direct['common']['next'];
  static String get tip => direct['common']['tip'];
  static String get logoutConfirm => direct['common']['logout_confirm'];

  // Network
  static String get networkErrorTimeout => direct['network']['error_timeout'];
  static String get networkErrorConnection => direct['network']['error_connection'];
  static String get networkErrorServer => direct['network']['error_server'];
  static String get networkError401 => direct['network']['error_401'];
  static String get networkError403 => direct['network']['error_403'];
  static String get networkError404 => direct['network']['error_404'];

  // Login
  static String get loginTitle => direct['login']['title'];
  static String get loginUsername => direct['login']['username'];
  static String get loginPassword => direct['login']['password'];
  static String get loginUsernameHint => direct['login']['username_hint'];
  static String get loginPasswordHint => direct['login']['password_hint'];
  static String get loginButton => direct['login']['button'];
  static String get loginRegisterLink => direct['login']['register_link'];
  static String get loginSuccess => direct['login']['success'];
  static String get loginFailed => direct['login']['failed'];
  static String get autoLoginSuccess => direct['login']['auto_login_success'];
  static String get autoLoginFailed => direct['login']['auto_login_failed'];
  static String get logoutSuccess => direct['login']['logout_success'];
  static String get logoutFailed => direct['login']['logout_failed'];

  // Register
  static String get registerTitle => direct['register']['title'];
  static String get registerUsername => direct['register']['username'];
  static String get registerPassword => direct['register']['password'];
  static String get registerRepassword => direct['register']['repassword'];
  static String get registerButton => direct['register']['button'];
  static String get registerSuccess => direct['register']['success'];
  static String get registerFailed => direct['register']['failed'];

  // Home
  static String get homeTitle => direct['home']['title'];
  static String get homeSearchHint => direct['home']['search_hint'];

  // My
  static String get myTitle => direct['my']['title'];
  static String get myCoins => direct['my']['coins'];
  static String get myCollect => direct['my']['collect'];
  static String get myShare => direct['my']['share'];
  static String get myGithub => direct['my']['github'];
  static String get myJuejin => direct['my']['juejin'];
  static String get myLogout => direct['my']['logout'];

  // Coin
  static String get coinTitle => direct['coin']['title'];

  // Collect
  static String get collectTitle => direct['collect']['title'];
  static String get cancelCollectSuccess => direct['collect']['cancel_success'];
  static String get collectSuccess => direct['collect']['collect_success'];

  // Tree
  static String get treeTitle => direct['tree']['title'];

  // Refresh
  static String get refreshPullComplete => direct['refresh']['pull_complete'];
  static String get refreshLoadMore => direct['refresh']['load_more'];
  static String get refreshReleaseToLoad => direct['refresh']['release_to_load'];
  static String get refreshNoMoreData => direct['refresh']['no_more_data'];

  // Page
  static String get pageUnknown => direct['page']['unknown'];
  static String get pageEnter => direct['page']['enter'];

  static Future<Map<String, dynamic>> _loadJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString) as Map<String, dynamic>;
  }
}

/// 颜色资源类
class AppColors {
  static Map<String, dynamic>? _colors;

  static Future<void> init() async {
    _colors ??= await _loadJson('assets/config/colors.json');
  }

  static Map<String, dynamic> get direct {
    if (_colors == null) {
      throw Exception('AppColors 未初始化！请在 main() 中调用 await AppColors.init()');
    }
    return _colors!;
  }

  // 快捷访问 - 自动转换为Color对象
  static Color get primary => _parseColor(direct['colors']['primary']);
  static Color get primaryDark => _parseColor(direct['colors']['primaryDark']);
  static Color get secondary => _parseColor(direct['colors']['secondary']);
  static Color get success => _parseColor(direct['colors']['success']);
  static Color get warning => _parseColor(direct['colors']['warning']);
  static Color get error => _parseColor(direct['colors']['error']);
  static Color get info => _parseColor(direct['colors']['info']);
  static Color get white => _parseColor(direct['colors']['white']);
  static Color get black => _parseColor(direct['colors']['black']);
  static Color get transparent => _parseColor(direct['colors']['transparent']);
  static Color get grey50 => _parseColor(direct['colors']['grey50']);
  static Color get grey100 => _parseColor(direct['colors']['grey100']);
  static Color get grey200 => _parseColor(direct['colors']['grey200']);
  static Color get grey300 => _parseColor(direct['colors']['grey300']);
  static Color get grey400 => _parseColor(direct['colors']['grey400']);
  static Color get grey500 => _parseColor(direct['colors']['grey500']);
  static Color get grey600 => _parseColor(direct['colors']['grey600']);
  static Color get grey700 => _parseColor(direct['colors']['grey700']);
  static Color get grey800 => _parseColor(direct['colors']['grey800']);
  static Color get grey900 => _parseColor(direct['colors']['grey900']);

  static Color _parseColor(String colorString) {
    return Color(
      int.parse(colorString.replaceAll('#', '0xFF')),
    );
  }

  static Future<Map<String, dynamic>> _loadJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString) as Map<String, dynamic>;
  }
}

/// 尺寸资源类
class AppDimens {
  static Map<String, dynamic>? _dimens;

  static Future<void> init() async {
    _dimens ??= await _loadJson('assets/config/dimens.json');
  }

  static Map<String, dynamic> get direct {
    if (_dimens == null) {
      throw Exception('AppDimens 未初始化！请在 main() 中调用 await AppDimens.init()');
    }
    return _dimens!;
  }

  // Padding
  static double get paddingTiny => direct['dimens']['padding_tiny'].toDouble();
  static double get paddingSmall => direct['dimens']['padding_small'].toDouble();
  static double get paddingMedium => direct['dimens']['padding_medium'].toDouble();
  static double get paddingLarge => direct['dimens']['padding_large'].toDouble();
  static double get paddingXlarge => direct['dimens']['padding_xlarge'].toDouble();

  // Font Size
  static double get fontSizeTiny => direct['dimens']['font_size_tiny'].toDouble();
  static double get fontSizeSmall => direct['dimens']['font_size_small'].toDouble();
  static double get fontSizeMedium => direct['dimens']['font_size_medium'].toDouble();
  static double get fontSizeLarge => direct['dimens']['font_size_large'].toDouble();
  static double get fontSizeXlarge => direct['dimens']['font_size_xlarge'].toDouble();
  static double get fontSizeXxlarge => direct['dimens']['font_size_xxlarge'].toDouble();

  // Radius
  static double get radiusSmall => direct['dimens']['radius_small'].toDouble();
  static double get radiusMedium => direct['dimens']['radius_medium'].toDouble();
  static double get radiusLarge => direct['dimens']['radius_large'].toDouble();
  static double get radiusXlarge => direct['dimens']['radius_xlarge'].toDouble();

  // Icon Size
  static double get iconSmall => direct['dimens']['icon_small'].toDouble();
  static double get iconMedium => direct['dimens']['icon_medium'].toDouble();
  static double get iconLarge => direct['dimens']['icon_large'].toDouble();
  static double get iconXlarge => direct['dimens']['icon_xlarge'].toDouble();

  // Component Height
  static double get buttonHeight => direct['dimens']['button_height'].toDouble();
  static double get inputHeight => direct['dimens']['input_height'].toDouble();
  static double get appBarHeight => direct['dimens']['app_bar_height'].toDouble();

  static Future<Map<String, dynamic>> _loadJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString) as Map<String, dynamic>;
  }
}

/// 统一初始化所有资源
class AppResources {
  static Future<void> init() async {
    await Future.wait([
      AppStrings.init(),
      AppColors.init(),
      AppDimens.init(),
    ]);
  }
}
