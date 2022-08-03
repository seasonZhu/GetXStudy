import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/base/resign_first_responder.dart';
import 'package:getx_study/pages/common/loading_view.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';

class RegisterPage extends GetView<MyController> {
  final _userNameTextFiledController = TextEditingController(text: "");

  final _passwordTextFiledController = TextEditingController(text: "");

  final _userNameIsNotEmpty = false.obs;

  final _passwordIsNotEmpty = false.obs;

  final _obscureText = true.obs;

  RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.1,
      ),
      body: GestureDetector(
        onTap: () {
          ResignFirstResponder.unfocus();
        },
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
                        child: TextField(
                          controller: _userNameTextFiledController,
                          decoration: const InputDecoration(
                            hintText: '手机号',
                            labelText: '用户名',
                            prefixIcon: Icon(Icons.person),
                          ),
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
                          () => TextField(
                            enabled: _userNameIsNotEmpty.value,
                            controller: _passwordTextFiledController,
                            decoration: const InputDecoration(
                              hintText: '密码',
                              labelText: '密码',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: _obscureText.value,
                            onChanged: (value) =>
                                _passwordIsNotEmpty.value = value.isNotEmpty,
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
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 15),
                        child: GestureDetector(
                          child: Text(
                            "还没有注册?",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15),
                          ),
                          onTap: () {},
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
                          visible: _userNameIsNotEmpty.value &&
                              _passwordIsNotEmpty.value,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor),
                            ),
                            child: const Text(
                              "登录",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () => controller.login(
                                username: _userNameTextFiledController.text,
                                password: _passwordTextFiledController.text),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: controller.isNowReqeust.value,
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
    );
  }
}
