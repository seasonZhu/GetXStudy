import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/enum/my.dart' as my;
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/routes/routes.dart';

class MyPage extends GetView<MyController> {
  final _isLogin = false.obs;

  MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的"),
      ),
      body: Obx(
        () {
          final dataSource =
              _isLogin.value ? my.Ext.userDataSource : my.Ext.visitorDataSource;
          return ListView.separated(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Container(),
                  );
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
                          _isLogin.value = result;
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
                                  _isLogin.value = result;
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        Get.toNamed(model.path);
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
