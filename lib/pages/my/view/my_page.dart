import 'package:flutter/cupertino.dart';
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("我的"),
      ),
      child: Obx(
        () {
          final dataSource = controller.isLogin.value
              ? my.Extension.userDataSource
              : my.Extension.visitorDataSource;
          final icon = controller.isLogin.value ? Icons.android : Icons.person;

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
                        Text(controller.rxUserInfo.value),
                      ],
                    ),
                  );
                } else {
                  final model = dataSource[index];
                  return ListTile(
                    leading: Icon(model.icon),
                    title: Text(model.title),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      if (model == my.My.login) {
                        final result = await Get.toNamed(Routes.login)
                            as Map<String, dynamic>;
                        controller.isLogin.value = result["isLogin"];
                        controller.rxUserInfo.value = result["userInfo"];
                      } else if (model == my.My.logout) {
                        showCupertinoDialog(
                          context: context,
                          builder: ((context) {
                            return CupertinoAlertDialog(
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
                                    controller.rxUserInfo.value =
                                        AccountManager().userInfo;
                                    controller.isLogin.value = result;
                                  },
                                ),
                              ],
                            );
                          }),
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
