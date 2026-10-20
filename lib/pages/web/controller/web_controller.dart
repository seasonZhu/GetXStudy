import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/app_service/collection_service.dart';
import 'package:getx_study/app_service/orientation_service.dart';
import 'package:getx_study/app_service/app_launcher_service.dart';
import 'package:getx_study/logger/logger.dart';

enum WebInitializationStatus { initializing, ready, failed }

class WebController extends GetxController {
  WebController({required this.webLoadInfo, this.hideCollection = false});

  final IWebLoadInfo webLoadInfo;
  final bool hideCollection;
  late final WebViewController webViewController;
  late final Future<void> initialization;
  final initializationStatus = WebInitializationStatus.initializing.obs;
  final canGoBack = false.obs;
  Timer? _dismissTimer;
  int _historyQuery = 0;
  bool _closing = false;
  bool _backInProgress = false;
  bool _exiting = false;

  bool get _active => !_closing && !isClosed;
  CollectionService get collections => Get.find<CollectionService>();

  @override
  void onInit() {
    super.onInit();
    OrientationService.find.enableAutoRotation();
    initialization = _initialize();
  }

  Future<void> _initialize() async {
    try {
      final params = WebViewPlatform.instance is WebKitWebViewPlatform
          ? WebKitWebViewControllerCreationParams(
              allowsInlineMediaPlayback: true,
              mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
            )
          : const PlatformWebViewControllerCreationParams();
      webViewController = WebViewController.fromPlatformCreationParams(params);
      await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
      if (!_active) return;
      await webViewController.setBackgroundColor(const Color(0x00000000));
      if (!_active) return;
      await webViewController.setNavigationDelegate(_navigationDelegate());
      if (!_active) return;
      final platform = webViewController.platform;
      if (platform is AndroidWebViewController) {
        await AndroidWebViewController.enableDebugging(true);
        if (!_active) return;
        await platform.setMediaPlaybackRequiresUserGesture(false);
      } else if (platform is WebKitWebViewController) {
        await platform.setAllowsBackForwardNavigationGestures(true);
      }
      if (!_active) return;
      await webViewController
          .loadRequest(Uri.parse(webLoadInfo.link.toString()));
      if (!_active) return;
      initializationStatus.value = WebInitializationStatus.ready;
    } catch (error) {
      if (!_active) return;
      logger.e(error, null, '网页初始化失败');
      EasyLoading.dismiss();
      initializationStatus.value = WebInitializationStatus.failed;
    }
  }

  NavigationDelegate _navigationDelegate() => NavigationDelegate(
        onProgress: (progress) {
          if (!_active) return;
          logger.d('WebView is loading (progress : $progress%)');
          if (progress == 100) {
            EasyLoading.dismiss();
          } else {
            EasyLoading.showProgress(progress / 100,
                maskType: EasyLoadingMaskType.none);
          }
        },
        onPageStarted: (url) {
          if (!_active) return;
          _historyQuery++;
          logger.d('Page started loading: $url');
        },
        onPageFinished: (url) {
          if (!_active) return;
          logger.d('Page finished loading: $url');
          EasyLoading.dismiss();
          unawaited(_readCanGoBack());
        },
        onWebResourceError: (error) {
          if (!_active) return;
          logger.d('网页加载错误：${error.errorCode} ${error.description}');
        },
        onNavigationRequest: (request) {
          if (!_active) return NavigationDecision.prevent;
          final url = request.url;
          if (url.startsWith('https://www.baidu.com/')) {
            return NavigationDecision.prevent;
          }
          if (AppLauncherService.find.isCustomScheme(url)) {
            unawaited(_launchExternalApp(url));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      );

  Future<bool?> _readCanGoBack() async {
    if (!_active) return null;
    final query = ++_historyQuery;
    try {
      final value = await webViewController.canGoBack();
      if (!_active || query != _historyQuery) return null;
      canGoBack.value = value;
      return value;
    } catch (error) {
      if (_active) logger.e(error, null, '查询网页历史失败');
      return null;
    }
  }

  Future<void> onRefresh() async {
    if (!_active || initializationStatus.value != WebInitializationStatus.ready) {
      return;
    }
    try {
      await webViewController.reload();
    } catch (error) {
      if (_active) logger.e(error, null, '重新加载网页失败');
    }
  }

  Future<void> collectOrUnCollectAction(
      {required IWebLoadInfo webLoadInfo}) async {
    if (isClosed) return;
    final id = webLoadInfo.originId ?? webLoadInfo.id;
    if (id == null) return;
    final revision = collections.account.sessionRevision;
    final target = !collections.isCollected(id);
    final result = await collections.setCollected(id, target);
    if (isClosed || collections.account.sessionRevision != revision) return;
    if (result.type == CollectionResultType.success ||
        result.type == CollectionResultType.failure) {
      Get.snackbar(
          '',
          result.type == CollectionResultType.success
              ? (target ? '收藏成功' : '取消收藏成功')
              : (result.message ?? '操作失败，请重试'),
          duration: const Duration(seconds: 1));
    }
  }

  Future<void> onBackAction() async {
    if (!_active || _backInProgress || _exiting) return;
    _backInProgress = true;
    try {
      final hasHistory =
          initializationStatus.value == WebInitializationStatus.ready
              ? await _readCanGoBack()
              : false;
      if (!_active || hasHistory == null) return;
      if (hasHistory) {
        await webViewController.goBack();
        if (!_active) return;
        _dismissTimer?.cancel();
        _dismissTimer = Timer(const Duration(seconds: 1), () {
          if (_active) EasyLoading.dismiss();
        });
      } else {
        _exiting = true;
        Get.back();
      }
    } catch (error) {
      if (_active) logger.e(error, null, '网页返回失败');
    } finally {
      _backInProgress = false;
    }
  }

  Future<void> _launchExternalApp(String url) =>
      AppLauncherService.find.launchExternalApp(
        url,
        isActive: () => _active,
        onNotInstalled: (url) {
          if (_active) {
            unawaited(AppLauncherService.find.handleAppNotInstalled(url));
          }
        },
      );

  @override
  void onClose() {
    _closing = true;
    _historyQuery++;
    _dismissTimer?.cancel();
    EasyLoading.dismiss();
    OrientationService.find.resetToDefault();
    super.onClose();
  }
}
