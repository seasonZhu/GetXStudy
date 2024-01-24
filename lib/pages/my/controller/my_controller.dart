import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_service.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/controller/get_user_info_mixin.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/logger/logger.dart';

class MyController
    extends BaseRequestController<MyRepository, AccountInfoEntity>
    with GetUserInfoMixin {
  /*
     为了避免这种问题，_observable_的第一次变化将总是触发一个事件，即使它包含相同的.value。
     如果你想删除这种行为，你可以使用： isLogin.firstRebuild = false;。
     */
  final isLogin = AccountService().isLogin.obs;

  final rxUserInfo = AccountService().userInfo.obs;

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
      AccountService().clear();
    } else {
      message = "登出失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );
    return AccountService().isLogin;
  }

  Future<void> autoLogin() async {
    final username = await AccountService().getLastLoginUserName();
    final password = await AccountService().getLastLoginPassword();

    if (username.isNotEmpty && password.isNotEmpty) {
      final response =
          await request.login(username: username, password: password);

      String message;
      if (response.isSuccess == true && response.data != null) {
        await AccountService()
            .save(info: response.data!, isLogin: true, password: password);
        message = "自动登录成功";

        await getUserCoinInfo();

        isLogin.value = AccountService().isLogin;
        rxUserInfo.value = AccountService().userInfo;
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
