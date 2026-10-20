import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/pages/main/controller/main_controller.dart';
import 'package:getx_study/pages/main/view/main_page.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AccountService());
    Get.put(ThemeService());
    Get.put(MyRepository());
    Get.put(MyController());
    Get.put(MainController()..selectedIndex = 4);
  });
  tearDown(Get.reset);

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final inset in [0.0, 24.0]) {
      testWidgets('$platform 底部安全区 $inset 时导航留白与内容边界正确', (tester) async {
        await tester.pumpWidget(GetMaterialApp(
          theme: ThemeData(platform: platform),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.only(bottom: inset),
              viewPadding: EdgeInsets.only(bottom: inset),
            ),
            child: child!,
          ),
          home: const MainPage(),
        ));
        await tester.pumpAndSettle();
        final extra = platform == TargetPlatform.android ? 8.0 : 0.0;
        final bar = tester.getRect(find.byType(CupertinoTabBar));
        expect(bar.height, closeTo(50 + inset + extra, 0.01));
        expect(
            bar.bottom,
            closeTo(
                tester.view.physicalSize.height / tester.view.devicePixelRatio,
                0.01));
        final page = tester.getRect(find.byType(CupertinoPageScaffold));
        expect(page.bottom, closeTo(bar.top, 0.01));
        final pageContext = tester.element(find.byType(CupertinoPageScaffold));
        expect(MediaQuery.viewPaddingOf(pageContext).bottom, 0);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
