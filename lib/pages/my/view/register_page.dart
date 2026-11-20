import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_view.dart';
import 'package:getx_study/pages/my/controller/register_controller.dart';
import 'package:getx_study/widgets/animated_button.dart';

import 'auth_field.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResignFirstView(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticBackgroundVisibility: false,
          middle: Text(AppText.t('register.title')),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AuthField(
                    controller: controller.userNameTextFiledController,
                    focusNode: controller.userNameFocusNode,
                    placeholder: AppText.t('login.phone'),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) =>
                        controller.userNameTextFieldOnSubmitted(context),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => AuthField(
                        enabled: controller.userNameIsNotEmpty.value,
                        controller: controller.passwordTextFiledController,
                        focusNode: controller.passwordFocusNode,
                        placeholder: AppText.t('login.password'),
                        textInputAction: TextInputAction.next,
                        obscureText: controller.obscureText.value,
                        onSubmitted: (_) =>
                            controller.passwordTextFieldOnSubmitted(context),
                        onToggleVisibility: () =>
                            controller.obscureText.toggle(),
                      )),
                  const SizedBox(height: 12),
                  Obx(() => AuthField(
                        enabled: controller.userNameIsNotEmpty.value &&
                            controller.password.value.isNotEmpty,
                        controller: controller.rePasswordTextFiledController,
                        focusNode: controller.rePasswordFocusNode,
                        placeholder: AppText.t('register.repassword'),
                        textInputAction: TextInputAction.done,
                        obscureText: controller.reObscureText.value,
                        onToggleVisibility: () =>
                            controller.reObscureText.toggle(),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => Visibility(
                          visible: controller.isShowRegisterButton,
                          child: AnimatedTextButton(
                            style: authSubmitStyle(context),
                            onPressed: controller.isSubmitting.value
                                ? null
                                : () {
                                    controller.register(
                                      username: controller
                                          .userNameTextFiledController.text,
                                      password: controller
                                          .passwordTextFiledController.text,
                                      rePassword: controller
                                          .rePasswordTextFiledController.text,
                                    );
                                  },
                            child: Text(
                              AppText.t('register.title'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
