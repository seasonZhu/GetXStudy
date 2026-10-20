import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:get/get.dart';

import 'package:getx_study/base/base_paged_list_controller.dart';
import 'package:getx_study/entity/my_coin_history_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/my/repository/my_coin_history_repository.dart';

class MyCoinHistoryController extends BasePagedListController<
    MyCoinHistoryRepository, MyCoinHistoryDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find<int>(tag: className(MyCoinHistoryController));
    page = initPage;
    refreshController = Get.find(tag: className(MyCoinHistoryController));
  }

  @override
  Future<BaseEntity<PageEntity<List<MyCoinHistoryDatas>>>> fetchPage(
          int page) =>
      request.getCoinRankList(page);
}
