import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/http_util/request.dart' as http;
import 'package:getx_study/http_util/api.dart';

class TreeListRepository extends IRepository {
  /// 获取体系文章列表
  ///
  /// [page] 页码，从 0 开始
  /// [tagId] 分类 ID
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getTreeArticleList({
    required int page,
    required String id,
  }) async {
        final params = <String, String>{};
        params["cid"] = id;
        final api = "${Api.getArticleList}${page.toString()}/json";
        return await http.Request.get(api: api, params: params);
  }
}
