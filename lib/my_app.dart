import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:getx_study/base/getx_router_observer.dart';
import 'package:getx_study/extension/theme_data_extension.dart';
import 'package:getx_study/logger/logger.dart';
import 'routes/routes.dart';

class MyApp extends StatelessWidget {
  final bool isFirst;

  const MyApp({Key? key, required this.isFirst}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'GetX Study',
      navigatorObservers: [GetXRouterObserver()],
      unknownRoute: Routes.unknownPage,

      /// 通过使用initialRoute来保证绑定的操作
      initialRoute: isFirst ? Routes.welcome : Routes.splash,
      getPages: Routes.routePage,
      onGenerateRoute: (settings) {
        logger.d(settings.name);
        return null;
      },
      /// 使用toast
      builder: EasyLoading.init(),
      theme: _getCupertinoCurrentTheme(),
    );
  }

  /// App运行过程中,如果在iOS的设置中更改了亮度模式,还是无法实时进行更改,只能下次运行的时候才能体现变化,体验不好
  ThemeData _getMaterialCurrentTheme() {
    return SchedulerBinding.instance.window.platformBrightness.themeData;
  }

  CupertinoThemeData _getCupertinoCurrentTheme() {
    return const CupertinoThemeData(
        primaryColor: Colors.blue,
        barBackgroundColor: Colors.white,
        brightness: Brightness.light);
  }

  /// 悼念模式
  void _changeColorModel({required Color color,  required Widget widget }) {
    ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.color),
      child: widget
    );
  }
}
