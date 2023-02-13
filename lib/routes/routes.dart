import 'package:get/get.dart';
import 'package:getx_study/account_manager/account_binding.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/my_home_page.dart';
import 'package:getx_study/pages/coin_rank/bindings/coin_rank_binding.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_page.dart';
import 'package:getx_study/pages/common/unknow_page.dart';
import 'package:getx_study/pages/home/binding/home_binding.dart';
import 'package:getx_study/pages/hot_key/bindings/hot_key_binding.dart';
import 'package:getx_study/pages/hot_key/view/hot_key_page.dart';
import 'package:getx_study/pages/launch/splash_page.dart';
import 'package:getx_study/pages/launch/welcom_page.dart';
import 'package:getx_study/pages/main/bindings/main_binding.dart';
import 'package:getx_study/pages/main/view/main_page.dart';
import 'package:getx_study/pages/my/binding/my_binding.dart';
import 'package:getx_study/pages/my/binding/my_coin_history_binding.dart';
import 'package:getx_study/pages/my/binding/my_collect_binding.dart';
import 'package:getx_study/pages/my/view/login_page.dart';
import 'package:getx_study/pages/my/view/my_coin_history_page.dart';
import 'package:getx_study/pages/my/view/my_collect_page.dart';
import 'package:getx_study/pages/my/view/register_page.dart';
import 'package:getx_study/pages/project_public_number/binding/project_binding.dart';
import 'package:getx_study/pages/project_public_number/binding/public_number_binding.dart';
import 'package:getx_study/pages/search_result/bindings/search_result_binding.dart';
import 'package:getx_study/pages/search_result/view/search_result_page.dart';
import 'package:getx_study/pages/tree/bindings/tabs_binding.dart';
import 'package:getx_study/pages/tree/bindings/tree_binding.dart';
import 'package:getx_study/pages/tree/view/tabs_page.dart';
import 'package:getx_study/pages/tree/view/tree_page.dart';
import 'package:getx_study/pages/web/binding/web_binding.dart';
import 'package:getx_study/pages/web/view/web_page.dart';

abstract class Routes {
  Routes._();

  static const coinRink = '/coinRink';

  static const hotKey = "/hotKey";

  static const searchResult = "/searchResult";

  static const tree = "/tree";

  static const project = "/project";

  static const publicNumber = "/publicNumber";

  static const main = "/main";

  static const login = "/login";

  static const register = "/register";

  static const myCoinHistory = "/myCoinHistory";

  static const myCollect = "/myCollect";

  static const web = "/web/:notShowCollectIcon";

  static const unknown = "/unknown";

  static const myHomePage = "/myHomePage";

  static const myNextPage = "/myNextPage";

  static const welcome = "/welcome";

  static const splash = "/splash";

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
      name: main,
      page: () => const MainPage(),
      bindings: [
        MainBinding(),
        HomeBinding(),
        TabsBinding(TagType.project),
        TreeBinding(TagType.tree),
        ProjectBinding(),
        PublicNumberBinding(),
        MyBinding(),
        AccountBinding(),
      ],
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
    ),
    GetPage(
      name: register,
      page: () => RegisterPage(),
    ),
    GetPage(
      name: myCoinHistory,
      page: () => const MyCoinHistoryPage(),
      binding: MyCoinHistoryBinding(),
    ),
    GetPage(
      name: myCollect,
      page: () => const MyCollectPage(),
      bindings: [
        MyCollectBinding(),
        WebBinding(),
      ],
    ),
    GetPage(
      name: web,
      page: () => WebPage(),
      binding: WebBinding(),
    ),
    GetPage(
      name: unknown,
      page: () => const UnknownPage(),
    ),

    GetPage(
      name: welcome,
      page: () => WelcomePage(),
    ),
    GetPage(
      name: splash,
      page: () => SplashPage()
    ),

    /// 以下是测试路由
    GetPage(
      name: myHomePage,
      page: () => const MyHomePage(title: "普通计数器"),
      binding: MyHomeBindings(),
    ),
    GetPage(
      name: myNextPage,
      page: () => MyNextPage(title: "响应式计数器"),
      binding: MyNextBindings(),
    ),
  ];

  static final unknownPage = GetPage(
    name: Routes.unknown,
    page: () => const UnknownPage(),
  );
}
