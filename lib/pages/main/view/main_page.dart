import 'package:flutter/cupertino.dart';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:getx_study/account_manager/account_controller.dart';
import 'package:getx_study/enum/main_tag_type.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/pages/main/controller/main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    logger.d(accountController);
    return GetBuilder<MainController>(
      builder: ((controller) {
        return CupertinoTabScaffold(
          tabBuilder: (context, index) {
            final type = MainTagType.values[index];
            return CupertinoTabView(builder: (context) {
              return type.page;
            });
          },
          tabBar: CupertinoTabBar(
            items: MainTagTypeExt.items,
            currentIndex: controller.selectedIndex, //默认选中的 index
            onTap: controller.onItemTapped,
          ),
        );
      }),
    );
  }
}
