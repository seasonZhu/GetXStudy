import 'package:flutter/material.dart';
import 'package:getx_study/pages/common/refresh_status_view.dart';
import 'package:getx_study/pages/search_result/controller/search_result_controller.dart';
import 'package:getx_study/routes/routes.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class SearchResultPage extends GetView<SearchResultController> {
  const SearchResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("搜索"),
      ),
      body: RefreshStatusView(
        controller: controller,
        contentBuilder: (_) {
          return SmartRefresher(
            enablePullUp: true,
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: controller.dataSource.length,
              itemBuilder: (BuildContext context, int index) {
                final model = controller.dataSource[index];
                return Text(model.title.toString());
                return ListTile(
                  leading: Text(model.title.toString()),
                  title: Text(model.desc.toString()),
                  trailing: Text(model.author.toString()),
                  onTap: () => Get.toNamed(Routes.hotKey),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
