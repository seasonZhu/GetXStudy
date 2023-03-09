import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:getx_study/account_manager/account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AccountController(),
    );
    //getPutAsyncTest();
  }

  void getPutAsyncTest() {
    /// 测试Get.putAsync
    Get.putAsync<SharedPreferences>(() async {
      final prefs = await SharedPreferences.getInstance();

      /// 测试塞入的数据
      await prefs.setInt('counter', 12345);
      return prefs;
    });
  }
}
