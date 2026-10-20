import 'dart:async';

import 'package:getx_study/app_service/collection_service.dart';
import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/my/repository/my_collect_repository.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/app_service/account_service.dart';

class MyCollectController
    extends BaseRefreshController<MyCollectRepository, ArticleInfoDatas> {
  late final CollectionService collections;
  StreamSubscription<CollectionChange>? _collectionSubscription;
  final Map<int, bool> _changesDuringLoad = {};
  int _loadGeneration = 0;

  bool isPending(int articleId) => collections.isPending(articleId);

  @override
  void onInit() {
    super.onInit();
    collections = Get.find<CollectionService>();
    _collectionSubscription = collections.changes.listen(_onCollectionChange);
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
    _changesDuringLoad.clear();
    final generation = ++_loadGeneration;
    final targetPage =
        type == ScrollViewActionType.refresh ? initPage : page + 1;
    final account = AccountService.find;
    final revision = account.sessionRevision;
    final info = account.info;
    try {
      final result = await request.getCollectArticleList(page: targetPage);
      if (isClosed ||
          generation != _loadGeneration ||
          account.sessionRevision != revision ||
          !identical(account.info, info)) {
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
          .where((item) => _changesDuringLoad[item.originId] != false);
      if (type == ScrollViewActionType.refresh) {
        dataSource = models.toList();
      } else {
        dataSource.addAll(models);
      }
      checkDataSourceAndStatus();
      refreshControllerStatusUpdate(type);
    } catch (_) {
      if (!isClosed && generation == _loadGeneration) failHandle(type);
    } finally {
      if (!isClosed && generation == _loadGeneration) {
        isLoading = false;
        _changesDuringLoad.clear();
        update();
      }
    }
  }

  void _onCollectionChange(CollectionChange change) {
    if (isClosed) return;
    if (change.sessionChanged) {
      _loadGeneration++;
      isLoading = false;
      _changesDuringLoad.clear();
      dataSource = [];
      response = null;
      page = initPage;
      refreshController.refreshCompleted(resetFooterState: true);
      refreshController.loadComplete();
      checkDataSourceAndStatus();
    } else if (change.articleId != null && change.collected != null) {
      if (isLoading) _changesDuringLoad[change.articleId!] = change.collected!;
      if (!change.collected!) {
        dataSource.removeWhere((item) => item.originId == change.articleId);
        checkDataSourceAndStatus();
      }
    }
    update();
  }

  Future<void> unCollectAction({required int originId}) async {
    if (isClosed) return;
    final revision = collections.account.sessionRevision;
    final result = await collections.setCollected(originId, false);
    if (isClosed || collections.account.sessionRevision != revision) return;
    if (result.type == CollectionResultType.success ||
        result.type == CollectionResultType.failure) {
      Get.snackbar(
          '',
          result.type == CollectionResultType.success
              ? '取消收藏成功'
              : (result.message ?? '取消收藏失败'),
          duration: const Duration(seconds: 1));
    }
  }

  @override
  void onClose() {
    _collectionSubscription?.cancel();
    refreshController.dispose();
    super.onClose();
  }
}
