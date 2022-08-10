import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:marquee/marquee.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/extension/string_extension.dart';

class WebPage extends GetView<WebController> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  WebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IWebLoadInfo webLoadInfo = Get.arguments;
    var isCollect = controller.isCollect(webLoadInfo).obs;
    var notShowCollectIcon = Get.parameters['notShowCollectIcon'];
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
    bool isShowCollectIcon;
    if (notShowCollectIcon == "true") {
      isShowCollectIcon = false;
    } else {
      isShowCollectIcon =
          webLoadInfo.id != null && AccountManager.shared.isLogin;
    }
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
                  final collectId = controller.realCollectId(webLoadInfo);
                  EasyLoading.show(
                    status: 'loading...',
                    maskType: EasyLoadingMaskType.none,
                    dismissOnTap: true
                  );
                  if (collectId != null) {
                    if (isCollect.value) {
                      final result =
                          await controller.unCollectAction(originId: collectId);
                      isCollect.value = !result;
                    } else {
                      final result =
                          await controller.collectAction(originId: collectId);
                      isCollect.value = result;
                    }
                  }
                  EasyLoading.dismiss();
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
          return WebView(
            initialUrl: webLoadInfo.link,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            // Remove this when collection literals makes it to stable.
            // ignore: prefer_collection_literals
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
              EasyLoading.show(
                  status: "loading...", maskType: EasyLoadingMaskType.clear);
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
              EasyLoading.dismiss();
            },
            gestureNavigationEnabled: true,
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
            style: TextStyle(color: Colors.black),
            showFadingOnlyWhenScrolling: true),
      );
    } else {
      return Text(
        webLoadInfo.title.toString(),
      );
    }
  }
}
