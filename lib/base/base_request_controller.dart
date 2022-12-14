import 'package:get/get.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/base_entity.dart';

abstract class BaseRequestController<R extends IRepository, T>
    extends GetxController implements IRetry {
  late R request;

  BaseEntity<T>? response;

  ResponseStatus status = ResponseStatus.loading;

  T? data;

  @override
  void onInit() async {
    super.onInit();
    request = Get.find<R>();
  }

  Future<void> aRequest({
    Map<String, dynamic>? parameters,
  }) async {}

  @override
  void retry() {
    aRequest();
  }
}
