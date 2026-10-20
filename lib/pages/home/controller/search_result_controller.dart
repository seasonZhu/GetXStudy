import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:get/get.dart';

import 'package:getx_study/base/base_paged_list_controller.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/home/repository/search_result_repository.dart';

class SearchResultController
    extends BasePagedListController<SearchResultRepository, ArticleInfoDatas> {
  late final String keyword;

  @override
  void onInit() {
    super.onInit();
    keyword = Get.arguments as String;
    initPage = Get.find(tag: className(SearchResultController));
    page = initPage;
    refreshController = Get.find(tag: className(SearchResultController));
  }

  @override
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> fetchPage(int page) =>
      request.searchKeyword(page: page, keyword: keyword);
}
