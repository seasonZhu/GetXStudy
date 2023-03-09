import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:getx_study/account_manager/account_manager.dart';
import 'package:getx_study/my_app.dart';

void main() => run();

run() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final isFirst = await AccountManager().getIsFirstLaunch();
  runApp(MyApp(isFirst: isFirst));
}
