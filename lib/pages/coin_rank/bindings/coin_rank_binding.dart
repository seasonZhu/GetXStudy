import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';
import 'package:getx_study/pages/coin_rank/data/coin_rank_repository.dart';

class CoinRankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinRankRepository>(
      () => CoinRankRepository(),
    );
    Get.lazyPut<RefreshController>(
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(() => 1);
    Get.lazyPut(
      () => CoinRankController(
        request: Get.find(),
        refreshController: Get.find(),
        page: Get.find(),
      ),
    );
  }
}
