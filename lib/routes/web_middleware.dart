import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class WebMiddleware extends GetMiddleware {
  @override
  void onPageDispose() {
    super.onPageDispose();
    EasyLoading.dismiss(animation: false);
  }
}
