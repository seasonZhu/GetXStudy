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
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("测试首页"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: (() => Get.toNamed(Routes.myHomePage)),
            child: const Text("去普通的计数首页"),
          ),
        ),
      ),
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
