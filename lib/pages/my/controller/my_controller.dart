import 'package:getx_study/i18n/app_text.dart';
import 'dart:async';

import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/pages/my/controller/get_user_info_mixin.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';

class MyController
    extends BaseRequestController<MyRepository, AccountInfoEntity>
    with GetUserInfoMixin {
  final isLogin = AccountService.find.isLogin.obs;
  final rxUserInfo = AccountService.find.userInfo.obs;
  bool _loggingOut = false;
  bool _autoLoggingIn = false;

  void syncAccount() {
    if (isClosed) return;
    isLogin.value = AccountService.find.isLogin;
    rxUserInfo.value = AccountService.find.userInfo;
  }

  Future<bool> logout() async {
    if (isClosed || _loggingOut) return AccountService.find.isLogin;
    _loggingOut = true;
    final account = AccountService.find;
    final revision = account.sessionRevision;
    try {
      final response = await request.logout();
      if (isClosed || account.sessionRevision != revision) {
        return account.isLogin;
      }
      if (response.isSuccess) {
        await account.clear();
        syncAccount();
      }
      if (!isClosed) {
        Get.snackbar(
          "",
          response.isSuccess ? AppText.t('login.logout_success') : AppText.t('login.logout_failed'),
          duration: const Duration(seconds: 1),
        );
      }
    } catch (error) {
      if (!isClosed) Get.snackbar("", AppText.t('login.logout_error', {'error': error.toString()}));
    } finally {
      syncAccount();
      _loggingOut = false;
    }
    return account.isLogin;
  }

  Future<void> autoLogin() async {
    if (isClosed ||
        _autoLoggingIn ||
        _loggingOut ||
        AccountService.find.isLogin) {
      return;
    }
    _autoLoggingIn = true;
    final account = AccountService.find;
    final revision = account.sessionRevision;
    var operationRevision = revision;
    try {
      final username = await account.getLastLoginUserName();
      final password = await account.getLastLoginPassword();
      if (isClosed ||
          account.sessionRevision != revision ||
          username.isEmpty ||
          password.isEmpty) {
        return;
      }
      final response = await request.login(
        username: username,
        password: password,
      );
      if (isClosed || account.sessionRevision != revision) return;
      if (response.isSuccess && response.data != null) {
        final info = response.data!;
        operationRevision = revision + 1;
        await account.save(info: info, isLogin: true, password: password);
        if (isClosed ||
            account.sessionRevision != operationRevision ||
            !account.isLogin ||
            !identical(account.info, info)) {
          return;
        }
        syncAccount();
        unawaited(getUserCoinInfo());
      } else {
        Get.snackbar("", AppText.t('login.auto_login_failed'), duration: const Duration(seconds: 1));
      }
    } catch (error) {
      if (!isClosed && account.sessionRevision == operationRevision) {
        Get.snackbar("", AppText.t('login.auto_login_error', {'error': error.toString()}));
      }
    } finally {
      _autoLoggingIn = false;
    }
  }
}
