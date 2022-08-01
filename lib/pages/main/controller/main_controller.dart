import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 0;

  void onItemTapped(int index) {
    selectedIndex = index;
    update();
  }
}
