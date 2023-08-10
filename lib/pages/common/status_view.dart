import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/base_controller.dart';
import 'package:getx_study/enum/response_status.dart';
import 'loading_view.dart';
import 'error_view.dart';
import 'empty_view.dart';

typedef WidgetCallback<T extends BaseController> = Widget Function(T);

/// 响应View,这个view和网络请求的回调紧密联系,是我经过几次思考后得出的方案
class StatusView<T extends BaseController> extends StatelessWidget {
  final WidgetCallback<T> contentBuilder;

  final String? tag;

  const StatusView({Key? key, required this.contentBuilder, this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      tag: tag,
      builder: ((controller) {
        return IndexedStack(
          index: controller.status.value,
          children: [
            const LoadingView(),
            ErrorView(
              retryAction: controller.retry,
            ),
            contentBuilder(controller),
            EmptyView(
              emptyTap: controller.emptyTap,
            )
          ],
        );
      }),
    );
  }

  /// 这种方式好像在构建首页的时候无法触发首页刷新操作,导致无法做首页的网络请求,正常的页面无法构建
  Widget responseStatusWidgetWithSwitch(T controller) {
    switch (controller.status) {
      case ResponseStatus.loading:
        return const LoadingView();
      case ResponseStatus.fail:
        return ErrorView(
          retryAction: controller.retry,
        );
      case ResponseStatus.successHasContent:
        return contentBuilder(controller);
      case ResponseStatus.successNoData:
        return EmptyView(
          emptyTap: controller.emptyTap,
        );
    }
  }
}
