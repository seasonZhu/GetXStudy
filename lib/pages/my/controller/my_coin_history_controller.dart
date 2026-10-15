import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/entity/my_coin_history_entity.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/my/repository/my_coin_history_repository.dart';

class MyCoinHistoryController
    extends BaseRefreshController<MyCoinHistoryRepository, MyCoinHistoryDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find<int>(tag: className(MyCoinHistoryController));
    page = initPage;
    refreshController = Get.find(tag: className(MyCoinHistoryController));
  }

  @override
  Future<void> onRefresh() async {
    await aRequest(type: ScrollViewActionType.refresh);
  }

  @override
  Future<void> onLoadMore() async {
    await aRequest(type: ScrollViewActionType.loadMore);
  }

  @override
  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {
    if (isLoading || isClosed) return;
    isLoading = true;
    final targetPage =
        type == ScrollViewActionType.refresh ? initPage : page + 1;
    try {
      final result = await request.getCoinRankList(targetPage);
      if (isClosed) return;
      if (!result.isSuccess) {
        failHandle(type);
        return;
      }
      response = result;
      page = targetPage;
      final models = result.data?.dataSource ?? [];
      if (type == ScrollViewActionType.refresh) {
        dataSource = List.of(models);
      } else {
        dataSource.addAll(models);
      }
      checkDataSourceAndStatus();
      refreshControllerStatusUpdate(type);
    } catch (error) {
      if (!isClosed) failHandle(type);
    } finally {
      isLoading = false;
      if (!isClosed) update();
    }
  }
}
