import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/pages/web/repository/web_repository.dart';
import 'package:getx_study/enum/collect_action_type.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/base/class_name.dart' as Func;
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';

class WebController extends BaseRequestController<WebRepository, Object?> {
  void Function(CollectActionType, IWebLoadInfo)? collectActionCallback;

  late final WebViewController webViewController;

  late final RefreshController refreshController;

  final canGoBack = false.obs;

  var _actionTag = 0;

  IWebLoadInfo? _webLoadInfo;

  CollectActionType? _type;

  String? className;

  @override
  void onInit() {
    super.onInit();
    refreshController = Get.find(tag: Func.className(WebController));
  }

  @override
  void onClose() {
    super.onClose();
    EasyLoading.dismiss();
    doCollectAction();
  }

  void flutterWebViewSetting(IWebLoadInfo webLoadInfo) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController webViewController =
        WebViewController.fromPlatformCreationParams(params);

    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            logger.d('WebView is loading (progress : $progress%)');
            EasyLoading.showProgress((progress / 100).toDouble(),
                maskType: EasyLoadingMaskType.none);
          },
          onPageStarted: (String url) {
            logger.d('Page started loading: $url');
            //refreshController.requestRefresh();
          },
          onPageFinished: (String url) {
            logger.d('Page finished loading: $url');
            EasyLoading.dismiss();
            //refreshController.refreshCompleted();

            /// 在onPageFinished监听canGoBack()属性变化
            webViewController.canGoBack().then((value) {
              canGoBack.value = value;
              if (value) {
                logger.d("可以返回上一个Web页面");
              } else {
                logger.d("可以返回上一个Page页面");
              }
            });
          },
          onWebResourceError: (WebResourceError error) {
            logger.d('''
                Page resource error:
                  code: ${error.errorCode}
                  description: ${error.description}
                  errorType: ${error.errorType}
                  isForMainFrame: ${error.isForMainFrame}
                          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // 阻止百度导航（原逻辑）
            if (url.startsWith('https://www.baidu.com/')) {
              logger.d('blocking navigation to $url');
              return NavigationDecision.prevent;
            }

            // 处理自定义 scheme URL（如 snssdk2606://、weixin:// 等）
            if (_isCustomScheme(url)) {
              logger.d('检测到自定义 scheme URL: $url');
              _launchExternalApp(url);
              return NavigationDecision.prevent;
            }

            logger.d('allowing navigation to $url');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(webLoadInfo.link.toString()));

    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    /// 在这里设置iOS的Web侧滑手势
    if (webViewController.platform is WebKitWebViewController) {
      (webViewController.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }
    this.webViewController = webViewController;
  }

  Future<bool> unCollectAction({required int originId}) async {
    final model = await request.unCollectAction(originId: originId);

    String message;
    if (model.isSuccess) {
      if ((AccountService.find.info?.collectIds ?? []).contains(originId)) {
        (AccountService.find.info?.collectIds ?? []).remove(originId);
      }
      message = "取消收藏成功";
      _actionTag = _actionTag - 1;
      _type = CollectActionType.unCollect;
    } else {
      message = model.errorMsg.toString();
    }

    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );

    return model.isSuccess;
  }

  Future<bool> collectAction({required int originId}) async {
    final model = await request.collectAction(originId: originId);

    String message;
    if (model.isSuccess) {
      (AccountService.find.info?.collectIds ?? []).add(originId);
      message = "收藏成功";
      _actionTag = _actionTag + 1;
      _type = CollectActionType.collect;
    } else {
      message = model.errorMsg.toString();
    }

    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );

    return model.isSuccess;
  }

  bool isCollect(IWebLoadInfo webLoadInfo) {
    final collectId = _realCollectId(webLoadInfo);
    final collectIds = AccountService.find.info?.collectIds;
    if (collectIds != null && collectId != null) {
      if (collectIds.contains(collectId)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  int? _realCollectId(IWebLoadInfo webLoadInfo) {
    final id = webLoadInfo.id;
    final collectId = webLoadInfo.originId;
    if (collectId == null && id != null) {
      return id;
    } else {
      return collectId;
    }
  }

  void onRefresh() => webViewController.reload();

  Future<bool> collectOrUnCollectAction(
      {required IWebLoadInfo webLoadInfo, required bool isCollect}) async {
    final collectId = _realCollectId(webLoadInfo);
    _webLoadInfo = webLoadInfo;
    if (collectId != null) {
      if (isCollect) {
        final result = await unCollectAction(originId: collectId);
        return !result;
      } else {
        final result = await collectAction(originId: collectId);
        return result;
      }
    } else {
      return false;
    }
  }

  void doCollectAction() {
    if (className == "MyCollectPage") {
      if (_actionTag != 0) {
        if (_webLoadInfo != null && _type != null) {
          final myCollectController = Get.find<MyCollectController>();
          switch (_type!) {
            case CollectActionType.unCollect:
              myCollectController.removeUnCollectItem(_webLoadInfo!);
              break;
            case CollectActionType.collect:
              break;
          }
        }
      }
    } else {
      logger.d("it is not MyCollectPage, do nothing");
    }
  }

  Future onBackAction() async {
    final canGoback = await webViewController.canGoBack();
    if (canGoback) {
      webViewController.goBack();
      Future.delayed(Duration(seconds: 1), () {
        EasyLoading.dismiss();
      });
    } else {
      Get.back();
    }
  }

  /// 判断是否是自定义 scheme URL
  bool _isCustomScheme(String url) {
    // 根据平台使用不同的 scheme 列表
    final customSchemes = _getPlatformSpecificSchemes();

    try {
      final uri = Uri.parse(url);
      final scheme = uri.scheme.toLowerCase();
      return customSchemes.contains(scheme) ||
             !scheme.startsWith('http'); // 任何非 http/https 的 scheme
    } catch (e) {
      logger.d('解析 URL 失败: $url, error: $e');
      return false;
    }
  }

  /// 获取平台特定的 scheme 列表
  List<String> _getPlatformSpecificSchemes() {
    final isAndroid = Platform.isAndroid;
    final isIOS = Platform.isIOS;

    // 通用 schemes（两个平台都支持）
    final commonSchemes = [
      'weixin',           // 微信
      'alipay',           // 支付宝
      'taobao',           // 淘宝
      'zhihu',            // 知乎
      'bilibili',         // 哔哩哔哩
    ];

    // Android 特有 schemes
    final androidSchemes = [
      'snssdk2606',       // 掘金 Android
      'jdmobile',         // 京东 Android
      'pinduoduo',        // 拼多多 Android
      'mqzone',           // QQ空间 Android
      'mqq',              // 手机QQ Android
      'mqqapi',           // QQ API Android
      'tmall',            // 天猫 Android
      'csj',              // 穿山甲 Android
      'bytedance',        // 字节跳动 Android
      'tbopen',           // 淘宝开放 Android
    ];

    // iOS 特有 schemes
    final iOSSchemes = [
      'juejin',           // 掘金 iOS
      'cn.juejin',        // 掘金 iOS 完整包名前缀
      'snssdk2606',       // 掘金 iOS（与 Android 共用）
      'orz',              // 掘金 iOS 旧 scheme
      'snssdk',           // 抖音 iOS
      'wtloginmqq2',      // QQ iOS
      'mqzonev2',         // QQ空间 iOS
      'pinduoduo',        // 拼多多 iOS
      'jd',               // 京东 iOS
      'tmall',            // 天猫 iOS
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
  Future<void> _launchExternalApp(String url) async {
    try {
      final uri = Uri.parse(url);
      logger.d('尝试拉起外部 App: $url');

      // 检查是否可以启动该 App
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 使用外部应用打开
        );

        if (launched) {
          logger.d('成功拉起外部 App');
          EasyLoading.showToast('正在打开外部应用...');
        } else {
          logger.d('取消拉起外部 App');
          EasyLoading.showToast('已取消打开');
        }
      } else {
        logger.d('无法拉起该 App，可能未安装');
        EasyLoading.showError('未安装对应应用，请先下载安装');

        // 可选：如果无法打开 App，可以尝试跳转到应用商店
        _handleAppNotInstalled(url);
      }
    } catch (e) {
      logger.d('拉起外部 App 异常: $e');
      EasyLoading.showError('打开应用失败');
    }
  }

  /// 处理应用未安装的情况（入口方法，根据平台分发）
  void _handleAppNotInstalled(String url) {
    if (Platform.isAndroid) {
      _handleAppNotInstalledInAndroid(url);
    } else if (Platform.isIOS) {
      _handleAppNotInstalledInIOS(url);
    } else {
      logger.d('未知平台: ${Platform.operatingSystem}');
      EasyLoading.showInfo('未安装对应应用，请先下载');
    }
  }

  /// 处理 Android 平台应用未安装的情况
  void _handleAppNotInstalledInAndroid(String url) {
    if (url.startsWith('snssdk2606')) {
      // 掘金 Android
      EasyLoading.showInfo('未安装掘金 App，正在前往应用商店...');
      _openAndroidAppStore(packageName: 'cn.juejin', appName: '掘金');
    } else if (url.startsWith('snssdk')) {
      // 抖音 Android
      EasyLoading.showInfo('未安装抖音，正在前往应用商店...');
      _openAndroidAppStore(packageName: 'com.ss.android.ugc.aweme', appName: '抖音');
    } else if (url.startsWith('weixin')) {
      // 微信 Android
      EasyLoading.showInfo('未安装微信，请先下载微信');
      _openAndroidAppStore(packageName: 'com.tencent.mm', appName: '微信');
    } else if (url.startsWith('alipay')) {
      // 支付宝 Android
      EasyLoading.showInfo('未安装支付宝，请先下载支付宝');
      _openAndroidAppStore(packageName: 'com.eg.android.AlipayGphone', appName: '支付宝');
    } else if (url.startsWith('bilibili')) {
      // 哔哩哔哩 Android
      EasyLoading.showInfo('未安装哔哩哔哩，请先下载');
      _openAndroidAppStore(packageName: 'tv.danmaku.bili', appName: '哔哩哔哩');
    } else if (url.startsWith('zhihu')) {
      // 知乎 Android
      EasyLoading.showInfo('未安装知乎，请先下载');
      _openAndroidAppStore(packageName: 'com.zhihu.android', appName: '知乎');
    } else if (url.startsWith('taobao')) {
      // 淘宝 Android
      EasyLoading.showInfo('未安装淘宝，请先下载');
      _openAndroidAppStore(packageName: 'com.taobao.taobao', appName: '淘宝');
    } else {
      // 未知应用
      EasyLoading.showInfo('未安装对应应用，请先下载');
    }
  }

  /// 处理 iOS 平台应用未安装的情况
  void _handleAppNotInstalledInIOS(String url) {
    // 注意：判断顺序很重要！更具体的 scheme 要放在前面
    // snssdk2606 要在 snssdk 之前判断，否则会被匹配为抖音

    if (url.startsWith('snssdk2606') || url.startsWith('juejin') || url.startsWith('cn.juejin')) {
      // 掘金 iOS（支持 snssdk2606、juejin、cn.juejin 三种 scheme）
      // 正确的掘金 App Store ID
      EasyLoading.showInfo('未安装掘金 App，正在前往 App Store...');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id1252852573', // 掘金正确的 App Store ID
        appName: '掘金',
      );
    } else if (url.startsWith('snssdk')) {
      // 抖音 iOS（不包含 snssdk2606，因为已经在上面处理）
      EasyLoading.showInfo('未安装抖音，正在前往 App Store...');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id1142110895',
        appName: '抖音',
      );
    } else if (url.startsWith('weixin')) {
      // 微信 iOS
      EasyLoading.showInfo('未安装微信，请先下载微信');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id414478124',
        appName: '微信',
      );
    } else if (url.startsWith('alipay')) {
      // 支付宝 iOS
      EasyLoading.showInfo('未安装支付宝，请先下载支付宝');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id333206289',
        appName: '支付宝',
      );
    } else if (url.startsWith('bilibili')) {
      // 哔哩哔哩 iOS
      EasyLoading.showInfo('未安装哔哩哔哩，请先下载');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id736536022',
        appName: '哔哩哔哩',
      );
    } else if (url.startsWith('zhihu')) {
      // 知乎 iOS
      EasyLoading.showInfo('未安装知乎，请先下载');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id432274380',
        appName: '知乎',
      );
    } else if (url.startsWith('taobao')) {
      // 淘宝 iOS
      EasyLoading.showInfo('未安装淘宝，请先下载');
      _openIOSAppStore(
        appStoreUrl: 'https://apps.apple.com/cn/app/id387682726',
        appName: '淘宝',
      );
    } else {
      // 未知应用
      EasyLoading.showInfo('未安装对应应用，请先下载');
    }
  }

  /// 打开 Android 应用商店
  ///
  /// [packageName] Android 应用包名
  /// [appName] 应用名称（用于日志）
  Future<void> _openAndroidAppStore({
    required String packageName,
    String? appName,
  }) async {
    // 优先使用应用宝（更适合国内用户）
    final storeUrl = 'https://a.app.qq.com/o/simple.jsp?pkgname=$packageName';
    // 备选：Google Play
    // final storeUrl = 'https://play.google.com/store/apps/details?id=$packageName';

    logger.d('正在打开 Android 应用商店: $storeUrl, 应用: ${appName ?? packageName}');

    try {
      final launched = await launchUrl(
        Uri.parse(storeUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        logger.d('无法打开 Android 应用商店');
      }
    } catch (e) {
      logger.d('打开 Android 应用商店异常: $e');
    }
  }

  /// 打开 iOS App Store
  ///
  /// [appStoreUrl] App Store 链接
  /// [appName] 应用名称（用于日志）
  Future<void> _openIOSAppStore({
    required String appStoreUrl,
    String? appName,
  }) async {
    logger.d('正在打开 iOS App Store: $appStoreUrl, 应用: ${appName ?? "未知"}');

    try {
      final launched = await launchUrl(
        Uri.parse(appStoreUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        logger.d('无法打开 iOS App Store');
      }
    } catch (e) {
      logger.d('打开 iOS App Store 异常: $e');
    }
  }

  /// 打开应用商店（支持 iOS 和 Android）
  ///
  /// @deprecated 请使用 [_openAndroidAppStore] 或 [_openIOSAppStore]
  Future<void> _openAppStore({
    String? packageName,  // Android 包名
    String? iosAppStoreUrl,  // iOS App Store 链接
  }) async {
    if (packageName != null && Platform.isAndroid) {
      await _openAndroidAppStore(packageName: packageName);
    } else if (iosAppStoreUrl != null && Platform.isIOS) {
      await _openIOSAppStore(appStoreUrl: iosAppStoreUrl);
    } else {
      logger.d('_openAppStore: 参数不匹配或平台不支持');
    }
  }

  /// 获取应用的 scheme 映射表（用于调试和扩展）
  /// 返回格式: { 'app_name': { 'android_scheme': 'xxx', 'ios_scheme': 'xxx', ... } }
  ///
  /// 注意：snssdk2606 是掘金的 scheme，但同时也会被 startsWith('snssdk') 匹配
  /// 因此在 _handleAppNotInstalledInIOS 中的判断顺序很重要：
  /// 必须先判断 snssdk2606，再判断 snssdk，否则会被匹配为抖音
  Map<String, Map<String, String>> getAppSchemeMapping() {
    return {
      'juejin': {
        'android_scheme': 'snssdk2606',
        'ios_scheme': 'snssdk2606',
        'android_package': 'cn.juejin',
        'ios_bundle': 'cn.juejin',
        'ios_appstore': 'https://apps.apple.com/cn/app/id1252852573', // 掘金正确的 App Store ID
        'name': '稀土掘金',
      },
      'douyin': {
        'adroid_scheme': 'snssdk',
        'ios_scheme': 'snssdk',
        'android_package': 'com.ss.android.ugc.aweme',
        'ios_bundle': 'com.ss.iphone.ugc.Aweme',
        'ios_appstore': 'https://apps.apple.com/cn/app/id1142110895',
        'name': '抖音',
      },
      'weixin': {
        'android_scheme': 'weixin',
        'ios_scheme': 'weixin',
        'android_package': 'com.tencent.mm',
        'ios_bundle': 'com.tencent.xin',
        'ios_appstore': 'https://apps.apple.com/cn/app/id414478124',
        'name': '微信',
      },
      'alipay': {
        'android_scheme': 'alipay',
        'ios_scheme': 'alipay',
        'android_package': 'com.eg.android.AlipayGphone',
        'ios_bundle': 'com.alipay.iphoneclient',
        'ios_appstore': 'https://apps.apple.com/cn/app/id333206289',
        'name': '支付宝',
      },
      'zhihu': {
        'android_scheme': 'zhihu',
        'ios_scheme': 'zhihu',
        'android_package': 'com.zhihu.android',
        'ios_bundle': 'com.zhihu.ios',
        'ios_appstore': 'https://apps.apple.com/cn/app/id432274380',
        'name': '知乎',
      },
      'bilibili': {
        'android_scheme': 'bilibili',
        'ios_scheme': 'bilibili',
        'android_package': 'tv.danmaku.bili',
        'ios_bundle': 'tv.danmaku.bili',
        'ios_appstore': 'https://apps.apple.com/cn/app/id736536022',
        'name': '哔哩哔哩',
      },
      'taobao': {
        'android_scheme': 'taobao',
        'ios_scheme': 'taobao',
        'android_package': 'com.taobao.taobao',
        'ios_bundle': 'com.taobao.taobao4iphone',
        'ios_appstore': 'https://apps.apple.com/cn/app/id387682726',
        'name': '淘宝',
      },
    };
  }

  /// 根据当前平台获取对应的应用信息
  Map<String, String>? getAppInfoForCurrentPlatform(String appName) {
    final mapping = getAppSchemeMapping();
    final appInfo = mapping[appName];

    if (appInfo == null) return null;

    final isAndroid = Platform.isAndroid;
    final isIOS = Platform.isIOS;

    if (isAndroid) {
      return {
        'scheme': appInfo['android_scheme']!,
        'package': appInfo['android_package']!,
        'name': appInfo['name']!,
        'platform': 'android',
      };
    } else if (isIOS) {
      return {
        'scheme': appInfo['ios_scheme']!,
        'bundle': appInfo['ios_bundle']!,
        'appstore': appInfo['ios_appstore']!,
        'name': appInfo['name']!,
        'platform': 'ios',
      };
    }

    return null;
  }
}
