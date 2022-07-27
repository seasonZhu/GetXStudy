import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';
import 'loading_view.dart';
import 'error_view.dart';
import 'empty_view.dart';

typedef WidgetCallback<T extends CoinRankController>  = Widget Function(T);

/// 响应View,这个view和网络请求的回调紧密联系,是我经过几次思考后得出的方案
class StatusView<T extends CoinRankController> extends StatelessWidget {
  final T controller;

  final WidgetCallback contentBuilder;

  get value => controller.status.value;

  const StatusView(
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
            const ErrorView(),
            contentBuilder(controller),
            const EmptyView(),
          ],
        );
      }),
    );
  }
}
