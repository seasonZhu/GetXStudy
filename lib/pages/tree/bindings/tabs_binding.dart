import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';
import 'package:getx_study/pages/tree/repository/tree_repository.dart';

class TabsBinding extends Bindings {
  TabsBinding(this.type);

  TagType type;

  @override
  void dependencies() {
    Get.lazyPut(
      () => TreeRepository(type),
    );
    Get.lazyPut(
      () => TreeController(type),
    );
    Get.lazyPut(
      () => TabListRepository(),
    );
  }
}
