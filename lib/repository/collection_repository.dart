import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/http_util/api.dart';
import 'package:getx_study/http_util/request.dart' as http;

class CollectionRepository {
  Future<BaseEntity<Object?>> setCollected(int articleId, bool collected) =>
      http.Request.post(
        api: '${collected ? Api.postCollectArticle : Api.postUnCollectArticle}'
            '$articleId/json',
        showBusinessErrorToast: false,
      );
}
