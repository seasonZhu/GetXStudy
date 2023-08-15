import 'package:get/get.dart';

import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/banner_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:getx_study/logger/class_name.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/pages/home/repository/home_repository.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';

class HomeController
    extends BaseRefreshController<HomeRepository, ArticleInfoDatas> {
  var banners = [];

  var swiperAutoPlay = false;

  @override
  void onInit() {
    super.onInit();
    initPage = Get.find<int>(tag: className(HomeController));
    page = initPage;
    refreshController = Get.find(tag: className(HomeController));

    final myController = Get.find<MyController>();
    myController.autoLogin();
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
    response = await request.getArticleList(page: page).catchError((error) {
      return processError(type: type, error: error);
    });
    status = response?.responseStatus ?? ResponseStatus.loading;

    final models = response?.data?.dataSource ?? [];

    switch (type) {
      case ScrollViewActionType.refresh:
        final result = await Future.wait(
          [
            request.getBanner(),
            request.getTopArticleList(),
            request.getArticleList(page: page),
          ],
          cleanUp: (successValue) => logger.d(successValue),
        );

        if (result.length == 3) {
          final bannerModels = result[0].data as List<BannerEntity>;
          final topArticleModels = result[1].data as List<ArticleInfoDatas>;
          response =
              result[2] as BaseEntity<PageEntity<List<ArticleInfoDatas>>>;
          final articleModels = response?.data?.dataSource ?? [];

          /// 轮播图赋值
          banners = bannerModels;
          swiperAutoPlay = banners.length > 1 ? true : false;

          /// 列表赋值
          dataSource = topArticleModels;
          dataSource.addAll(articleModels);
        } else {
          response = BaseEntity(null, null, null);

          swiperAutoPlay = false;
        }

        break;
      case ScrollViewActionType.loadMore:
        response = await request.getArticleList(page: page);
        dataSource.addAll(models);
        break;
    }

    refreshControllerStatusUpdate(type);

    update();
  }
}
