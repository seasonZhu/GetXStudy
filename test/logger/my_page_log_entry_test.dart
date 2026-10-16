import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/pages/my/view/my_page.dart';

void main() {
  tearDown(Get.reset);

  for (final loggedIn in [false, true]) {
    testWidgets('${loggedIn ? "登录用户" : "游客"}可从我的页面打开调试日志', (tester) async {
      Get.testMode = true;
      Get.put<AccountService>(AccountService()..isLogin = loggedIn);
      Get.put<MyRepository>(MyRepository());
      Get.put(MyController());
      await tester.pumpWidget(const GetCupertinoApp(
        home: Material(child: MyPage()),
      ));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('调试日志'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('调试日志'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('调试日志'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('分享当前筛选日志'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
