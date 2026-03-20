import 'package:get/get.dart';

import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';

class TreeListBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(
      () => TabListRepository(),
      fenix: true
    );
  }
}