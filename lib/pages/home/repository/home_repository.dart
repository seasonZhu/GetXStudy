import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/banner_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/http_util/request.dart' as http;
import 'package:getx_study/http_util/api.dart';
import 'package:getx_study/http_util/request_client.dart';

class HomeRepository extends IRepository {
  Future<BaseEntity<List<BannerEntity>>> getBanner() =>
      http.Request.get(api: Api.getBanner);

  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList() =>
      http.Request.get(api: Api.getTopArticleList);

  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
          {required int page}) =>
      http.Request.get(api: "${Api.getArticleList}${page.toString()}/json");
}

/* 瞬间觉得自己写的HomeRepository不香了
class HomeRepository extends IRepository {
  Future<BaseEntity<List<BannerEntity>>> getBanner() =>
      requestClient.getBanner();

  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList() =>
      requestClient.getTopArticleList();

  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
          {required int page}) =>
      requestClient.getArticleList(page);
}
 */