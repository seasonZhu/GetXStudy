import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/controller/mixin_get_user_info.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/logger/logger.dart';

class MyController extends BaseRequestController<MyRepository, AccountInfoEntity> with GetUserInfoMixin {

  void Function()? autoLoginSuccessCallback;

  @override
  void onInit() {
    super.onInit();
    logger.d("onInit");
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
