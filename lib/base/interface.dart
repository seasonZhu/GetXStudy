import 'package:get/get.dart';

typedef GetPage<T> = GetView<T>;

abstract class IRepository {
  /// 重试机制
  void retry() {}
}

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

class Box<T extends Object> {
  T value;

  Box(this.value);
}

extension Extension<T extends Object> on T {
  Box<T> get box => Box<T>(this);
}

String typeName(Type type) => type.toString();
