import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';

class PublicNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TabsRepository(TagType.publicNumber),
    );
    Get.lazyPut(
      () => TabsController(TagType.publicNumber),
    );
    Get.lazyPut(
      () => TabListRepository(),
    );
  }
}