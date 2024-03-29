import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/http_util/request.dart' as http;
import 'package:getx_study/http_util/api.dart';

class SearchResultRepository extends IRepository {
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> searchKeyword(
      {required int page, required String keyword}) async {
    final params = <String, String>{};
    params["k"] = keyword;
    return await http.Request.post(
        api: "${Api.postQueryKey}${page.toString()}/json", params: params);
  }
}
