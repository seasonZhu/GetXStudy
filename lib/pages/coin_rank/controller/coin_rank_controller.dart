import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:get/get.dart';

import 'package:getx_study/base/base_paged_list_controller.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/coin_rank/repository/coin_rank_repository.dart';

class CoinRankController
    extends BasePagedListController<CoinRankRepository, CoinRankDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find<int>(tag: className(CoinRankController));
    page = initPage;
    refreshController = Get.find(tag: className(CoinRankController));
  }

  @override
  Future<BaseEntity<PageEntity<List<CoinRankDatas>>>> fetchPage(int page) =>
      request.getCoinRankList(page);
}
