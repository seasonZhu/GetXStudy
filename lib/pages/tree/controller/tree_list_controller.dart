import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:get/get.dart';

import 'package:getx_study/base/base_paged_list_controller.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/tree/repository/tree_list_repository.dart';

class TreeListController
    extends BasePagedListController<TreeListRepository, ArticleInfoDatas> {
  late final String treeId;

  @override
  void onInit() {
    super.onInit();
    treeId = (Get.arguments as TabEntity).id.toString();
    initPage = Get.find(tag: className(TreeListController));
    page = initPage;
    refreshController = Get.find(tag: className(TreeListController));
  }

  @override
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> fetchPage(int page) =>
      request.getTreeArticleList(page: page, id: treeId);
}
