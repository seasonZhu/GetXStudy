import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/hot_key_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';

import 'package:getx_study/http_util/api.dart';
import 'http_util/request.dart' as Moya;
import 'entity/base_entity.dart';
import 'routes/routes.dart';

import 'my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: Routes.routePage,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GetX 普通计数器'),
    );
  }
}

void _requestTest({required int page}) async {
  final api = "${Api.getRankingList}${page.toString()}/json";
  /// 泛型里面带泛型的问题解决
  BaseEntity<PageEntity<List<CoinRankDatas>>> model =
      await Moya.Request.get(api: api);
  print(model.toString());

  /// 这里的T是一个数组,Dart里面没有[HotKeyEntity]这种写法,必须使用List<HotKeyEntity>
  BaseEntity<List<HotKeyEntity>> keys =
      await Moya.Request.get(api: Api.getSearchHotKey);
  print(keys);

  BaseEntity<List<TabEntity>> tabs =
      await Moya.Request.get(api: Api.getProjectClassify);
  print(tabs);
}