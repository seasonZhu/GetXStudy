import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/base/base_controller.dart';
import 'loading_view.dart';
import 'error_view.dart';
import 'empty_view.dart';

typedef WidgetCallback<T extends BaseController>  = Widget Function(T);

/// 响应View,这个view和网络请求的回调紧密联系,是我经过几次思考后得出的方案
class StatusView<T extends BaseController> extends StatelessWidget {
  final WidgetCallback<T> contentBuilder;

  final String? tag;

  const StatusView(
      {Key? key, required this.contentBuilder, this.tag})
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
            ErrorView(retryAction: controller.retry,),
            contentBuilder(controller),
            EmptyView(emptyTap: controller.emptyTap,)
          ],
        );
      }),
    );
  }
}
