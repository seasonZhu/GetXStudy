import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/my_coin_history_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/http_util/request.dart' as http;
import 'package:getx_study/http_util/api.dart';

class MyCoinHistoryRepository extends IRepository {
  Future<BaseEntity<PageEntity<List<MyCoinHistoryDatas>>>> getCoinRankList(
          int page) =>
      http.Request.get(api: "${Api.getCoinList}${page.toString()}/json");
}