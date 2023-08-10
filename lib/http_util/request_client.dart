import 'dart:io';

import 'package:dio/dio.dart';
import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/http_util/http_util.dart';

import 'package:getx_study/http_util/api.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/banner_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:retrofit/retrofit.dart';

part 'request_client.g.dart';

const timeout = Duration(seconds: 60);

final _dio = Dio(
  BaseOptions(
    baseUrl: Api.baseUrl,
    connectTimeout: timeout,
    receiveTimeout: timeout,
    headers: {HttpHeaders.cookieHeader: AccountManager().cookieHeaderValue},
  ),
).addPlugins;

final requestClient = RequestClient(_dio);

@RestApi(
  // 请求域名
  baseUrl: Api.baseUrl,
  // 数据解析方式，默认为json
  parser: Parser.JsonSerializable,
)
abstract class RequestClient {
  // 标准的构建方式
  // dio: 传入发起网络请求的对象
  // baseUrl: 请求域名，优先级高于注解
  factory RequestClient(Dio dio, {String baseUrl}) = _RequestClient;

  @GET(Api.getBanner)
  Future<BaseEntity<List<BannerEntity>>> getBanner();

  @GET(Api.getTopArticleList)
  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList();

  @GET("${Api.getArticleList}{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
      @Path() int page);
}
