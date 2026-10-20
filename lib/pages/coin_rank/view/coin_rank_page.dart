import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';
import 'package:getx_study/pages/common/status_view.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';

class CoinRankPage extends GetView<CoinRankController> {
  const CoinRankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('coin.title')),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: StatusView<CoinRankController>(
          contentBuilder: (controller) {
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

                  return ListTile(
                    leading: Text(AppText.number(model.rank)),
                    title: Text(model.username.toString()),
                    trailing: Text(AppText.t('coin.points', {'points': AppText.number(model.level)})),
                    onTap: () => logger.d(model.username),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
