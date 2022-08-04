import 'dart:async';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:marquee/marquee.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/pages/common/marquee_label.dart';

class WebPage extends StatelessWidget {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  WebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IWebLoadInfo webLoadInfo = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        // 参考了微信的做法,直接就没有标题,这个title有h5元素,
        //用Text或者框架Html都不能很好解决,加上跑马灯的问题
        title: SizedBox(
          height: 44,
          child: Marquee(
            text: webLoadInfo.title.toString().replaceHtmlElement,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.1,
        actions: const <Widget>[],
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
}
