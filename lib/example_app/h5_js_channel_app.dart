import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:getx_study/logger/logger.dart';

import 'js_bridge.dart';

class H5JSChannelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      home: AppH5Page(),
    );
  }
}

class AppH5Page extends StatelessWidget {
  late WebViewController _controller;

  final jsBridge = JSBridge();

  AppH5Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _flutterWebViewSetting(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter与JS交互"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.share),
            onPressed: _flutterCallJS,
          ),
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: SafeArea(
        child: Builder(builder: (BuildContext context) {
          return WebViewWidget(
            controller: _controller,
          );
        }),
      ),
    );
  }

  void _flutterWebViewSetting(BuildContext context) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController webController =
        WebViewController.fromPlatformCreationParams(params);

    webController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            logger.d('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            logger.d('Page started loading: $url');
          },
          onPageFinished: (String url) {
            logger.d('Page finished loading: $url');
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
            if (request.url.startsWith('https://www.youtube.com/')) {
              logger.d('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            logger.d('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel("handleMessageFromJS",
          onMessageReceived: (javaScriptMessage) {
        final dict = convert.jsonDecode(javaScriptMessage.message);
        final string = "message from js: $dict";
        logger.d(string);
        EasyLoading.showToast(string);
      })
      ..loadFlutterAsset("assets/html/index.html");

    if (webController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = webController;

    _jsBridgeSetting();
  }

  Future<void> _loadHtmlFromAssets() async {
    String filePath = 'assets/html/index.html';

    String fileText = await rootBundle.loadString(filePath);
    _controller.loadHtmlString(Uri.dataFromString(fileText,
            mimeType: 'text/html',
            encoding: convert.Encoding.getByName('utf-8'))
        .toString());
    logger.d(fileText);
  }

  void _flutterCallJS() async {
    var flutterMap = {
      "type": "commit",
      "message": "this is a message from Flutter"
    };

    var jsonString = convert.jsonEncode(flutterMap);

    /// dart调用js,js方法入参,使用html中注释的方法,基本上所有的类型都可以传
    final javaScriptCallbackResult =
        await _controller.runJavaScriptReturningResult(
            "sendMessageToDiscussList('$jsonString')");
    final string = javaScriptCallbackResult as String;
    logger.d(string);
    EasyLoading.showToast(string);
  }

  void _jsBridgeSetting() {
    jsBridge
      ..setWebViewController(_controller)
      ..addJavaScriptChannel()
      ..registerResponse('/test', (value, next) {
        next('flutter响应消息');
      });

    Function? unsubscribe;
    unsubscribe = jsBridge.subscribe('test', (value) {
      unsubscribe?.call(); // 取消订阅
      /// 6、发布消息事件："test"
      jsBridge.publisher('test', '这是一条订阅消息');
    });
  }
}
