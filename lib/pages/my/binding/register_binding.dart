import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:get/get.dart';

import 'package:getx_study/pages/my/controller/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyRepository>()) {
      Get.lazyPut<MyRepository>(() => MyRepository(), fenix: true);
    }
    Get.lazyPut(() => RegisterController());
  }
}
