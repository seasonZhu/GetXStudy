import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/my/repository/my_collect_repository.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/app_service/account_service.dart';

class MyCollectController
    extends BaseRefreshController<MyCollectRepository, ArticleInfoDatas> {
  final Set<int> pendingUncollectIds = {};
  final Set<int> _removedDuringLoad = {};

  @override
  void onInit() {
    super.onInit();
    initPage = Get.find(tag: className(MyCollectController));
    page = initPage;
    refreshController = Get.find(tag: className(MyCollectController));
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
    _removedDuringLoad.clear();
    final targetPage =
        type == ScrollViewActionType.refresh ? initPage : page + 1;
    final account = AccountService.find;
    final revision = account.sessionRevision;
    try {
      final result = await request.getCollectArticleList(page: targetPage);
      if (isClosed) return;
      if (account.sessionRevision != revision) {
        failHandle(type);
        return;
      }
      if (!result.isSuccess) {
        failHandle(type);
        return;
      }
      response = result;
      page = targetPage;
      // 请求发出后已取消的文章，不能被较早的刷新结果重新带回。
      final models = (result.data?.dataSource ?? <ArticleInfoDatas>[])
          .where((item) => !_removedDuringLoad.contains(item.originId));
      if (type == ScrollViewActionType.refresh) {
        dataSource = models.toList();
      } else {
        dataSource.addAll(models);
      }
      checkDataSourceAndStatus();
      refreshControllerStatusUpdate(type);
    } catch (_) {
      if (!isClosed) failHandle(type);
    } finally {
      isLoading = false;
      _removedDuringLoad.clear();
      if (!isClosed) update();
    }
  }

  Future<void> unCollectAction({required int originId}) async {
    if (isClosed || !pendingUncollectIds.add(originId)) return;
    final account = AccountService.find;
    final revision = account.sessionRevision;
    update();
    try {
      final result = await request.unCollectAction(originId: originId);
      if (isClosed || account.sessionRevision != revision) return;
      if (result.isSuccess) _removeById(originId);
      Get.snackbar(
        '',
        result.isSuccess ? '取消收藏成功' : (result.errorMsg ?? '取消收藏失败'),
        duration: const Duration(seconds: 1),
      );
    } catch (_) {
      if (!isClosed && account.sessionRevision == revision) {
        Get.snackbar('', '取消收藏失败，请重试');
      }
    } finally {
      pendingUncollectIds.remove(originId);
      if (!isClosed) update();
    }
  }

  void _removeById(int originId) {
    if (isLoading) _removedDuringLoad.add(originId);
    AccountService.find.info?.collectIds?.removeWhere((id) => id == originId);
    dataSource.removeWhere((item) => item.originId == originId);
    checkDataSourceAndStatus();
  }

  void removeUnCollectItem(IWebLoadInfo webLoadInfo) {
    final originId = webLoadInfo.originId ?? webLoadInfo.id;
    if (isClosed || originId == null) return;
    _removeById(originId);
    update();
  }
}
