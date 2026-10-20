import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/pages/my/controller/login_controller.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/pages/my/view/my_page.dart';

class _Repository extends MyRepository {
  Completer<BaseEntity<CoinRankDatas>>? _result;
  Completer<BaseEntity<CoinRankDatas>> get result =>
      _result ??= Completer<BaseEntity<CoinRankDatas>>();

  @override
  Future<BaseEntity<CoinRankDatas>> getUserCoinInfo() => result.future;
}

void main() {
  late AccountService account;
  late _Repository repository;
  late MyController controller;

  setUp(() {
    Get.testMode = true;
    account = Get.put<AccountService>(AccountService()
      ..isLogin = true
      ..info = AccountInfoEntity());
    repository = Get.put<MyRepository>(_Repository()) as _Repository;
    controller = Get.put(MyController());
    // 模拟登录已同步，避免同值首次通知触发外层重建而掩盖问题。
    controller.syncAccount();
  });
  tearDown(Get.reset);

  Future<void> showPage(WidgetTester tester) async {
    await tester.pumpWidget(const GetCupertinoApp(home: MyPage()));
    await tester.pumpAndSettle();
  }

  void completeCoin() {
    repository.result.complete(BaseEntity(
      0,
      '',
      CoinRankDatas()
        ..level = 3
        ..rank = 12
        ..coinCount = 100,
    ));
  }

  testWidgets('登录状态不变时延迟积分响应刷新页面文本', (tester) async {
    await showPage(tester);
    expect(find.text('等级 --  排名 --  积分 --'), findsOneWidget);
    final pending = controller.getUserCoinInfo();
    completeCoin();
    await pending;
    await tester.pump();
    expect(find.text('等级 3  排名 12  积分 100'), findsOneWidget);
    expect(controller.isLogin.value, isTrue);
  });

  testWidgets('积分在页面展示之前返回时显示已有数据', (tester) async {
    final pending = controller.getUserCoinInfo();
    completeCoin();
    await pending;
    await showPage(tester);
    expect(find.text('等级 3  排名 12  积分 100'), findsOneWidget);
  });

  testWidgets('登录控制器关闭后积分响应仍刷新我的页', (tester) async {
    await showPage(tester);
    final login = Get.put(LoginController());
    final pending = login.getUserCoinInfo();
    await Get.delete<LoginController>();
    completeCoin();
    await pending;
    await tester.pump();
    expect(find.text('等级 3  排名 12  积分 100'), findsOneWidget);
  });

  testWidgets('积分失败保留已有文本及登录状态', (tester) async {
    account.userInfo = '等级 2  排名 20  积分 80';
    controller.syncAccount();
    await showPage(tester);
    final pending = controller.getUserCoinInfo();
    repository.result.completeError(Exception('积分请求失败'));
    await pending;
    await tester.pump();
    expect(find.text('等级 2  排名 20  积分 80'), findsOneWidget);
    expect(controller.isLogin.value, isTrue);
  });

  for (final logout in [false, true]) {
    testWidgets('${logout ? "退出" : "切换账户"}后旧积分响应不能更新页面', (tester) async {
      await showPage(tester);
      final pending = controller.getUserCoinInfo();
      // 在内存中模拟会话变更，避免测试依赖平台存储。
      account.sessionRevision++;
      account.isLogin = !logout;
      account.info = logout ? null : AccountInfoEntity();
      controller.syncAccount();
      completeCoin();
      await pending;
      await tester.pump();
      expect(find.text('等级 --  排名 --  积分 --'), findsOneWidget);
      expect(find.text('等级 3  排名 12  积分 100'), findsNothing);
    });
  }
}
