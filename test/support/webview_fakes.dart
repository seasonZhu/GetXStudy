import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class FakeWebViewPlatform extends WebViewPlatform {
  final controllers = <FakeWebViewController>[];
  Completer<void>? setupGate;
  bool failSetup = false;
  FakeNavigationDelegate? delegate;

  @override
  PlatformWebViewController createPlatformWebViewController(
      PlatformWebViewControllerCreationParams params) {
    final controller = FakeWebViewController(params, this);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
          PlatformNavigationDelegateCreationParams params) =>
      delegate = FakeNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      FakeWebViewWidget(params);
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params, this.owner) : super.implementation();
  final FakeWebViewPlatform owner;
  final loads = <Uri>[];
  final histories = <Completer<bool>>[];
  int backCalls = 0;
  int reloadCalls = 0;
  int backgrounds = 0;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {
    if (owner.failSetup) throw StateError('初始化失败');
    await owner.setupGate?.future;
  }

  @override
  Future<void> setBackgroundColor(Color color) async => backgrounds++;

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {}

  @override
  Future<void> loadRequest(LoadRequestParams params) async =>
      loads.add(params.uri);

  @override
  Future<bool> canGoBack() {
    final result = Completer<bool>();
    histories.add(result);
    return result.future;
  }

  @override
  Future<void> goBack() async => backCalls++;

  @override
  Future<void> reload() async => reloadCalls++;
}

class FakeNavigationDelegate extends PlatformNavigationDelegate {
  FakeNavigationDelegate(super.params) : super.implementation();
  late NavigationRequestCallback onNavigation;
  late PageEventCallback onStarted;
  late PageEventCallback onFinished;
  late ProgressCallback onProgress;
  late WebResourceErrorCallback onError;

  @override
  Future<void> setOnNavigationRequest(
      NavigationRequestCallback callback) async {
    onNavigation = callback;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    onStarted = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    onFinished = callback;
  }

  @override
  Future<void> setOnProgress(ProgressCallback callback) async {
    onProgress = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    onError = callback;
  }
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox(key: ValueKey('测试网页'));
}
