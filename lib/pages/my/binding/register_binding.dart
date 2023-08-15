import 'package:get/get.dart';

import 'package:getx_study/pages/my/controller/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => RegisterController(),
    );
  }
}