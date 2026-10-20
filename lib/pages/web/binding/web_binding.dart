import 'package:get/get.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';

class WebBinding extends Bindings {
  @override
  void dependencies() {
    final webLoadInfo = Get.arguments as IWebLoadInfo;
    final hideCollection = Get.parameters['notShowCollectIcon'] == 'true';
    Get.lazyPut(() => WebController(
          webLoadInfo: webLoadInfo,
          hideCollection: hideCollection,
        ));
  }
}
