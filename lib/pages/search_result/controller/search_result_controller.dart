import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/base/inferface.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/pages/search_result/repository/search_result_repository.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';

class SearchResultController
    extends BaseRefreshController<SearchResultRepository, ArticleInfoDatas>
    implements IClassName {
  @override
  void onInit() {
    super.onInit();
    initPage = 0;
    refreshController = Get.find(tag: SearchResultController.className);
  }

  @override
  Future<void> onRefresh() async {
    page = initPage;
    await aRequest(type: ScrollViewActionType.refresh);
  }

  @override
  Future<void> onLoadMore() async {
    page = page + 1;
    await aRequest(type: ScrollViewActionType.loadMore);
  }

  @override
  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {
    String keyword = Get.arguments;

    response = await request.searchKeyword(page: page, keyword: keyword);
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
        if (response?.data?.curPage == response?.data?.pageCount) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }

        if (status == ResponseStatus.successNoData && dataSource.isNotEmpty) {
          status = ResponseStatus.successHasContent;
        }

        break;
    }

    update();
  }

  static String? get className => (SearchResultController).toString();
}
