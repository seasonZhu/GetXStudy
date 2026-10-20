import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/my/controller/my_coin_history_controller.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class MyCoinHistoryPage extends GetView<MyCoinHistoryController> {
  const MyCoinHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        middle: Text(AppText.t('my.coins')),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: StatusView<MyCoinHistoryController>(
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
                    leading: Text(model.reason.toString()),
                    title: Text(model.desc.toString()),
                    trailing: Text(AppText.number(model.coinCount)),
                    onTap: () => Get.toNamed(Routes.stateMixinExample),
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
