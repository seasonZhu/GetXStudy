
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/http_util/request.dart' as Moya;
import 'package:getx_study/http_util/api.dart';

class CoinRankRepository extends IRepository {
  
  Future<BaseEntity<PageEntity<List<CoinRankDatas>>>> getCoinRankList(int page)
   => Moya.Request.get(api: "${Api.getRankingList}${page.toString()}/json");
}