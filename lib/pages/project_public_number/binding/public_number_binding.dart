import 'package:get/get.dart';

import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/project_public_number/controller/public_number_controller.dart';
import 'package:getx_study/pages/project_public_number/repository/public_number_repository.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';

class PublicNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PublicNumberRepository(TagType.publicNumber),
    );
    Get.lazyPut(
      () => PublicNumberController(TagType.publicNumber),
    );
    Get.lazyPut(
      () => TabListRepository(),
    );
  }
}