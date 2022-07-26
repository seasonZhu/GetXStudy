import 'package:get/get.dart';

import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/pages/coin_rank/data/coin_rank_repository.dart';

class CoinRankController extends GetxController {
  CoinRankController({required this.request});

  CoinRankRepository request;

  BaseEntity<PageEntity<List<CoinRankDatas>>>? response;

  var dataSource = List.filled(0, CoinRankDatas()).obs;

  var page = 1;

  @override
  void onInit() async {
    super.onInit();
    request = Get.find<CoinRankRepository>();
    getCoinRankList();
  }

  void getCoinRankList() async {
    response = await request.getCoinRankList(page);
    if (response!.data!.dataSource != null) {
      final models = response!.data!.dataSource!;
      dataSource.addAll(models);
    }
  }
}
