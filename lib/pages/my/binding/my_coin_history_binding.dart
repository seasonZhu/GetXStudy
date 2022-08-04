import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

import 'package:getx_study/pages/my/controller/my_coin_history_controller.dart';
import 'package:getx_study/pages/my/repository/my_coin_history_repository.dart';

class MyCoinHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MyCoinHistoryRepository(),
    );

    /// 需要通过tag来进行区分,避免RefreshController反复使用导致的内存泄露与崩溃
    Get.lazyPut(
      tag: MyCoinHistoryController.className,
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(
      tag: MyCoinHistoryController.className,
      () => 1,
    );
    Get.lazyPut(
      () => MyCoinHistoryController(),
    );
  }
}