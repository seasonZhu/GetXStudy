import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/http_util/request.dart' as http;
import 'package:getx_study/http_util/api.dart';

class TabListRepository extends IRepository {
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getList(
      {required int page, required String id, required TagType tagType}) async {
    switch (tagType) {
      case TagType.project:
        final params = <String, String>{};
        params["cid"] = id.toString();
        final api = "${Api.getProjectClassifyList}${page.toString()}/json";
        return await http.Request.get(api: api, params: params);
      case TagType.publicNumber:
        final api =
            "${Api.getPubilicNumberList}${id.toString()}/${page.toString()}/json";
        return await http.Request.get(api: api);
      case TagType.tree:
        return BaseEntity<PageEntity<List<ArticleInfoDatas>>>(null, null, null);
    }
  }
}
