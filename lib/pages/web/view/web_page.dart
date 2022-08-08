import 'dart:async';
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
    bool isShowCollectIcon;
    if (notShowCollectIcon == "true") {
      isShowCollectIcon = false;
    } else {
      isShowCollectIcon =
          webLoadInfo.id != null && AccountManager.shared.isLogin;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _title(webLoadInfo),
        actions: <Widget>[
          Visibility(
            visible: webLoadInfo.id != null,
            child: IconButton(
              icon: const Icon(Icons.open_in_new),
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
                  final icon =
                      isCollect.value ? Icons.bookmark : Icons.bookmark_outline;
                  return Icon(icon);
                },
              ),
              onPressed: () async {
                final collectId = controller.realCollectId(webLoadInfo);
                EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.clear);
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
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: SafeArea(
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
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
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
            showFadingOnlyWhenScrolling: true),
      );
    } else {
      return Text(
        webLoadInfo.title.toString(),
      );
    }
  }
}
