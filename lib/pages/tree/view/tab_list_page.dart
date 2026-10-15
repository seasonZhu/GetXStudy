import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:getx_study/pages/common/empty_view.dart';
import 'package:getx_study/pages/common/error_view.dart';
import 'package:getx_study/pages/common/loading_view.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/common/info_cell.dart';
import 'package:getx_study/routes/routes.dart';

class TabListPage extends StatelessWidget {
  final String controllerTag;

  const TabListPage({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabListController>(
      tag: controllerTag,
      autoRemove: false,
      builder: ((controller) {
        final isEmpty = controller.dataSource.isEmpty;
        return SmartRefresher(
          enablePullUp: !isEmpty,
          header: isEmpty
              ? CustomHeader(
                  height: 0,
                  builder: (context, mode) => const SizedBox.shrink(),
                )
              : const RefreshHeader(),
          footer: const RefreshFooter(),
          controller: controller.refreshController,
          onRefresh: controller.onRefresh,
          onLoading: controller.onLoadMore,
          child: CustomScrollView(
            key: PageStorageKey(controllerTag),
            slivers: [
              if (isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: switch (controller.status) {
                    ResponseStatus.fail =>
                      ErrorView(retryAction: controller.retry),
                    ResponseStatus.loading => const LoadingView(),
                    ResponseStatus.successNoData ||
                    ResponseStatus.successHasContent =>
                      EmptyView(emptyTap: controller.emptyTap),
                  },
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final model = controller.dataSource[index];
                    return InfoCell(
                      model: model,
                      callback: (_) =>
                          Get.toNamed(Routes.web, arguments: model),
                    );
                  }, childCount: controller.dataSource.length),
                ),
            ],
          ),
        );
      }),
    );
  }
}
