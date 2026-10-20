import 'package:getx_study/i18n/app_text.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:getx_study/enum/my.dart' as my;
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/logger/debug_logs_page.dart';

class MyPage extends GetView<MyController> {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('my.title')),
      ),
      child: Obx(
        () {
          final dataSource = controller.isLogin.value
              ? my.Extension.userDataSource
              : my.Extension.visitorDataSource;
          final icon = controller.isLogin.value ? Icons.android : Icons.person;

          // Cupertino 背景内的 ListTile 需要就近的 Material 承载点击效果。
          return Material(
            type: MaterialType.transparency,
            child: ListView.separated(
              itemBuilder: (context, index) {
                if (kDebugMode && index == dataSource.length) {
                  return ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text(AppText.t('logs.title')),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.to(
                      () => const DebugLogsPage(),
                      routeName: '/debug-logs',
                    ),
                  );
                }
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 66,
                          height: 66,
                          child: Icon(icon),
                        ),
                        Obx(() {
                          controller.rxUserInfo.value;
                          return Text(AccountService.find.userInfo, textAlign: TextAlign.center);
                        }),
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
                        await Get.toNamed(Routes.login);
                        controller.syncAccount();
                      } else if (model == my.My.logout) {
                        showCupertinoDialog(
                          context: context,
                          builder: ((context) {
                            return CupertinoAlertDialog(
                              title: Text(AppText.t('common.tip')),
                              content: Text(AppText.t('common.logout_confirm')),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    AppText.t('common.cancel'),
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  onPressed: () => Get.back(), //关闭对话框
                                ),
                                TextButton(
                                  child: Text(
                                    AppText.t('common.confirm'),
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    await controller.logout();
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
                  indent: 15,
                  height: 0.5,
                );
              },
              itemCount: dataSource.length + (kDebugMode ? 1 : 0)),
          );
        },
      ),
    );
  }
}
