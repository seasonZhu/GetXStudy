import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var selectedIndex = 0;

  void onItemTapped(int index) {
    selectedIndex = index;

    /// Get.putAsyn使用的时候要稍微注意,避免先find后put
    final prefs = Get.find<SharedPreferences>();
    int? count = prefs.getInt('counter');
    print(count);

    update();
  }
}
