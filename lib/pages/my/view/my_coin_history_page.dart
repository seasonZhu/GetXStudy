import 'package:flutter/material.dart';
import 'package:getx_study/pages/common/refresh_status_view.dart';
import 'package:getx_study/pages/my/controller/my_coin_history_controller.dart';
import 'package:getx_study/routes/routes.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';

class MyCoinHistoryPage extends GetView<MyCoinHistoryController> {
  const MyCoinHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的积分"),
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
              shrinkWrap: true,
              itemCount: controller.dataSource.length,
              itemBuilder: (BuildContext context, int index) {
                final model = controller.dataSource[index];

                return ListTile(
                  leading: Text(model.reason.toString()),
                  title: Text(model.desc.toString()),
                  trailing: Text(model.coinCount.toString()),
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
