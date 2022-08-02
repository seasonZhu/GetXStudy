import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/project_public_number/controller/project_controller.dart';
import 'package:getx_study/pages/project_public_number/repository/project_repository.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';

class ProjectBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(
      () => ProjectRepository(TagType.project),
    );
    Get.lazyPut(
      () => ProjectController(TagType.project),
    );
    Get.lazyPut(
      () => TabListRepository(),
    );
  }
}