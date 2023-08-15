import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/resign_first_view.dart';
import 'package:getx_study/pages/my/controller/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  final _userNameTextFiledController = TextEditingController(text: "");

  final _passwordTextFiledController = TextEditingController(text: "");

  final _rePasswordTextFiledController = TextEditingController(text: "");

  final _userNameIsNotEmpty = false.obs;

  final _password = "".obs;

  final _rePassword = "".obs;

  final _obscureText = true.obs;

  final _reObscureText = true.obs;

  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResignFirstView(
        child: CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text("注册"),
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
                            controller: _userNameTextFiledController,
                            placeholder: "手机号",
                            onChanged: (value) =>
                                _userNameIsNotEmpty.value = value.isNotEmpty,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: InkWell(
                            child: const Icon(Icons.clear),
                            onTap: () {
                              _userNameTextFiledController.text = "";
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Obx(
                            () => CupertinoTextField(
                              enabled: _userNameIsNotEmpty.value,
                              controller: _passwordTextFiledController,
                              placeholder: "密码",
                              obscureText: _obscureText.value,
                              onChanged: (value) => _password.value = value,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          width: 38,
                          child: InkWell(
                            child: const Icon(Icons.security),
                            onTap: () {
                              final value = _obscureText.value;
                              _obscureText.value = !value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Obx(
                            () => CupertinoTextField(
                              enabled: _userNameIsNotEmpty.value &&
                                  _password.value.isNotEmpty,
                              controller: _rePasswordTextFiledController,
                              placeholder: "确认密码",
                              obscureText: _reObscureText.value,
                              onChanged: (value) => _rePassword.value = value,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          width: 38,
                          child: InkWell(
                            child: const Icon(Icons.security),
                            onTap: () {
                              final value = _reObscureText.value;
                              _reObscureText.value = !value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 15, right: 15),
                      child: SizedBox(
                        /// 这个地方可以写宽一点 会被Padding卡住
                        width: double.infinity,
                        height: 44,
                        child: Obx(
                          () => Visibility(
                            visible: (_userNameIsNotEmpty.value &&
                                    _password.value.isNotEmpty &&
                                    _rePassword.value.isNotEmpty) &&
                                (_password == _rePassword),
                            child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor),
                                ),
                                child: const Text(
                                  "注册",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                onPressed: () {
                                  controller.register(
                                      username:
                                          _userNameTextFiledController.text,
                                      password:
                                          _passwordTextFiledController.text,
                                      rePassword:
                                          _rePasswordTextFiledController.text,
                                    );
                                }),
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
      ),
    );
  }
}
