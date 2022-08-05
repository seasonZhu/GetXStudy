import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/enum/my.dart' as my;
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/routes/routes.dart';

class MyPage extends GetView<MyController> {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLogin = AccountManager.shared.isLogin.obs;

    final userInfo = AccountManager.shared.myCoinInfo.obs;

    controller.autoLoginSuccessCallback = () {
      isLogin.value = AccountManager.shared.isLogin;
      userInfo.value = AccountManager.shared.myCoinInfo;
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("我的"),
      ),
      body: Obx(
        () {
          final dataSource = isLogin.value
              ? my.Extension.userDataSource
              : my.Extension.visitorDataSource;
          final icon = isLogin.value ? Icons.android : Icons.person;
          return ListView.separated(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AspectRatio(
                      aspectRatio: 16.0 / 9.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 66,
                            height: 66,
                            child: Icon(icon),
                          ),
                          Text(userInfo.value),
                        ],
                      ));
                } else {
                  final model = dataSource[index];
                  return ListTile(
                    leading: Icon(model.icon),
                    title: Text(model.title),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      if (model == my.My.login) {
                        final result = await Get.toNamed(Routes.login);
                        if (result != null) {
                          isLogin.value = result;
                          userInfo.value = controller.userInfo;
                        }
                      } else if (model == my.My.logout) {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("提示"),
                            content: const Text("是否登出?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  "取消",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () => Get.back(), //关闭对话框
                              ),
                              TextButton(
                                child: Text(
                                  "确定",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () async {
                                  Get.back();
                                  final result = await controller.logout();
                                  userInfo.value = AccountManager.shared.myCoinInfo;
                                  isLogin.value = result;
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        if (model.entity != null) {
                          Get.toNamed(model.path, arguments: model.entity);
                        } else {
                          Get.toNamed(model.path);
                        }
                      }
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1.0,
                );
              },
              itemCount: dataSource.length);
        },
      ),
    );
  }
}
