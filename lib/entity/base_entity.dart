import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/generated/json/base/json_convert_content.dart';

import 'package:getx_study/resource/constant.dart';

class BaseEntity<T> {
  BaseEntity(this.errorCode, this.errorMsg, this.data);

  BaseEntity.fromJson(Map<String, dynamic> json) {
    errorCode = json[Constant.errorCode] as int?;
    errorMsg = json[Constant.errorMsg] as String?;
    if (json.containsKey(Constant.data)) {
      data = _generateOBJ<T>(json[Constant.data] as Object);
    }
  }

  int? errorCode;
  String? errorMsg;
  T? data;

  bool get isSuccess => errorCode == 0;

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

  ResponseStatus get responseStatus => _responseStatus;

  ResponseStatus get _responseStatus {
    if (errorCode == null) {
      return ResponseStatus.loading;
    } else if (errorCode == 0) {
      if (data is List) {
        var listData = data as List;
        if (listData.isNotEmpty) {
          return ResponseStatus.successHasContent;
        } else {
          return ResponseStatus.successNoData;
        }
      } else if (data is PageEntity ) {
        var pageEntity = data as PageEntity;
        var dataSource = pageEntity.dataSource as List;
        if (dataSource.isNotEmpty) {
          return ResponseStatus.successHasContent;
        } else {
          return ResponseStatus.successNoData;
        }
      } else {
        if (data != null) {
          return ResponseStatus.successHasContent;
        } else {
          return ResponseStatus.successNoData;
        }
      }
    } else {
      return ResponseStatus.fail;
    }
  }
}
