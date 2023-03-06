import 'package:get/get.dart';

abstract class IRepository {}

abstract class IRetry {
  /// 重试机制,这里写不写方法的实现好像并不影响代码编译与逻辑
  void retry();
}

abstract class IClassName {
  static String? className;

  /// 协议的类方法必须要进行实现,否则就会报错
  // static String? Some();

  // String some();
}

abstract class IWebLoadInfo {
  int? id;
  int? originId;
  String? title;
  String? link;
}

/// 以下代码没有使用,是思考

abstract class IRequestController extends GetxController {}

/// 危险,不要定义这个类
/// typedef GetPage<T> = GetView<T>;

String typeName(Type type) => (type).toString();

class Box<T extends Object> {
  T value;

  Box(this.value);
}

extension Extension<T extends Object> on T {
  Box<T> get box => Box<T>(this);
}
