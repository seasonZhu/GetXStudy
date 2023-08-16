import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/routes/routes.dart';

abstract class BaseController extends GetxController
    implements IRetry, IEmptyTap {
  ResponseStatus status = ResponseStatus.loading;
}

/// 要不要with是个问题
mixin ResponseStatusMixin on GetxController {
  ResponseStatus status = ResponseStatus.loading;
}

/// 目前这个玩安卓版本的设计是如果用户是游客,就直接屏蔽功能
/// 这里考虑的是如果所有功能都是开放的,那么点击事件最后都会传到Controller层,那么控制器层就需要用一个方法做统一拦截
/// 这里考虑用的mixin的方式,这样的好处的是,有些页面根本就不需要检查是否登录,也就减少了继承的成本
/// 但是用mixin的问题是,很多页面又都需要写with
/// 先with然后再extends?
mixin CheckIsLoginMixin on BaseController {
  bool checkIsLogin() {
    if (!AccountManager().isLogin) {
      Get.toNamed(Routes.login);
    }

    return AccountManager().isLogin;
  }
}
