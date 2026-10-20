import 'package:getx_study/pages/web/view/web_collection_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/logger/logger.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:marqueer/marqueer.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/widgets/animated_button.dart';

class WebPage extends GetView<WebController> {
  final themeService = ThemeService.find;

  WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    final webLoadInfo = controller.webLoadInfo;

    return Obx(
      // 根据 WebView 是否有历史记录来决定是否允许侧滑退出
      () => PopScope(
        canPop: !controller.canGoBack.value, // Web 无历史时允许退出，有历史时拦截
        onPopInvokedWithResult: (didPop, result) async {
          // 如果 didPop 为 true，说明已经退出了（canPop 为 true 的情况）
          if (didPop) return;
          // Web 有历史记录时，侧滑先尝试 WebView 后退
          await controller.onBackAction();
        },
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: controller.canGoBack.value,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () async {
                controller.onBackAction();
              },
            ),
            middle: _title(webLoadInfo),
            trailing: SizedBox(
              width: 100,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Visibility(
                  visible: webLoadInfo.id != null,
                  child: AnimatedIconButton(
                    icon: const Icon(CupertinoIcons.share),
                    onPressed: () async {
                      print('分享链接: ${webLoadInfo.link}');
                      if (webLoadInfo.link != null) {
                        try {
                          await SharePlus.instance.share(
                            ShareParams(
                              title: webLoadInfo.title,
                              text: '${webLoadInfo.title.toString().replaceHtmlElement}\n${webLoadInfo.link}',
                            ),
                          );
                        } catch (error, stackTrace) {
                          logger.e(error, stackTrace, '分享网页失败');
                        }
                      }
                    },
                  ),
                ),
                WebCollectionButton(
                  controller: controller,
                  webLoadInfo: webLoadInfo,
                  hidden: controller.hideCollection,
                ),
              ]),
            ),
          ),
          child: SafeArea(
            child: switch (controller.initializationStatus.value) {
              WebInitializationStatus.initializing =>
                const Center(child: CupertinoActivityIndicator()),
              WebInitializationStatus.failed => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('网页初始化失败，请返回后重试'),
                      CupertinoButton(
                        onPressed: controller.onBackAction,
                        child: const Text('返回'),
                      ),
                    ],
                  ),
                ),
              WebInitializationStatus.ready => WebViewWidget(
                  controller: controller.webViewController,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => HorizontalDragGestureRecognizer()
                        ..onStart = (_) {
                          logger.d('处理拖动开始的逻辑');
                        }
                        ..onUpdate = (_) {
                          logger.d('处理拖动更新的逻辑');
                        }
                        ..onEnd = (_) {
                          logger.d('处理拖动结束的逻辑');
                        },
                    ),
                  },
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _title(IWebLoadInfo webLoadInfo) {
    if (webLoadInfo.id != null) {
      return SizedBox(
        height: 44,
        child: Marqueer(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              webLoadInfo.title.toString().replaceHtmlElement,
              style: themeService.themeData.textTheme.navTitleTextStyle,
            ),
          ),
        ),
      );
    } else {
      return Text(
        webLoadInfo.title.toString(),
      );
    }
  }
}
