import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'loading_view.dart';
import 'error_view.dart';
import 'empty_view.dart';

typedef RefreshWidgetCallback<T extends BaseRefreshController>  = Widget Function(T);

/// 响应View,这个view和网络请求的回调紧密联系,是我经过几次思考后得出的方案
class RefreshStatusView<T extends BaseRefreshController> extends StatelessWidget {
  final T controller;

  final RefreshWidgetCallback contentBuilder;

  get value => controller.status.value;

  const RefreshStatusView(
      {Key? key, required this.controller, required this.contentBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      builder: ((controller) {
        return IndexedStack(
          index: value,
          children: [
            const LoadingView(),
            ErrorView(retryAction: controller.retry,),
            contentBuilder(controller),
            const EmptyView(),
          ],
        );
      }),
    );
  }
}
