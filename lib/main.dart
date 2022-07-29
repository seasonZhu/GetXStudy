import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/base/getx_router_observer.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/hot_key_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';

import 'package:getx_study/http_util/api.dart';
import 'http_util/request.dart' as Moya;
import 'entity/base_entity.dart';
import 'routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Study',
      navigatorObservers: [GetXRouterObserver()],
      /// 通过使用initialRoute来保证绑定的操作
      initialRoute: Routes.myHomePage,
      getPages: Routes.routePage,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      /// 一开始的时候,我在初始化页面的发现并不能很好的进行初始化页面的binding操作,
      /// 于是写了一个临时页面,便于路由进去操作,看完官方的example懂了
      // home: const TestHome(),
    );
  }
}

class TestHome extends StatelessWidget {
  const TestHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("测试首页"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (() => Get.toNamed(Routes.myHomePage)),
          child: const Text("去普通的计数首页"),
        ),
      ),
    );
  }
}

void _requestTest({required int page}) async {
  /// 泛型里面带泛型的问题解决
  BaseEntity<PageEntity<List<CoinRankDatas>>> model =
      await Moya.Request.get(api: "${Api.getRankingList}${page.toString()}/json");
  print(model.toString());

  /// 这里的T是一个数组,Dart里面没有[HotKeyEntity]这种写法,必须使用List<HotKeyEntity>
  BaseEntity<List<HotKeyEntity>> keys =
      await Moya.Request.get(api: Api.getSearchHotKey);
  print(keys);

  BaseEntity<List<TabEntity>> tabs =
      await Moya.Request.get(api: Api.getProjectClassify);
  print(tabs);
}
