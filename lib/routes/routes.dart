import 'package:get/get.dart';
import 'package:getx_study/pages/coin_rank/bindings/coin_rank_binding.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_view.dart';

abstract class Routes {
  static const coinRink = '/coinRink';

  ///页面合集
  static final routePage = [
    GetPage(
        name: coinRink,
        page: () => const CoinRankView(),
        binding: CoinRankBinding()),
  ];
}
