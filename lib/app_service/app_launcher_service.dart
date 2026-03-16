import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// 外部应用启动服务
///
/// 提供外部 App 跳转、应用商店跳转等功能
///
/// 使用方式：
/// ```dart
/// // 判断是否是自定义 scheme
/// final isCustom = AppLauncherService.find.isCustomScheme('weixin://...');
///
/// // 启动外部 App
/// await AppLauncherService.find.launchExternalApp('weixin://');
///
/// // 处理 App 未安装的情况
/// await AppLauncherService.find.handleAppNotInstalled('weixin://');
/// ```
class AppLauncherService extends GetxService {
  static AppLauncherService get find => Get.find<AppLauncherService>();

  final _logger = Logger();

  /// 判断是否是自定义 scheme URL
  ///
  /// [url] 要检查的 URL
  /// [customSchemes] 可选的自定义 scheme 列表，默认使用内置列表
  bool isCustomScheme(String url, {List<String>? customSchemes}) {
    // 边界情况处理
    if (url.isEmpty) {
      return false;
    }

    // 获取 schemes 并转换为小写
    final schemes = (customSchemes ?? _getPlatformSpecificSchemes())
        .map((s) => s.toLowerCase())
        .toList();

    try {
      final uri = Uri.parse(url);
      final scheme = uri.scheme.toLowerCase();

      // 无效的 scheme（如解析失败）返回 false
      if (scheme.isEmpty) {
        return false;
      }

      return schemes.contains(scheme) || !scheme.startsWith('http');
    } catch (e) {
      _logger.d('解析 URL 失败: $url, error: $e');
      return false;
    }
  }

  /// 获取平台特定的 scheme 列表
  List<String> _getPlatformSpecificSchemes() {
    final isAndroid = Platform.isAndroid;
    final isIOS = Platform.isIOS;

    // 通用 schemes
    const commonSchemes = [
      'weixin',
      'alipay',
      'taobao',
      'zhihu',
      'bilibili',
    ];

    // Android 特有 schemes
    const androidSchemes = [
      'snssdk2606',
      'jdmobile',
      'pinduoduo',
      'mqzone',
      'mqq',
      'mqqapi',
      'tmall',
      'csj',
      'bytedance',
      'tbopen',
    ];

    // iOS 特有 schemes
    const iOSSchemes = [
      'juejin',
      'cn.juejin',
      'snssdk2606',
      'orz',
      'snssdk',
      'wtloginmqq2',
      'mqzonev2',
      'pinduoduo',
      'jd',
      'tmall',
    ];

    if (isAndroid) {
      return [...commonSchemes, ...androidSchemes];
    } else if (isIOS) {
      return [...commonSchemes, ...iOSSchemes];
    } else {
      return commonSchemes;
    }
  }

