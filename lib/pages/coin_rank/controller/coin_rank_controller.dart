import 'package:get/get.dart';

import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/pages/coin_rank/data/coin_rank_repository.dart';

class CoinRankController extends GetxController {
  CoinRankController({required this.request});

  CoinRankRepository request;

  BaseEntity<PageEntity<List<CoinRankDatas>>>? response;

  List<CoinRankDatas> dataSource = [];

  var page = 1;

  @override
  void onInit() async {
    
    request = Get.find<CoinRankRepository>();
    response = await request.getCoinRankList(page);
    final models = response?.data?.dataSource ?? [];
    dataSource.addAll(models);

    update();

    super.onInit();
  }
}
