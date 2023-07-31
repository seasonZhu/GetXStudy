import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/pages/web/repository/web_repository.dart';
import 'package:getx_study/enum/collect_action_type.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/logger/class_name.dart' as Func;
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';

class WebController extends BaseRequestController<WebRepository, Object?> {
  void Function(CollectActionType, IWebLoadInfo)? collectActionCallback;

  late final WebViewController webViewController;

  late final RefreshController refreshController;

  var _actionTag = 0;

  IWebLoadInfo? _webLoadInfo;

  CollectActionType? _type;

  String? className;

  @override
  void onInit() {
    super.onInit();
    refreshController = Get.find(tag: Func.className(WebController));
  }

  @override
  void onClose() {
    super.onClose();
    EasyLoading.dismiss();
    doCollectAction();
  }

  void flutterWebViewSetting(IWebLoadInfo webLoadInfo) {
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
            EasyLoading.showProgress((progress / 100).toDouble(),
                maskType: EasyLoadingMaskType.none);
          },
          onPageStarted: (String url) {
            logger.d('Page started loading: $url');
            //refreshController.requestRefresh();
          },
          onPageFinished: (String url) {
            logger.d('Page finished loading: $url');
            EasyLoading.dismiss();
            //refreshController.refreshCompleted();
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
            if (request.url.startsWith('https://www.baidu.com/')) {
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
    this.webViewController = webViewController;
  }

  Future<bool> unCollectAction({required int originId}) async {
    final model = await request.unCollectAction(originId: originId);

    String message;
    if (model.isSuccess) {
      if ((AccountManager().info?.collectIds ?? []).contains(originId)) {
        (AccountManager().info?.collectIds ?? []).remove(originId);
      }
      message = "取消收藏成功";
      _actionTag = _actionTag - 1;
      _type = CollectActionType.unCollect;
    } else {
      message = model.errorMsg.toString();
    }

    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );

    return model.isSuccess;
  }

  Future<bool> collectAction({required int originId}) async {
    final model = await request.collectAction(originId: originId);

    String message;
    if (model.isSuccess) {
      (AccountManager().info?.collectIds ?? []).add(originId);
      message = "收藏成功";
      _actionTag = _actionTag + 1;
      _type = CollectActionType.collect;
    } else {
      message = model.errorMsg.toString();
    }

    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );

    return model.isSuccess;
  }

  bool isCollect(IWebLoadInfo webLoadInfo) {
    final collectId = _realCollectId(webLoadInfo);
    final collectIds = AccountManager().info?.collectIds;
    if (collectIds != null && collectId != null) {
      if (collectIds.contains(collectId)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  int? _realCollectId(IWebLoadInfo webLoadInfo) {
    final id = webLoadInfo.id;
    final collectId = webLoadInfo.originId;
    if (collectId == null && id != null) {
      return id;
    } else {
      return collectId;
    }
  }

  void onRefresh() => webViewController.reload();

  Future<bool> collectOrUnCollectAction(
      {required IWebLoadInfo webLoadInfo, required bool isCollect}) async {
    final collectId = _realCollectId(webLoadInfo);
    _webLoadInfo = webLoadInfo;
    if (collectId != null) {
      if (isCollect) {
        final result = await unCollectAction(originId: collectId);
        return !result;
      } else {
        final result = await collectAction(originId: collectId);
        return result;
      }
    } else {
      return false;
    }
  }

  void doCollectAction() {
    if (className == "MyCollectPage") {
      if (_actionTag != 0) {
        if (_webLoadInfo != null && _type != null) {
          final myCollectController = Get.find<MyCollectController>();
          switch (_type!) {
            case CollectActionType.unCollect:
              myCollectController.removeUnCollectItem(_webLoadInfo!);
              break;
            case CollectActionType.collect:
              break;
          }
        }
      }
    } else {
      logger.d("it is not MyCollectPage, do nothing");
    }
  }
}
