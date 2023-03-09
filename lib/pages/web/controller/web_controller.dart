import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:getx_study/base/interface.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/pages/web/repository/web_repository.dart';

class WebController extends BaseRequestController<WebRepository, Object?> {
  void Function()? hasActionCallback;

  WebViewController? webViewController;

  @override
  void onClose() {
    super.onClose();
    EasyLoading.dismiss();
  }

  Future<bool> unCollectAction({required int originId}) async {
    final model = await request.unCollectAction(originId: originId);

    String message;
    if (model.isSuccess) {
      if ((AccountManager().info?.collectIds ?? []).contains(originId)) {
        (AccountManager().info?.collectIds ?? []).remove(originId);
      }
      message = "取消收藏成功";
      if (hasActionCallback != null) {
        hasActionCallback!();
      }
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
      if (hasActionCallback != null) {
        hasActionCallback!();
      }
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

  void onRefresh() => webViewController?.reload();

  Future<bool> collectOrUnCollectAction(
      {required IWebLoadInfo webLoadInfo, required bool isCollect}) async {
    final collectId = _realCollectId(webLoadInfo);
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
}
