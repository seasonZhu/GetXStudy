import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/http_util/request.dart' as http;
import 'package:getx_study/http_util/api.dart';

class WebRepository extends IRepository {
  Future<BaseEntity<Object?>> unCollectAction({required int originId}) =>
      http.Request.post(
          api: Api.postUnCollectArticle + originId.toString() + "/json");

  Future<BaseEntity<Object?>> collectAction({required int originId}) =>
      http.Request.post(api: Api.postCollectArticle + originId.toString() + "/json");
}
