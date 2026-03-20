import 'package:get/get.dart';
import 'package:getx_study/example_app/state_mixin_example_page.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/coin_rank/bindings/coin_rank_binding.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_page.dart';
import 'package:getx_study/pages/common/unknown_page.dart';
import 'package:getx_study/pages/home/binding/home_binding.dart';
import 'package:getx_study/pages/home/binding/hot_key_binding.dart';
import 'package:getx_study/pages/home/view/hot_key_page.dart';
import 'package:getx_study/pages/launch/splash_page.dart';
import 'package:getx_study/pages/launch/welcome_page.dart';
import 'package:getx_study/pages/main/bindings/main_binding.dart';
import 'package:getx_study/pages/main/view/main_page.dart';
import 'package:getx_study/pages/my/binding/login_binding.dart';
import 'package:getx_study/pages/my/binding/my_binding.dart';
import 'package:getx_study/pages/my/binding/my_coin_history_binding.dart';
import 'package:getx_study/pages/my/binding/my_collect_binding.dart';
import 'package:getx_study/pages/my/binding/register_binding.dart';
import 'package:getx_study/pages/my/view/login_page.dart';
import 'package:getx_study/pages/my/view/my_coin_history_page.dart';
import 'package:getx_study/pages/my/view/my_collect_page.dart';
import 'package:getx_study/pages/my/view/register_page.dart';
import 'package:getx_study/pages/home/binding/search_result_binding.dart';
import 'package:getx_study/pages/home/view/search_result_page.dart';
import 'package:getx_study/pages/my/view/theme_setting_page.dart';
import 'package:getx_study/pages/tree/bindings/tabs_binding.dart';
import 'package:getx_study/pages/tree/bindings/tree_list_binding.dart';
import 'package:getx_study/pages/tree/view/tabs_page.dart';
import 'package:getx_study/pages/tree/view/tree_list_page.dart';
import 'package:getx_study/pages/tree/view/tree_page.dart';
import 'package:getx_study/pages/web/binding/web_binding.dart';
import 'package:getx_study/pages/web/view/web_page.dart';
import 'package:getx_study/routes/middleware/login_middleware.dart';
import 'package:getx_study/routes/middleware/web_middleware.dart';

abstract class Routes {
  Routes._();

  static const coinRink = '/coinRink';

  static const hotKey = "/hotKey";

  static const searchResult = "/searchResult";

  static const tree = "/tree";

  static const treeList = "/treeList";

  static const project = "/project";

  static const publicNumber = "/publicNumber";

  static const main = "/main";

  static const login = "/login";

  static const register = "/register";

  static const myCoinHistory = "/myCoinHistory";

  static const myCollect = "/myCollect";

  static const web = "/web/:notShowCollectIcon";

  static const welcome = "/welcome";

  static const splash = "/splash";

  static const unknown = "/unknown";

  static const stateMixinExample = "/stateMixinExample";

  static const themeSetting = "/themeSetting";

  ///页面合集
  static final routePage = [
    GetPage(
      name: coinRink,
      page: () => const CoinRankPage(),
      binding: CoinRankBinding(),
      middlewares: [LoginMiddleware()],
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: hotKey,
      page: () => const HotKeyPage(),
      binding: HotKeyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: searchResult,
      page: () => const SearchResultPage(),
      binding: SearchResultBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: tree,
      page: () => const TreePage(),
      binding: TabsBinding(TagType.tree),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: treeList,
      page: () => const TreeListPage(),
      binding: TreeListBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: project,
      page: () => const TabsPage(
        type: TagType.project,
      ),
      binding: TabsBinding(TagType.project),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: publicNumber,
      page: () => const TabsPage(
        type: TagType.publicNumber,
      ),
      binding: TabsBinding(TagType.publicNumber),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: main,
      page: () => const MainPage(),
      bindings: [
        MainBinding(),
        HomeBinding(),
        TabsBinding(TagType.project),
        TabsBinding(TagType.publicNumber),
        TabsBinding(TagType.tree),
        MyBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: myCoinHistory,
      page: () => const MyCoinHistoryPage(),
      binding: MyCoinHistoryBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: myCollect,
      page: () => const MyCollectPage(),
      bindings: [
        MyCollectBinding(),
        WebBinding(),
      ],
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: web,
      page: () => WebPage(),
      binding: WebBinding(),
      middlewares: [WebMiddleware()],
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: stateMixinExample,
      page: () => const StateMixinExamplePage(),
      binding: StateMixinBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: unknown,
      page: () => const UnknownPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: themeSetting,
      page: () => const ThemeSettingPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  static final unknownPage = GetPage(
    name: Routes.unknown,
    page: () => const UnknownPage(),
  );
}
