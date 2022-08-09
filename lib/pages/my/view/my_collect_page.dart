import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/pages/common/refresh_status_view.dart';
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class MyCollectPage extends GetView<MyCollectController> {
  const MyCollectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final webController = Get.find<WebController>();

    webController.hasActionCallback =
        () => controller.refreshController.requestRefresh();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("我的收藏"),
      ),
      child: RefreshStatusView(
        controller: controller,
        contentBuilder: (_) {
          return SmartRefresher(
            enablePullUp: true,
            header: const RefreshHeader(),
            footer: const RefreshFooter(),  
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.dataSource.length,
              itemBuilder: (BuildContext context, int index) {
                final model = controller.dataSource[index];
                return Slidable(
                  // Specify a key if the Slidable is dismissible.
                  key: Key(model.title.toString()),
                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          controller.unCollectAction(index: index);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '取消收藏',
                      ),
                    ],
                  ),
                  // The child of the Slidable is what the user sees when the
                  // component is not dragged.
                  child: InfoCell(
                    model: model,
                    callback: (_) => Get.toNamed(Routes.web, arguments: model),
                  ),
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
