import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/app_launcher_service.dart';
import 'package:getx_study/app_service/collection_service.dart';
import 'package:getx_study/app_service/orientation_service.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/pages/web/binding/web_binding.dart';
import 'package:getx_study/pages/web/controller/web_controller.dart';
import 'package:getx_study/pages/web/view/web_page.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../support/collection_fakes.dart';
import '../support/webview_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeWebViewPlatform platform;
  WebViewPlatform? previous;
  late AccountService account;
  late CollectionService collections;
  late FakeCollectionRepository repository;
  WebController? web;

  ArticleInfoDatas article() => ArticleInfoDatas()
    ..id = 1
    ..title = '测试网页'
    ..link = 'https://example.com/article';

  setUp(() {
    Get.testMode = true;
    previous = WebViewPlatform.instance;
    platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
    account = Get.put(AccountService())
      ..isLogin = true
      ..info = (AccountInfoEntity()..collectIds = [1]);
    repository = FakeCollectionRepository();
    collections = Get.put(CollectionService(account, repository));
    Get.put(ThemeService());
    Get.put(OrientationService());
    Get.put(AppLauncherService());
  });
  tearDown(() {
    if (web != null && !web!.isClosed) web!.onDelete();
    collections.onDelete();
    account.onDelete();
    Get.find<OrientationService>().onDelete();
    Get.reset();
    if (previous != null) WebViewPlatform.instance = previous;
    EasyLoading.dismiss();
    web = null;
  });

  Future<WebController> initialize() async {
    web = Get.put<WebController>(WebController(webLoadInfo: article()));
    await web!.initialization;
    return web!;
  }

  testWidgets('页面重建、主题和收藏变化复用同一 WebView，仅加载一次', (tester) async {
    final controller = await initialize();
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    await tester.pumpWidget(GetMaterialApp(
        home: ValueListenableBuilder<int>(
      valueListenable: rebuild,
      builder: (context, value, child) => WebPage(),
    )));
    await tester.pump();
    final instance = controller.webViewController;
    rebuild.value++;
    await tester.pump();
    Get.changeTheme(ThemeData.dark());
    final change = collections.setCollected(1, false);
    repository.calls.single.succeed();
    await change;
    await tester.pump();
    expect(controller.webViewController, same(instance));
    expect(platform.controllers, hasLength(1));
    expect(platform.controllers.single.loads, [Uri.parse(article().link!)]);
    expect(find.byKey(const ValueKey('测试网页')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('初始化中显示占位，关闭后停止配置和初始加载', (tester) async {
    platform.setupGate = Completer<void>();
    web = Get.put<WebController>(WebController(webLoadInfo: article()));
    await tester.pumpWidget(GetMaterialApp(home: WebPage()));
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    web!.onDelete();
    platform.setupGate!.complete();
    await web!.initialization;
    expect(platform.controllers.single.loads, isEmpty);
    expect(platform.controllers.single.backgrounds, 0);
    expect(
        web!.initializationStatus.value, WebInitializationStatus.initializing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('初始化异常显示中文错误和返回入口，重建不重试', (tester) async {
    platform.failSetup = true;
    final controller = await initialize();
    await tester.pumpWidget(GetMaterialApp(home: WebPage()));
    expect(
        controller.initializationStatus.value, WebInitializationStatus.failed);
    expect(find.text('网页初始化失败，请返回后重试'), findsOneWidget);
    expect(find.text('返回'), findsOneWidget);
    tester.element(find.byType(WebPage)).markNeedsBuild();
    await tester.pump();
    expect(platform.controllers, hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('历史查询乱序只提交最新结果，关闭后查询和回调均失效', () async {
    final controller = await initialize();
    final delegate = platform.delegate!;
    final native = platform.controllers.single;
    delegate.onFinished('a');
    delegate.onFinished('b');
    native.histories[1].complete(true);
    await Future<void>.delayed(Duration.zero);
    native.histories[0].complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(controller.canGoBack.value, isTrue);
    delegate.onFinished('c');
    controller.onDelete();
    native.histories[2].complete(false);
    await Future<void>.delayed(Duration.zero);
    delegate.onProgress(20);
    delegate.onStarted('d');
    delegate.onFinished('d');
    expect(controller.canGoBack.value, isTrue);
    expect(native.histories, hasLength(3));
    expect(
        await delegate.onNavigation(const NavigationRequest(
            url: 'https://example.com', isMainFrame: true)),
        NavigationDecision.prevent);
    expect(EasyLoading.isShow, isFalse);
  });

  testWidgets('网页后退互斥，关闭时取消延迟 dismiss，不影响后来提示', (tester) async {
    final controller = await initialize();
    await tester.pumpWidget(
        GetMaterialApp(home: const Scaffold(), builder: EasyLoading.init()));
    final native = platform.controllers.single;
    final first = controller.onBackAction();
    await controller.onBackAction();
    expect(native.histories, hasLength(1));
    native.histories.single.complete(true);
    await first;
    expect(native.backCalls, 1);
    controller.onDelete();
    await tester.pump();
    EasyLoading.show(status: '其他页面加载');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 2));
    expect(EasyLoading.isShow, isTrue);
    EasyLoading.dismiss(animation: false);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });

  test('关闭后不执行仍在等待历史查询的返回操作', () async {
    final controller = await initialize();
    final pending = controller.onBackAction();
    controller.onDelete();
    platform.controllers.single.histories.single.complete(true);
    await pending;
    expect(platform.controllers.single.backCalls, 0);
  });

  test('Binding 执行后全局参数变化不影响延迟创建的 Controller', () async {
    final original = article();
    Get.routing.args = original;
    Get.parameters['notShowCollectIcon'] = 'true';
    WebBinding().dependencies();
    Get.routing.args = article()..link = 'https://example.com/other';
    Get.parameters['notShowCollectIcon'] = 'false';
    web = Get.find<WebController>();
    await web!.initialization;
    expect(web!.webLoadInfo, same(original));
    expect(web!.hideCollection, isTrue);
    expect(platform.controllers.single.loads, [Uri.parse(original.link!)]);
  });

  testWidgets('WebBinding 捕获参数，退出重进创建新实例，无历史时只退出一次', (tester) async {
    final firstArticle = article();
    await tester.pumpWidget(GetMaterialApp(
      home: const Scaffold(body: Text('起点')),
      getPages: [
        GetPage(name: '/test-web', binding: WebBinding(), page: () => WebPage())
      ],
    ));
    unawaited(Get.toNamed('/test-web',
        arguments: firstArticle, parameters: {'notShowCollectIcon': 'true'}));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    web = Get.find<WebController>();
    await web!.initialization;
    expect(web!.webLoadInfo, same(firstArticle));
    expect(web!.hideCollection, isTrue);
    final firstWeb = web;
    final back = web!.onBackAction();
    await web!.onBackAction();
    platform.controllers.single.histories.single.complete(false);
    await back;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('起点'), findsOneWidget);
    expect(firstWeb!.isClosed, isTrue);
    unawaited(Get.toNamed('/test-web', arguments: article()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    web = Get.find<WebController>();
    await web!.initialization;
    expect(web, isNot(same(firstWeb)));
    expect(platform.controllers, hasLength(2));
    await tester.pumpWidget(const SizedBox());
  });
}
