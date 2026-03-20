import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/tree/repository/tree_list_repository.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';

class TreeListController
    extends BaseRefreshController<TreeListRepository, ArticleInfoDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find(tag: className(TreeListController));
    page = initPage;
    refreshController = Get.find(tag: className(TreeListController));
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
    // 从路由参数获取 tagId
    TabEntity model = Get.arguments;
    final id = model.id.toString();

    response = await request
        .getTreeArticleList(page: page, id: id)
        .catchError((error) {
      return processError(type: type, error: error);
    });
    status = response?.responseStatus ?? ResponseStatus.loading;

    final models = response?.data?.dataSource ?? [];

    switch (type) {
      case ScrollViewActionType.refresh:
        dataSource.clear();
        dataSource.addAll(models);
        break;
      case ScrollViewActionType.loadMore:
        dataSource.addAll(models);
        break;
    }

    refreshControllerStatusUpdate(type);

    update();
  }
}
