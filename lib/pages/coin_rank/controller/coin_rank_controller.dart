import 'package:get/get.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/pages/coin_rank/data/coin_rank_repository.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';

class CoinRankController extends GetxController {
  CoinRankController(
      {required this.request,
      required this.refreshController,
      required this.page});

  CoinRankRepository request;

  RefreshController refreshController;

  int page;

  BaseEntity<PageEntity<List<CoinRankDatas>>>? response;

  ResponseStatus status = ResponseStatus.loading;

  List<CoinRankDatas> dataSource = [];

  late int _initPage;

  Future<void> onRefresh() async {
    page = _initPage;
    await _request(type: ScrollViewActionType.refresh);
  }

  Future<void> onLoadMore() async {
    page = page + 1;
    await _request(type: ScrollViewActionType.loadMore);
  }

  @override
  void onInit() async {
    _initPage = page;
    //await _request(type: ScrollViewActionType.refresh);
    super.onInit();
  }

  Future<void> _request({required ScrollViewActionType type}) async {
    request = Get.find<CoinRankRepository>();
    response = await request.getCoinRankList(page);
    status = response?.responseStatus ?? ResponseStatus.loading;

    final models = response?.data?.dataSource ?? [];

    switch (type) {
      case ScrollViewActionType.refresh:
        dataSource.clear();
        dataSource.addAll(models);
        refreshController.refreshCompleted();
        break;
      case ScrollViewActionType.loadMore:
        dataSource.addAll(models);
        if ((response?.data?.offset ?? false) == true) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
        break;
    }

    update();
  }
}
