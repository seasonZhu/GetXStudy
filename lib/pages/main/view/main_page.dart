import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:getx_study/account_manager/account_controller.dart';
import 'package:getx_study/pages/home/view/home_page.dart';
import 'package:getx_study/pages/main/controller/main_controller.dart';
import 'package:getx_study/pages/my/view/my_page.dart';
import 'package:getx_study/pages/tree/view/tabs_page.dart';
import 'package:getx_study/pages/tree/view/tree_page.dart';

class MainPage extends GetView<MainController> {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    print(accountController);
    return GetBuilder<MainController>(
      builder: ((controller) {
        return CupertinoTabScaffold(
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(builder: (context) {
                  return const HomePage();
                });
              case 1:
                return CupertinoTabView(builder: (context) {
                  return const TabsPage();
                });
              case 2:
                return CupertinoTabView(builder: (context) {
                  return const TreePage();
                });
              case 3:
                return CupertinoTabView(builder: (context) {
                  return const MyPage();
                });
              default:
                return CupertinoTabView(
                  builder: (context) {
                    return Container();
                  },
                );
            }
          },
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "首页",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.web),
                label: "项目",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: "体系",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "我的",
              ),
            ],
            currentIndex: controller.selectedIndex, //默认选中的 index
            onTap: controller.onItemTapped,
          ),
        );
      }),
    );
  }
}
