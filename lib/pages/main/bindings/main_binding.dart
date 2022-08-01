import 'package:get/get.dart';

import 'package:getx_study/pages/main/controller/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MainController(),
    );
  }
}