import 'package:get/get.dart';

import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:getx_study/pages/web/repository/web_repository.dart';

class WebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => WebRepository(),
    );
    Get.lazyPut(
      () => WebController(),
    );
  }
}