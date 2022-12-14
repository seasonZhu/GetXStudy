import 'package:get/get.dart';

typedef GetPage<T> = GetView<T>;

abstract class IRepository {}

abstract class IRetry {
  /// 重试机制
  void retry() {}
}

abstract class IClassName {
  static String? className;

  /// 协议的类方法只能返回可选类型,
  // static String? Some();

  // String some();
}

abstract class IRequestController extends GetxController {}

abstract class IWebLoadInfo {
  int? id;
  int? originId;
  String? title;
  String? link;
}

String typeName(Type type) => type.toString();

class Box<T extends Object> {
  T value;

  Box(this.value);
}

extension Extension<T extends Object> on T {
  Box<T> get box => Box<T>(this);
}
