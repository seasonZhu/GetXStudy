import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/base/base_paged_list_controller.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';

class TabListController
    extends BasePagedListController<TabListRepository, ArticleInfoDatas> {
  late TagType tagType;

  late String id;

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  @override
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> fetchPage(int page) =>
      request.getList(page: page, id: id, tagType: tagType);
}
