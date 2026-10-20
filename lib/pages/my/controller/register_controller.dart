import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_study/pages/my/controller/login_controller.dart';

class RegisterController extends LoginController {
  final rePasswordTextFiledController = TextEditingController(text: "");
  final password = "".obs;
  final rePassword = "".obs;
  final reObscureText = true.obs;
  final rePasswordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    rePasswordTextFiledController.addListener(syncInput);
    syncInput();
  }

  @override
  void syncInput() {
    super.syncInput();
    password.value = passwordTextFiledController.text;
    rePassword.value = rePasswordTextFiledController.text;
  }

  Future<void> register({
    required String username,
    required String password,
    required String rePassword,
  }) async {
    if (username.trim().isEmpty || password.isEmpty || password != rePassword) {
      return;
    }
    await submitAccount(
      operation: () => request.register(
        username: username,
        password: password,
        rePassword: rePassword,
      ),
      password: password,
      successMessage: 'register.success',
      failureMessage: 'register.failed',
    );
  }

  void passwordTextFieldOnSubmitted(BuildContext context) {
    passwordFocusNode.unfocus();
    FocusScope.of(context).requestFocus(rePasswordFocusNode);
  }

  @override
  void onClose() {
    rePasswordTextFiledController.removeListener(syncInput);
    rePasswordTextFiledController.dispose();
    rePasswordFocusNode.dispose();
    super.onClose();
  }

  bool get isShowRegisterButton =>
      userNameIsNotEmpty.value &&
      password.value.isNotEmpty &&
      rePassword.value.isNotEmpty &&
      password.value == rePassword.value;
}
