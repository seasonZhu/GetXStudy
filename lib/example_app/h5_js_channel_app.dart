import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:getx_study/logger/logger.dart';

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

    /// 在这里设置iOS的Web侧滑手势
    if (webController.platform is WebKitWebViewController) {
      (webController.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }

    _controller = webController;
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
}

/// 返回按钮与侧滑的应用
class OnBackAppH5Page extends StatelessWidget {
  late WebViewController _controller;

  ValueNotifier<bool> canGoBackNotifier = ValueNotifier(false);

  final canGoBackRelay = false.obs;

  OnBackAppH5Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _flutterWebViewSetting(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () async {
            final canGoback = await _controller.canGoBack();
            if (canGoback) {
              _controller.goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text("Flutter与JS交互"),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.share),
            onPressed: () {},
          ),
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: _valueListenableBuilder(),
    );
  }

  Widget _valueListenableBuilder() {
    return ValueListenableBuilder(
      valueListenable: canGoBackNotifier,
      builder: (context, bool canGoBack, child) {
        logger.d("重构了页面, Web可以返回上一页: $canGoBack, 可以侧滑关闭页面: ${!canGoBack}");
        // 达不到控制页面侧滑使能的效果
        // return WillPopScope(
        //   child: _buildBody(),
        //   onWillPop: () => Future.value(!canGoBack),
        // );

        /// 这个完全不能用
        // return PopScope(
        //   canPop: !canGoBack,
        //   onPopInvoked: (didPop) {

        //   },
        //   child: _buildBody(),
        // );

        if (canGoBack) {
          return PopScope(
            canPop: false,
            child: _buildBody(),
          );
        } else {
          return _buildBody();
        }
      },
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Builder(
        builder: (BuildContext context) {
          return WebViewWidget(
            controller: _controller,
          );
        },
      ),
    );
  }

  Widget _obxBuild() {
    return Obx(
      () {
        logger.d("重构了页面");
        if (canGoBackRelay.value) {
          return PopScope(
            canPop: false,
            child: _buildBody(),
          );
        } else {
          return _buildBody();
        }
      },
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
          onUrlChange: (change) {
            logger.d('url change to ${change.url}');

            Future.delayed(Duration(seconds: 1), () {
              webController.canGoBack().then((value) {
                logger.d('canGoBack value: $value');

                canGoBackNotifier.value = value;

                canGoBackRelay.value = value;

                if (value) {
                  logger.d("可以返回上一个Web页面");
                } else {
                  logger.d("可以返回上一个Page页面");
                }
                _sendMessageToNative(value);
              });
            });
          },
        ),
      )
      ..loadRequest(Uri.parse("https://juejin.cn/user/4353721778057997"));

    if (webController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    /// 在这里设置iOS的Web侧滑手势
    if (webController.platform is WebKitWebViewController) {
      (webController.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }

    _controller = webController;
  }

  static const platform = const MethodChannel('com.getStudy.app/popIsEnable');

  Future<void> _sendMessageToNative(bool canGoBack) async {
    String response = "";
    try {
      final String result =
          await platform.invokeMethod('sendMessage', {"canGoBack": canGoBack});
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to send message: '${e.message}'.";
    }
  }
}