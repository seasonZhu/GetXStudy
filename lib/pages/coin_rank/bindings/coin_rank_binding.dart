import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';
import 'package:getx_study/pages/coin_rank/data/coin_rank_repository.dart';

class CoinRankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinRankRepository>(() => CoinRankRepository());
    Get.lazyPut(() => CoinRankController(request: Get.find()));
  }
}