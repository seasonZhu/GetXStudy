import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/pages/common/loading_view.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';

class RegisterPage extends GetView<MyController> {
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
      child: GestureDetector(
        onTap: () {
          ResignFirstResponder.unfocus();
        },
        child: CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text("注册"),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
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
                            // decoration: const InputDecoration(
                            //   hintText: '手机号',
                            //   labelText: '用户名',
                            //   prefixIcon: Icon(Icons.person),
                            // ),
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Obx(
                            () => CupertinoTextField(
                              enabled: _userNameIsNotEmpty.value,
                              controller: _passwordTextFiledController,
                              // decoration: const InputDecoration(
                              //   hintText: '密码',
                              //   labelText: '密码',
                              //   prefixIcon: Icon(Icons.lock),
                              // ),
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Obx(
                            () => CupertinoTextField(
                              enabled: _userNameIsNotEmpty.value &&
                                  _password.value.isNotEmpty,
                              controller: _rePasswordTextFiledController,
                              // decoration: const InputDecoration(
                              //   hintText: '确认密码',
                              //   labelText: '确认密码',
                              //   prefixIcon: Icon(Icons.lock),
                              // ),
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
                                  if (!controller.isNowRequest.value) {
                                    controller.register(
                                      username:
                                          _userNameTextFiledController.text,
                                      password:
                                          _passwordTextFiledController.text,
                                      rePassword:
                                          _rePasswordTextFiledController.text,
                                    );
                                  }
                                }),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: controller.isNowRequest.value,
                        child: Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: const LoadingView(message: "正在注册..."),
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
