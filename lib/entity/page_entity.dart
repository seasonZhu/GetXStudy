import 'package:getx_study/generated/json/base/json_convert_content.dart';
import 'package:getx_study/resource/constant.dart';

/// 有关与BaseEntity<PageEntity<CoinRankDatas>>这种泛型解析我还没有找个非常好的方案,目前还是保证单层解析
class PageEntity<T> {
  int? curPage;
  T? datas;
  int? offset;
  bool? over;
  int? pageCount;
  int? size;
  int? total;

  PageEntity.fromJson(Map<String, dynamic> json) {
    curPage = json[Constant.curPage] as int?;
    offset = json[Constant.offset] as int?;
    over = json[Constant.over] as bool?;
    pageCount = json[Constant.pageCount] as int?;
    size = json[Constant.size] as int?;
    total = json[Constant.total] as int?;
    if (json.containsKey(Constant.datas)) {
      datas = _generateOBJ<T>(json[Constant.datas] as Object);
    }
  }

  T? _generateOBJ<O>(Object json) {
    if (T.toString() == 'String') {
      return json.toString() as T;
    } else if (T.toString() == 'Map<dynamic, dynamic>') {
      return json as T;
    } else {
      /// List类型数据由fromJsonAsT判断处理
      return JsonConvert.fromJsonAsT<T>(json);
    }
  }
}
