import 'package:get/get.dart';
import 'package:getx_study/pages/my/controller/tree_layout_setting_controller.dart';

class TreeLayoutSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TreeLayoutSettingController(Get.find()));
  }
}
