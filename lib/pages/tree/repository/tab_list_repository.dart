import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/http_util/request.dart' as Moya;
import 'package:getx_study/http_util/api.dart';

class TabListRepository extends IRepository {
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getList(
      {required int page, required String id, required TagType tagType}) async {
    switch (tagType) {
      case TagType.project:
        var params = <String, String>{};
        params["cid"] = id.toString();
        return await Moya.Request.get(
            api: Api.getProjectClassifyList + page.toString() + "/json",
            params: params);
      case TagType.publicNumber:
        return await Moya.Request.get(api: Api.getPubilicNumberList + id.toString() + "/" + page.toString() + "/json");
      case TagType.tree:
        return BaseEntity<PageEntity<List<ArticleInfoDatas>>>(null, null, null);
    }
  }
}
