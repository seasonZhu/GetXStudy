import 'package:getx_study/base/interface.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/http_util/request.dart' as Moya;

class TreeRepository extends IRepository {

  TreeRepository(this.type);

  TagType type;
  
  Future<BaseEntity<List<TabEntity>>> getTab()
   => Moya.Request.get(api: type.tabApi);
}

typedef TabsRepository = TreeRepository;