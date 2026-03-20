import 'package:get/get.dart';

import 'package:getx_study/base/class_name.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:getx_study/enum/tag_type.dart';

import 'package:getx_study/pages/tree/controller/tree_list_controller.dart';
import 'package:getx_study/pages/tree/repository/tree_list_repository.dart';

class TreeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TreeListRepository(),
    );
    Get.lazyPut(
      tag: className(TreeListController),
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(
      tag: className(TreeListController),
      () => TagType.tree.pageNum,
    );
    Get.lazyPut(
      () => TreeListController(),
    );
  }
}
