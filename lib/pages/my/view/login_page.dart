import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_view.dart';
import 'package:getx_study/pages/my/controller/login_controller.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/widgets/animated_button.dart';

import 'auth_field.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResignFirstView(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticBackgroundVisibility: false,
          middle: Text(AppText.t('login.title')),
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
                        textInputAction: TextInputAction.done,
                        obscureText: controller.obscureText.value,
                        onToggleVisibility: () =>
                            controller.obscureText.toggle(),
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AnimatedInkWell(
                        onTap: () async {
                          if (controller.isSubmitting.value) return;
                          final result = await Get.toNamed(Routes.register);
                          if (!controller.isClosed &&
                              result is Map<String, dynamic>) {
                            navigator?.pop(result);
                          }
                        },
                        child: Text(
                          AppText.t('login.register_link'),
                          style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => Visibility(
                          visible: controller.userNameIsNotEmpty.value &&
                              controller.passwordIsNotEmpty.value,
                          child: AnimatedTextButton(
                            style: authSubmitStyle(context),
                            onPressed: controller.isSubmitting.value
                                ? null
                                : () {
                                    controller.login(
                                      username: controller
                                          .userNameTextFiledController.text,
                                      password: controller
                                          .passwordTextFiledController.text,
                                    );
                                  },
                            child: Text(
                              AppText.t('login.title'),
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
