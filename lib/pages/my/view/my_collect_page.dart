import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/logger/class_name.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class MyCollectPage extends GetView<MyCollectController> {
  const MyCollectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("我的收藏"),
      ),
      child: StatusView<MyCollectController>(
        contentBuilder: (controller) {
          return SmartRefresher(
            enablePullUp: true,
            header: const RefreshHeader(),
            footer: const RefreshFooter(),
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.dataSource.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 15,
                  endIndent: 15,
                  height: 0.1,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final model = controller.dataSource[index];
                return InfoCell(
                  model: model,
                  callback: (_) => Get.toNamed(Routes.web,
                      arguments: model,
                      parameters: {"className": className(this)}),
                  isNeedBottomLine: false,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void doNothing(BuildContext context) {}
}
