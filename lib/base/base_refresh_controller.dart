import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import "package:getx_study/base/base_controller.dart";
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/logger/logger.dart';

abstract class BaseRefreshController<R extends IRepository, T>
    extends BaseController {
  late R request;

  bool isLoading = false;

  late RefreshController refreshController;

  late int page;

  late int initPage;

  BaseEntity<PageEntity<List<T>>>? response;

  List<T> dataSource = [];

  @override
  void onInit() async {
    super.onInit();
    request = Get.find<R>();
  }

  @override
  void onClose() {
    super.onClose();
    logger.d("onClose");
  }

  Future<void> onRefresh() async {}

  Future<void> onLoadMore() async {}

  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {}

  void refreshControllerStatusUpdate(ScrollViewActionType type) {
    switch (type) {
      case ScrollViewActionType.refresh:
        refreshController.refreshCompleted(resetFooterState: true);
        if (response?.data?.over == true ||
            (response?.data?.curPage != null &&
                response?.data?.curPage == response?.data?.pageCount)) {
          refreshController.loadNoData();
        }
        break;
      case ScrollViewActionType.loadMore:
        if (response?.data?.over == true ||
            (response?.data?.curPage != null &&
                response?.data?.curPage == response?.data?.pageCount)) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }

        checkDataSourceAndStatus();
        break;
    }
  }

  void checkDataSourceAndStatus() {
    status = dataSource.isEmpty
        ? ResponseStatus.successNoData
        : ResponseStatus.successHasContent;
  }

  void failHandle(ScrollViewActionType type) {
    status = dataSource.isEmpty
        ? ResponseStatus.fail
        : ResponseStatus.successHasContent;
    switch (type) {
      case ScrollViewActionType.refresh:
        refreshController.refreshFailed();
        break;
      case ScrollViewActionType.loadMore:
        refreshController.loadFailed();
        break;
    }
  }

  @override
  void retry() {
    onRefresh();
  }

  @override
  void emptyTap() {
    onRefresh();
  }
}
