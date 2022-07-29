import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/http_util/request.dart' as Moya;
import 'package:getx_study/http_util/api.dart';

class TreeRepository extends IRepository {
  
  Future<BaseEntity<List<TabEntity>>> getTree()
   => Moya.Request.get(api: Api.getTree);
}