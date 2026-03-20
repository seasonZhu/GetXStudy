import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:getx_study/pages/common/empty_view.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/common/status_view.dart';

class TreeListPage extends StatelessWidget {

  const TreeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    TabEntity model = Get.arguments;
    final controller = TabListController();
    final tagType = TagType.tree;
    controller.tagType = tagType;
    controller.id = model.id.toString();
    controller.request = Get.find();
    controller.refreshController = RefreshController(initialRefresh: true);
    controller.page = tagType.pageNum;
    controller.initPage = tagType.pageNum;
    Get.put(controller);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(model.name.toString()),
      ),
      child: StatusView<TabListController>(
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
                return InfoCell(
                  model: model,
                  callback: (_) => Get.toNamed(Routes.web, arguments: model),
                );
              },
            ),
          );
        },
      ),
    );
  }
}