import 'package:get/get.dart';
import 'package:getx_study/my_home_page.dart';
import 'package:getx_study/pages/coin_rank/bindings/coin_rank_binding.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_page.dart';
import 'package:getx_study/pages/hot_key/bindings/hot_key_binding.dart';
import 'package:getx_study/pages/hot_key/view/hot_key_page.dart';

abstract class Routes {
  static const coinRink = '/coinRink';

  static const hotKey = "/hotKey";

  static const myHomePage = "/myHomePage";

  static const myNextPage = "/myNextPage";

  ///页面合集
  static final routePage = [
    GetPage(
      name: coinRink,
      page: () => const CoinRankPage(),
      binding: CoinRankBinding(),
    ),
    GetPage(
      name: hotKey,
      page: () => const HotKeyPage(),
      binding: HotKeyBinding(),
    ),
    GetPage(
      name: myHomePage,
      page: () => MyHomePage(title: "普通计数器"),
      binding: MyHomeBindings(),
    ),
    GetPage(
      name: myNextPage,
      page: () => MyNextPage(title: "响应式计数器"),
      binding: MyNextBindings(),
    ),
  ];
}
