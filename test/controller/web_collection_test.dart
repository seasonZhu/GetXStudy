import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/collection_service.dart';
import 'package:getx_study/app_service/orientation_service.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';
import 'package:getx_study/pages/my/repository/my_collect_repository.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:getx_study/pages/web/view/web_collection_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/collection_fakes.dart';

void main() {
  late AccountService account;
  late CollectionService collections;
  late FakeCollectionRepository repository;
  late WebController web;
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    account = Get.put(AccountService())
      ..isLogin = true
      ..info = (AccountInfoEntity()..collectIds = [1]);
    repository = FakeCollectionRepository();
    collections = Get.put(CollectionService(account, repository));
    Get.put(OrientationService());
    // 收藏行为无需创建原生 WebView。
    web = WebController(webLoadInfo: ArticleInfoDatas()..originId = 1);
  });

  tearDown(() {
    if (!web.isClosed) web.onDelete();
    collections.onDelete();
    account.onDelete();
    Get.find<OrientationService>().onDelete();
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> showButton(WidgetTester tester) => tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: WebCollectionButton(
              controller: web,
              webLoadInfo: ArticleInfoDatas()..originId = 1,
            ),
          ),
        ),
      );

  testWidgets('Web 与列表共用请求锁和状态，按钮禁用且列表立即删除', (tester) async {
    Get.put<MyCollectRepository>(MyCollectRepository());
    Get.put<int>(0, tag: className(MyCollectController));
    Get.put(RefreshController(), tag: className(MyCollectController));
    final list = Get.put(MyCollectController())
      ..dataSource = [ArticleInfoDatas()..originId = 1];
    await showButton(tester);
    expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    await list.unCollectAction(originId: 1);
    expect(repository.calls, hasLength(1));
    repository.calls.single.succeed();
    await tester.pump();
    expect(list.dataSource, isEmpty);
    expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNotNull);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    list.onDelete();
  });

  testWidgets('失败保留收藏图标，外部成功操作同步按钮', (tester) async {
    await showButton(tester);
    await tester.tap(find.byType(IconButton));
    repository.calls.last.result.complete(BaseEntity(-1, '取消失败', null));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byIcon(CupertinoIcons.heart_fill), findsOneWidget);
    final outside = collections.setCollected(1, false);
    repository.calls.last.succeed();
    await outside;
    await tester.pump();
    expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);
  });

  testWidgets('Web 关闭后成功仍更新存活列表，不显示页面提示', (tester) async {
    Get.put<MyCollectRepository>(MyCollectRepository());
    Get.put<int>(0, tag: className(MyCollectController));
    Get.put(RefreshController(), tag: className(MyCollectController));
    final list = Get.put(MyCollectController())
      ..dataSource = [ArticleInfoDatas()..originId = 1];
    await showButton(tester);
    final pending = web.collectOrUnCollectAction(
        webLoadInfo: ArticleInfoDatas()..originId = 1);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    web.onDelete();
    repository.calls.last.succeed();
    await pending;
    await tester.pumpAndSettle();
    expect(collections.isCollected(1), isFalse);
    expect(list.dataSource, isEmpty);
    expect(Get.isSnackbarOpen, isFalse);
    list.onDelete();
    expect(tester.takeException(), isNull);
  });

  testWidgets('退出登录隐藏按钮，旧成功不弹提示也不恢复收藏', (tester) async {
    await showButton(tester);
    final pending = web.collectOrUnCollectAction(
        webLoadInfo: ArticleInfoDatas()..originId = 1);
    await tester.runAsync(() => account.clear());
    await tester.pump();
    expect(find.byType(IconButton), findsNothing);
    repository.calls.last.succeed();
    await pending;
    await tester.pumpAndSettle();
    expect(account.info, isNull);
    expect(Get.isSnackbarOpen, isFalse);
  });
}
