import 'package:get/get.dart';
import 'package:getx_study/account_manager/account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountController());
  }
}
