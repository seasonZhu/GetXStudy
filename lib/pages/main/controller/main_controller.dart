import 'package:get/get.dart';
import 'package:getx_study/enum/main_tag_type.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var selectedIndex = 0;

  void onItemTapped(int index) {
    final treeTag = TagType.tree.toString();
    if (index == MainTagType.tree.index &&
        Get.isRegistered<TabsController>(tag: treeTag)) {
      Get.find<TabsController>(tag: treeTag).applyLayoutPreference();
    }
    selectedIndex = index;
    update();

    //getFindTest();
  }

  void getFindTest() {
    /// Get.putAsyn使用的时候要稍微注意,避免先find后put
    final prefs = Get.find<SharedPreferences>();
    int? count = prefs.getInt('counter');
    logger.d(count);
  }
}
