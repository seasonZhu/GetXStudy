import 'package:flutter/material.dart';
import 'package:getx_study/pages/common/refresh_status_view.dart';
import 'package:getx_study/routes/routes.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';

class CoinRankPage extends GetView<CoinRankController> {
  const CoinRankPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("积分排名"),
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

                return ListTile(
                  leading: Text(model.rank.toString()),
                  title: Text(model.username.toString()),
                  trailing: Text('积分:${model.level.toString()}'),
                  onTap: () => Get.toNamed(Routes.hotKey),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void dispose() {
    
  }
}
