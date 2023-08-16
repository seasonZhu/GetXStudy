import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/controller/mixin_get_user_info.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/logger/logger.dart';

class LoginController
    extends BaseRequestController<MyRepository, AccountInfoEntity> with GetUserInfoMixin {
  
  final userNameTextFiledController = TextEditingController(text: "");

  final passwordTextFiledController = TextEditingController(text: "");

  final userNameIsNotEmpty = false.obs;

  final passwordIsNotEmpty = false.obs;

  final obscureText = true.obs;

  @override
  void onInit() {
    super.onInit();
    logger.d("onInit");
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
          if (response.isSuccess) {
            navigator?.pop(AccountManager().isLogin);
          }
          // navigator?.popUntil(
          //   (route) => route.settings.name == Routes.main,
          // );
        }
      },
    );
  }
}