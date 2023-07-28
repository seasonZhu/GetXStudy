import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'package:getx_study/pages/tree/repository/tree_repository.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';

class TreeBinding extends Bindings {

  TreeBinding(this.type);

  TagType type;

  @override
  void dependencies() {
    Get.lazyPut(
      () => TabsRepository(type),
      tag: type.toString()
    );
    Get.lazyPut(
      () => TreeController(type),
    );
  }
}