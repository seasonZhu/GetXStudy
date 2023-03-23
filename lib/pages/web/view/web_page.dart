import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:marquee/marquee.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/logger/logger.dart';

class WebPage extends GetView<WebController> {
  late final WebViewController _webViewController;

  WebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 平台判断
    IWebLoadInfo webLoadInfo = Get.arguments;
    final isCollect = controller.isCollect(webLoadInfo).obs;
    final notShowCollectIcon = Get.parameters['notShowCollectIcon'];
    final className = Get.parameters['className'];
    controller.className = className;
    bool isShowCollectIcon;
    if (notShowCollectIcon == "true") {
      isShowCollectIcon = false;
    } else {
      isShowCollectIcon = webLoadInfo.id != null && AccountManager().isLogin;
    }

    _flutterWebViewSetting(webLoadInfo);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _title(webLoadInfo),
        trailing: SizedBox(
          width: 100,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Visibility(
              visible: webLoadInfo.id != null,
              child: IconButton(
                icon: const Icon(CupertinoIcons.share),
                onPressed: () {
                  if (webLoadInfo.link != null) {
                    Share.share(webLoadInfo.link!);
                  }
                },
              ),
            ),
            Visibility(
              visible: isShowCollectIcon,
              child: IconButton(
                icon: Obx(
                  () {
                    final icon = isCollect.value
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart;
                    return Icon(icon);
                  },
                ),
                onPressed: () async {
                  isCollect.value = await controller.collectOrUnCollectAction(
                      webLoadInfo: webLoadInfo, isCollect: isCollect.value);
                },
              ),
            ),
          ]),
        ),
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      child: SafeArea(
        child: Builder(builder: (BuildContext context) {
          return WebViewWidget(
            controller: _webViewController,
          );
        }),
      ),
    );
  }

  Widget _title(IWebLoadInfo webLoadInfo) {
    if (webLoadInfo.id != null) {
      return SizedBox(
        height: 44,
        child: Marquee(
            text: webLoadInfo.title.toString().replaceHtmlElement,
            style: const TextStyle(color: Colors.black),
            showFadingOnlyWhenScrolling: true),
      );
    } else {
      return Text(
        webLoadInfo.title.toString(),
      );
    }
  }

  void _flutterWebViewSetting(IWebLoadInfo webLoadInfo) {
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
          },
          onPageStarted: (String url) {
            logger.d('Page started loading: $url');
            EasyLoading.show(
                indicator: const CupertinoActivityIndicator(
                  color: Colors.white,
                  radius: 15,
                ),
                maskType: EasyLoadingMaskType.none);
          },
          onPageFinished: (String url) {
            logger.d('Page finished loading: $url');
            EasyLoading.dismiss();
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
      ..loadRequest(Uri.parse(webLoadInfo.link.toString()));

    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _webViewController = webViewController;
  }
}
