import 'package:get/get.dart';

import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'package:getx_study/pages/tree/repository/tree_repository.dart';

class TreeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TreeRepository(),
    );
    Get.lazyPut(
      () => TreeController(),
    );
  }
}