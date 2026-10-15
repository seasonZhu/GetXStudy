import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';

class TabListController
    extends BaseRefreshController<TabListRepository, ArticleInfoDatas> {
  late TagType tagType;

  late String id;

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
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
      final result = await request.getList(
        page: targetPage,
        id: id,
        tagType: tagType,
      );
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
