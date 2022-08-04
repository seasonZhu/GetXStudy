import 'package:get/get.dart';

abstract class IRepository {}

abstract class IClassName {
  static String? className;
}

abstract class IRequestController extends GetxController {}

abstract class IWebLoadInfo {
  int? id;
  int? originId;
  String? title;
  String? link;
}
