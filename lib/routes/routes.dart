import 'package:get/get.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/my_home_page.dart';
import 'package:getx_study/pages/coin_rank/bindings/coin_rank_binding.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_page.dart';
import 'package:getx_study/pages/hot_key/bindings/hot_key_binding.dart';
import 'package:getx_study/pages/hot_key/view/hot_key_page.dart';
import 'package:getx_study/pages/search_result/bindings/search_result_binding.dart';
import 'package:getx_study/pages/search_result/view/search_result_page.dart';
import 'package:getx_study/pages/tree/bindings/tree_binding.dart';
import 'package:getx_study/pages/tree/view/tabs_page.dart';
import 'package:getx_study/pages/tree/view/tree_page.dart';

abstract class Routes {
  static const coinRink = '/coinRink';

  static const hotKey = "/hotKey";

  static const searchResult = "/searchResult";

  static const tree = "/tree";

  static const project = "/project";

  static const publicNumber = "/publicNumber";

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
      name: searchResult,
      page: () => const SearchResultPage(),
      binding: SearchResultBinding(),
    ),
    GetPage(
      name: tree,
      page: () => const TreePage(),
      binding: TreeBinding(TagType.tree),
    ),
    GetPage(
      name: project,
      page: () => const TabsPage(),
      binding: TabsBinding(TagType.project),
    ),
    GetPage(
      name: publicNumber,
      page: () => const TabsPage(),
      binding: TabsBinding(TagType.publicNumber),
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
