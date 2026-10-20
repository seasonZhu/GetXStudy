import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_view.dart';
import 'package:getx_study/pages/my/controller/register_controller.dart';
import 'package:getx_study/widgets/animated_button.dart';

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
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoTextField(
                          controller: controller.userNameTextFiledController,
                          focusNode: controller.userNameFocusNode,
                          placeholder: AppText.t('login.phone'),
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              controller.userNameTextFieldOnSubmitted(context),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: InkWell(
                          child: Icon(Icons.clear, semanticLabel: AppText.t('input.clear')),
                          onTap: () {
                            controller.userNameTextFiledController.text = "";
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Obx(
                          () => CupertinoTextField(
                            enabled: controller.userNameIsNotEmpty.value,
                            controller: controller.passwordTextFiledController,
                            focusNode: controller.passwordFocusNode,
                            placeholder: AppText.t('login.password'),
                            textInputAction: TextInputAction.next,
                            obscureText: controller.obscureText.value,
                            onSubmitted: (_) => controller
                                .passwordTextFieldOnSubmitted(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 38,
                        child: Obx(
                          () => InkWell(
                            child: controller.obscureText.value
                                ? Icon(Icons.remove_red_eye, semanticLabel: AppText.t('input.show_password'))
                                : Icon(Icons.security, semanticLabel: AppText.t('input.hide_password')),
                            onTap: () {
                              final value = controller.obscureText.value;
                              controller.obscureText.value = !value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Obx(
                          () => CupertinoTextField(
                            enabled: controller.userNameIsNotEmpty.value &&
                                controller.password.value.isNotEmpty,
                            controller:
                                controller.rePasswordTextFiledController,
                            focusNode: controller.rePasswordFocusNode,
                            placeholder: AppText.t('register.repassword'),
                            textInputAction: TextInputAction.done,
                            obscureText: controller.reObscureText.value,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 38,
                        child: Obx(
                          () => InkWell(
                            child: controller.reObscureText.value
                                ? Icon(Icons.remove_red_eye, semanticLabel: AppText.t('input.show_password'))
                                : Icon(Icons.security, semanticLabel: AppText.t('input.hide_password')),
                            onTap: () {
                              final value = controller.reObscureText.value;
                              controller.reObscureText.value = !value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 15,
                      right: 15,
                    ),
                    child: SizedBox(
                      /// 这个地方可以写宽一点 会被Padding卡住
                      width: double.infinity,
                      height: 44,
                      child: Obx(
                        () => Visibility(
                          visible: controller.isShowRegisterButton,
                          child: AnimatedTextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.blue,
                              ),
                            ),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
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
