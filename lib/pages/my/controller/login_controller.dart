import 'package:getx_study/i18n/app_text.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/base/base_request_controller.dart';
import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/pages/my/controller/get_user_info_mixin.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';

class LoginController
    extends BaseRequestController<MyRepository, AccountInfoEntity>
    with GetUserInfoMixin {
  final userNameTextFiledController = TextEditingController(text: "");
  final passwordTextFiledController = TextEditingController(text: "");
  final userNameIsNotEmpty = false.obs;
  final passwordIsNotEmpty = false.obs;
  final obscureText = true.obs;
  final isSubmitting = false.obs;
  final userNameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    userNameTextFiledController.addListener(syncInput);
    passwordTextFiledController.addListener(syncInput);
    syncInput();
  }

  void syncInput() {
    userNameIsNotEmpty.value = userNameTextFiledController.text.isNotEmpty;
    passwordIsNotEmpty.value = passwordTextFiledController.text.isNotEmpty;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) return;
    await submitAccount(
      operation: () => request.login(username: username, password: password),
      password: password,
      successMessage: 'login.success',
      failureMessage: 'login.failed',
    );
  }

  /// 消息参数传入翻译键，在异步操作完成时使用当前语言解析。
  Future<void> submitAccount({
    required Future<BaseEntity<AccountInfoEntity>> Function() operation,
    required String password,
    required String successMessage,
    required String failureMessage,
  }) async {
    if (isClosed || isSubmitting.value) return;
    isSubmitting.value = true;
    ResignFirstResponder.unfocus();
    final account = AccountService.find;
    final revision = account.sessionRevision;
    var operationRevision = revision;
    try {
      final response = await operation();
      if (isClosed || account.sessionRevision != revision) return;
      if (!response.isSuccess || response.data == null) {
        Get.snackbar("", response.errorMsg ?? AppText.t(failureMessage));
        return;
      }
      final info = response.data!;
      operationRevision = revision + 1;
      await account.save(info: info, isLogin: true, password: password);
      if (isClosed ||
          account.sessionRevision != operationRevision ||
          !account.isLogin ||
          !identical(account.info, info)) {
        return;
      }
      if (Get.isRegistered<MyController>()) {
        Get.find<MyController>().syncAccount();
      }
      final result = <String, dynamic>{
        "isLogin": account.isLogin,
        "userInfo": account.userInfo,
      };
      unawaited(getUserCoinInfo());
      navigator?.pop(result);
      Get.snackbar("", AppText.t(successMessage), duration: const Duration(seconds: 1));
    } catch (error) {
      if (!isClosed && account.sessionRevision == operationRevision) {
        Get.snackbar("", AppText.t('example.error_detail', {'error': '${AppText.t(failureMessage)}: $error'}));
      }
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  void userNameTextFieldOnSubmitted(BuildContext context) {
    userNameFocusNode.unfocus();
    FocusScope.of(context).requestFocus(passwordFocusNode);
  }

  @override
  void onClose() {
    userNameTextFiledController.removeListener(syncInput);
    passwordTextFiledController.removeListener(syncInput);
    userNameTextFiledController.dispose();
    passwordTextFiledController.dispose();
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
