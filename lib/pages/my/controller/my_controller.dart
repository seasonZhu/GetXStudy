import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/routes/routes.dart';

class MyController
    extends BaseRequestController<MyRepository, AccountInfoEntity> {
  final isNowReqeust = false.obs;

  void login({required String username, required String password}) async {
    ResignFirstResponder.unfocus();
    isNowReqeust.value = true;
    final response =
        await request.login(username: username, password: password);
    isNowReqeust.value = false;

    String message;
    if (response.isSuccess == true && response.data != null) {
      AccountManager.shared
          .save(info: response.data!, isLogin: true, password: password);
      message = "登录成功";
    } else {
      message = "登录失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          //Get.back();
          navigator?.pop(AccountManager.shared.isLogin);
        }
      },
    );
  }

  void register(
      {required String username,
      required String password,
      required String rePassword}) async {
    ResignFirstResponder.unfocus();
    isNowReqeust.value = true;
    final response = await request.register(
        username: username, password: password, rePassword: rePassword);
    isNowReqeust.value = false;

    String message;
    bool isLogin;
    if (response.isSuccess == true && response.data != null) {
      AccountManager.shared
          .save(info: response.data!, isLogin: true, password: password);
      message = "注册成功";
    } else {
      message = "注册失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          navigator?.popUntil(
            (route) => route.settings.name == Routes.main,
          );
        }
      },
    );
  }

  Future<bool> logout() async {
    final response = await request.logout();
    String message;
    if (response.isSuccess) {
      message = "登出成功";
      AccountManager.shared.clear();
    } else {
      message = "登出失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );
    return AccountManager.shared.isLogin;
  }
}