  /// 拉起外部 App
  ///
  /// [url] 要打开的 URL
  /// [onNotInstalled] App 未安装时的回调，可选
  Future<void> launchExternalApp(
    String url, {
    void Function(String url)? onNotInstalled,
  }) async {
    try {
      final uri = Uri.parse(url);
      _logger.d('尝试拉起外部 App: $url');

      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          _logger.d('成功拉起外部 App');
          EasyLoading.showToast('正在打开外部应用...');
        } else {
          _logger.d('取消拉起外部 App');
          EasyLoading.showToast('已取消打开');
        }
      } else {
        _logger.d('无法拉起该 App，可能未安装');
        EasyLoading.showError('未安装对应应用，请先下载安装');
        onNotInstalled?.call(url);
      }
    } catch (e) {
      _logger.d('拉起外部 App 异常: $e');
      EasyLoading.showError('打开应用失败');
    }
  }

  /// 处理应用未安装的情况
  ///
  /// [url] 要打开的 URL
  Future<void> handleAppNotInstalled(String url) async {
    if (Platform.isAndroid) {
      await _handleAndroidAppNotInstalled(url);
    } else if (Platform.isIOS) {
      await _handleIOSAppNotInstalled(url);
    } else {
      _logger.d('未知平台: ${Platform.operatingSystem}');
      EasyLoading.showInfo('未安装对应应用，请先下载');
    }
  }

  /// 处理 Android 平台应用未安装的情况
  Future<void> _handleAndroidAppNotInstalled(String url) async {
    if (url.startsWith('snssdk2606')) {
      EasyLoading.showInfo('未安装掘金 App，正在前往应用商店...');
      await _openAndroidAppStore(packageName: 'cn.juejin', appName: '掘金');
    } else if (url.startsWith('snssdk')) {
      EasyLoading.showInfo('未安装抖音，正在前往应用商店...');
      await _openAndroidAppStore(
        packageName: 'com.ss.android.ugc.aweme',
        appName: '抖音',
      );
    } else if (url.startsWith('weixin')) {
      EasyLoading.showInfo('未安装微信，请先下载微信');
      await _openAndroidAppStore(
        packageName: 'com.tencent.mm',
        appName: '微信',
      );
    } else if (url.startsWith('alipay')) {
      EasyLoading.showInfo('未安装支付宝，请先下载支付宝');
      await _openAndroidAppStore(
        packageName: 'com.eg.android.AlipayGphone',
        appName: '支付宝',
      );
    } else if (url.startsWith('bilibili')) {
      EasyLoading.showInfo('未安装哔哩哔哩，请先下载');
      await _openAndroidAppStore(
        packageName: 'tv.danmaku.bili',
        appName: '哔哩哔哩',
      );
    } else if (url.startsWith('zhihu')) {
      EasyLoading.showInfo('未安装知乎，请先下载');
      await _openAndroidAppStore(
        packageName: 'com.zhihu.android',
        appName: '知乎',
      );
    } else if (url.startsWith('taobao')) {
      EasyLoading.showInfo('未安装淘宝，请先下载');
      await _openAndroidAppStore(
        packageName: 'com.taobao.taobao',
        appName: '淘宝',
      );
    } else {
      EasyLoading.showInfo('未安装对应应用，请先下载');
    }
  }

  /// 处理 iOS 平台应用未安装的情况
  Future<void> _handleIOSAppNotInstalled(String url) async {
    // 注意：判断顺序很重要！更具体的 scheme 要放在前面
    if (url.startsWith('snssdk2606') ||
        url.startsWith('juejin') ||
        url.startsWith('cn.juejin')) {
      EasyLoading.showInfo('未安装掘金 App，正在前往 App Store...');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id1252852573',
        appName: '掘金',
      );
    } else if (url.startsWith('snssdk')) {
      EasyLoading.showInfo('未安装抖音，正在前往 App Store...');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id1142110895',
        appName: '抖音',
      );
    } else if (url.startsWith('weixin')) {
      EasyLoading.showInfo('未安装微信，请先下载微信');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id414478124',
        appName: '微信',
      );
    } else if (url.startsWith('alipay')) {
      EasyLoading.showInfo('未安装支付宝，请先下载支付宝');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id333206289',
        appName: '支付宝',
      );
    } else if (url.startsWith('bilibili')) {
      EasyLoading.showInfo('未安装哔哩哔哩，请先下载');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id736536022',
        appName: '哔哩哔哩',
      );
    } else if (url.startsWith('zhihu')) {
      EasyLoading.showInfo('未安装知乎，请先下载');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id432274380',
        appName: '知乎',
      );
    } else if (url.startsWith('taobao')) {
      EasyLoading.showInfo('未安装淘宝，请先下载');
      await _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id387682726',
        appName: '淘宝',
      );
    } else {
      EasyLoading.showInfo('未安装对应应用，请先下载');
    }
  }

  /// 打开 Android 应用商店
  ///
  /// [packageName] Android 应用包名
  /// [appName] 应用名称
  Future<void> _openAndroidAppStore({
    required String packageName,
    String? appName,
  }) async {
    // 优先使用应用宝（更适合国内用户）
    final storeUrl =
        'https://a.app.qq.com/o/simple.jsp?pkgname=$packageName';
    // 备选：Google Play
    // final storeUrl = 'https://play.google.com/store/apps/details?id=$packageName';

    _logger.d('正在打开 Android 应用商店: $storeUrl, 应用: ${appName ?? packageName}');

    try {
      final launched = await launchUrl(
        Uri.parse(storeUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _logger.d('无法打开 Android 应用商店');
      }
    } catch (e) {
      _logger.d('打开 Android 应用商店异常: $e');
    }
  }

  /// 打开 iOS App Store
  ///
  /// [appStoreUrl] App Store 链接
  /// [appName] 应用名称
  Future<void> _openIOSAppStore({
    required String appStoreUrl,
    String? appName,
  }) async {
    _logger.d('正在打开 iOS App Store: $appStoreUrl, 应用: ${appName ?? "未知"}');

    try {
      final launched = await launchUrl(
        Uri.parse(appStoreUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _logger.d('无法打开 iOS App Store');
      }
    } catch (e) {
      _logger.d('打开 iOS App Store 异常: $e');
    }
  }

  /// 获取应用的 scheme 映射表
  Map<String, AppInfo> get appSchemeMapping {
    return _appInfoMap;
  }

  /// 根据应用名称获取当前平台的应用信息
  AppInfo? getAppInfoForCurrentPlatform(String appName) {
    final appInfo = _appInfoMap[appName];
    if (appInfo == null) return null;

    final isAndroid = Platform.isAndroid;
    final isIOS = Platform.isIOS;

    if (isAndroid) {
      return AppInfo(
        scheme: appInfo.androidScheme,
        package: appInfo.androidPackage,
        name: appInfo.name,
        platform: 'android',
      );
    } else if (isIOS) {
      return AppInfo(
        scheme: appInfo.iosScheme,
        bundle: appInfo.iosBundle,
        appStoreUrl: appInfo.iosAppStoreUrl,
        name: appInfo.name,
        platform: 'ios',
      );
    }

    return null;
  }

  static final Map<String, AppInfo> _appInfoMap = {
    'juejin': AppInfo(
      androidScheme: 'snssdk2606',
      iosScheme: 'snssdk2606',
      androidPackage: 'cn.juejin',
      iosBundle: 'cn.juejin',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id1252852573',
      name: '稀土掘金',
    ),
    'douyin': AppInfo(
      androidScheme: 'snssdk',
      iosScheme: 'snssdk',
      androidPackage: 'com.ss.android.ugc.aweme',
      iosBundle: 'com.ss.iphone.ugc.Aweme',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id1142110895',
      name: '抖音',
    ),
    'weixin': AppInfo(
      androidScheme: 'weixin',
      iosScheme: 'weixin',
      androidPackage: 'com.tencent.mm',
      iosBundle: 'com.tencent.xin',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id414478124',
      name: '微信',
    ),
    'alipay': AppInfo(
      androidScheme: 'alipay',
      iosScheme: 'alipay',
      androidPackage: 'com.eg.android.AlipayGphone',
      iosBundle: 'com.alipay.iphoneclient',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id333206289',
      name: '支付宝',
    ),
    'zhihu': AppInfo(
      androidScheme: 'zhihu',
      iosScheme: 'zhihu',
      androidPackage: 'com.zhihu.android',
      iosBundle: 'com.zhihu.ios',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id432274380',
      name: '知乎',
    ),
    'bilibili': AppInfo(
      androidScheme: 'bilibili',
      iosScheme: 'bilibili',
      androidPackage: 'tv.danmaku.bili',
      iosBundle: 'tv.danmaku.bili',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id736536022',
      name: '哔哩哔哩',
    ),
    'taobao': AppInfo(
      androidScheme: 'taobao',
      iosScheme: 'taobao',
      androidPackage: 'com.taobao.taobao',
      iosBundle: 'com.taobao.taobao4iphone',
      iosAppStoreUrl: 'https://apps.apple.com/cn/app/id387682726',
      name: '淘宝',
    ),
  };
}

/// 应用信息
class AppInfo {
  final String? scheme;
  final String? androidScheme;
  final String? iosScheme;
  final String? package;
  final String? androidPackage;
  final String? bundle;
  final String? iosBundle;
  final String? appStoreUrl;
  final String? iosAppStoreUrl;
  final String? name;
  final String? platform;

  const AppInfo({
    this.scheme,
    this.androidScheme,
    this.iosScheme,
    this.package,
    this.androidPackage,
    this.bundle,
    this.iosBundle,
    this.appStoreUrl,
    this.iosAppStoreUrl,
    this.name,
    this.platform,
  });
}
