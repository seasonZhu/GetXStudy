import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:marquee/marquee.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/extension/string_extension.dart';

class WebPage extends GetView<WebController> {
  const WebPage({Key? key}) : super(key: key);

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

    controller.flutterWebViewSetting(webLoadInfo);

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
          /// 这里没有使用下拉刷新组件,是因为SmartRefresh+WebViewWidget会导致底部显示异常
          return WebViewWidget(
            controller: controller.webViewController,
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
}
