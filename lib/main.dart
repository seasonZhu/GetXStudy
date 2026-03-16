import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:getx_study/my_app.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/app_service/orientation_service.dart';
import 'package:getx_study/resource/app_resources.dart';

void main() => run();

run() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //cherrilog();

  /// 初始化资源文件（字符串、颜色、尺寸等）
  await AppResources.init();

  /// 把初始化服务放到runApp之前
  final accountService = Get.put(AccountService());

  final themeService = Get.put(ThemeService());

  /// 初始化屏幕方向服务
  final orientationService = Get.put(OrientationService());

  final isFirst = await accountService.getIsFirstLaunch();

  await themeService.getThemeType();

  /// 玩安卓App的进这个
  runApp(MyApp(isFirst: isFirst));

  /// 使用StreamController与StreamBuilder构建页面的进这个
  //runApp(StreamApp());

  /// 使用RxDart与StreamBuilder构建页面的进这个
  //runApp(RxDartApp());

  /// 使用GetX构建页面的进这个
  //runApp(GetXApp());

  /// Flutter与JS通信的进这个
  //runApp(H5JSChannelApp());

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    const systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}