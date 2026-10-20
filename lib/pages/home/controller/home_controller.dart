import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/banner_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/home/repository/home_repository.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';

class HomeController
    extends BaseRefreshController<HomeRepository, ArticleInfoDatas> {
  List<BannerEntity> banners = [];
  List<ArticleInfoDatas> topArticles = [];
  final List<ArticleInfoDatas> _articles = [];
  bool _hasLoadedArticles = false;
  bool _hasRenderedContent = false;

  bool get hasContent => banners.isNotEmpty || dataSource.isNotEmpty;
  bool get swiperAutoPlay => banners.length > 1;

  @override
  void onInit() {
    super.onInit();
    initPage = Get.find<int>(tag: className(HomeController));
    page = initPage;
    refreshController = Get.find(tag: className(HomeController));
    Get.find<MyController>().autoLogin();
  }

  @override
  Future<void> onRefresh() => aRequest(type: ScrollViewActionType.refresh);

  @override
  Future<void> onLoadMore() => aRequest(type: ScrollViewActionType.loadMore);

  @override
  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {
    if (isClosed ||
        isLoading ||
        (type == ScrollViewActionType.loadMore && !_hasLoadedArticles)) {
      return;
    }
    isLoading = true;
    if (!hasContent && !_hasRenderedContent) status = ResponseStatus.loading;
    update();
    try {
      final results = await Future.wait([
        _loadArticles(type),
        if (type == ScrollViewActionType.refresh) _loadBanner(),
        if (type == ScrollViewActionType.refresh) _loadTopArticles(),
      ]);
      if (isClosed) return;
      if (results.first) {
        refreshControllerStatusUpdate(type);
      } else if (type == ScrollViewActionType.refresh) {
        refreshController.refreshFailed();
      } else {
        // 分页失败只结束加载；保留列表、页码，不向页脚添加错误文案。
        refreshController.loadComplete();
      }
      final failed = results.contains(false);
      if (failed && !hasContent && !_hasRenderedContent) {
        status = ResponseStatus.fail;
      } else {
        status = hasContent
            ? ResponseStatus.successHasContent
            : ResponseStatus.successNoData;
        if (failed) EasyLoading.showToast(AppText.t('common.load_failed'));
      }
    } finally {
      isLoading = false;
      if (!isClosed) update();
    }
  }

  Future<bool> _loadArticles(ScrollViewActionType type) async {
    final targetPage =
        type == ScrollViewActionType.refresh ? initPage : page + 1;
    try {
      final result = await request.getArticleList(page: targetPage);
      if (isClosed || !result.isSuccess) return false;
      response = result;
      page = targetPage;
      _hasLoadedArticles = true;
      if (type == ScrollViewActionType.refresh) _articles.clear();
      _articles.addAll(result.data?.dataSource ?? []);
      _combineArticles();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _combineArticles() {
    dataSource = [...topArticles, ..._articles];
    _updateContentStatus();
  }

  void _updateContentStatus() {
    if (hasContent) {
      _hasRenderedContent = true;
      status = ResponseStatus.successHasContent;
    } else if (_hasRenderedContent) {
      status = ResponseStatus.successNoData;
    }
    update();
  }

  Future<bool> _loadBanner() async {
    try {
      final result = await request.getBanner();
      if (isClosed || !result.isSuccess) return false;
      banners = List.of(result.data ?? []);
      _updateContentStatus();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _loadTopArticles() async {
    try {
      final result = await request.getTopArticleList();
      if (isClosed || !result.isSuccess) return false;
      topArticles = List.of(result.data ?? []);
      _combineArticles();
      return true;
    } catch (_) {
      return false;
    }
  }
}
