import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';

class MyController
    extends BaseRequestController<MyRepository, AccountInfoEntity> {
  var userInfo = "等级 --  排名 --  积分 --";

  void Function()? autoLoginSuccessCallback;

  @override
  void onInit() {
    super.onInit();
    debugPrint("onInit");
  }

  void login({required String username, required String password}) async {
    ResignFirstResponder.unfocus();
    final response =
        await request.login(username: username, password: password);

    String message;
    if (response.isSuccess == true && response.data != null) {
      await AccountManager()
          .save(info: response.data!, isLogin: true, password: password);
      await getUserCoinInfo();
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
          navigator?.pop(AccountManager().isLogin);

          // navigator?.popUntil(
          //   (route) => route.settings.name == Routes.main,
          // );
        }
      },
    );
  }

  void register(
      {required String username,
      required String password,
      required String rePassword}) async {
    ResignFirstResponder.unfocus();
    final response = await request.register(
        username: username, password: password, rePassword: rePassword);

    String message;
    if (response.isSuccess == true && response.data != null) {
      await AccountManager()
          .save(info: response.data!, isLogin: true, password: password);
      await getUserCoinInfo();
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
          Future.delayed(
            const Duration(seconds: 0),
            () => navigator?.pop(AccountManager().isLogin),
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
      AccountManager().clear();
    } else {
      message = "登出失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );
    return AccountManager().isLogin;
  }

  Future<String> getUserCoinInfo() async {
    final response = await request.getUserCoinInfo();
    final userInfo =
        "等级 ${response.data?.level ?? "--"}  排名 ${response.data?.rank ?? "--"}  积分 ${response.data?.coinCount ?? "--"}";
    this.userInfo = userInfo;
    AccountManager().myCoinInfo = userInfo;
    return userInfo;
  }

  Future<void> autoLogin() async {
    final username = await AccountManager().getLastLoginUserName();
    final password = await AccountManager().getLastLoginPassword();

    if (username.isNotEmpty && password.isNotEmpty) {
      final response =
          await request.login(username: username, password: password);

      String message;
      if (response.isSuccess == true && response.data != null) {
        await AccountManager()
            .save(info: response.data!, isLogin: true, password: password);
        message = "自动登录成功";
        await getUserCoinInfo();
        if (autoLoginSuccessCallback != null) {
          autoLoginSuccessCallback!();
        }
      } else {
        message = "自动登录失败";
      }
      Get.snackbar(
        "",
        message,
        duration: const Duration(seconds: 1),
      );
    }
  }
}
