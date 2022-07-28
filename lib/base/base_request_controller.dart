import 'package:get/get.dart';
import 'package:getx_study/base/inferface.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/entity/base_entity.dart';


abstract class BaseRequestController<R extends IRepository, T> extends GetxController {
  late R request;

  BaseEntity<T>? response;

  ResponseStatus status = ResponseStatus.loading;

  T? data;

  @override
  void onInit() async {
    super.onInit();
    print("${this.runtimeType.toString()}创建了");

    request = Get.find<R>();
  }

  @override
  void onClose() {
    print("${this.runtimeType.toString()}被销毁了");
    super.onClose();
  }

  Future<void> aRequest({Map<String, dynamic>? parameters,}) async {}
}
