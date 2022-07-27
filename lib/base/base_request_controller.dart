import 'package:get/get.dart';
import 'package:getx_study/base/inferface.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/base_entity.dart';


abstract class BaseRequestController<R extends IRepository, T> extends GetxController {
  late R request;

  BaseEntity<T>? response;

  ResponseStatus status = ResponseStatus.loading;
}
