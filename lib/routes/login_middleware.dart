import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/routes/routes.dart';

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AccountManager().isLogin ? null : const RouteSettings(name: Routes.login);
  }
}
