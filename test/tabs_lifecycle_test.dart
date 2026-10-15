import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';
import 'package:getx_study/pages/tree/view/tab_list_page.dart';
import 'package:getx_study/pages/tree/view/tabs_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

List<TabEntity> _tabs(List<int> ids) => ids
    .map((id) => TabEntity()
      ..id = id
      ..name = '分类$id')
    .toList();

class _TabsRepository extends TabsRepository {
  _TabsRepository(super.type);
  final pending = Completer<BaseEntity<List<TabEntity>>>();
  @override
  Future<BaseEntity<List<TabEntity>>> getTab() => pending.future;
}

class _ListRepository extends TabListRepository {
  final calls = <(TagType, String, int)>[];
  Completer<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>? deferred;
  @override
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getList({
    required int page,
    required String id,
    required TagType tagType,
  }) async {
    calls.add((tagType, id, page));
    if (deferred != null) return deferred!.future;
    return BaseEntity(
        0,
        '',
        PageEntity<List<ArticleInfoDatas>>.fromJson({})
          ..curPage = page
          ..pageCount = 5
          ..dataSource = List.generate(
              30,
              (index) => ArticleInfoDatas()
                ..id = index
                ..title = '$id-文章$index'
                ..envelopePic = ''));
  }
}

void main() {
  late _ListRepository repository;
  late ThemeService theme;

  setUp(() {
    Get.testMode = true;
    repository = _ListRepository();
    Get.put<TabListRepository>(repository);
    theme = Get.put(ThemeService());
  });
  tearDown(() => Get.reset());

  TabsController register(TagType type, List<int>? ids) {
    final repo = _TabsRepository(type);
    Get.put<TabsRepository>(repo, tag: type.toString());
    final controller = Get.put(TabsController(type), tag: type.toString());
    if (ids != null) repo.pending.complete(BaseEntity(0, '', _tabs(ids)));
    return controller;
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('首次加载在列表可用区域居中且只显示一个加载动画', (tester) async {
    repository.deferred =
        Completer<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>();
    register(TagType.publicNumber, [1]);
    await tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        bottomNavigationBar: SizedBox(height: 70),
        body: TabsPage(type: TagType.publicNumber),
      ),
    ));
    await settle(tester);
    final page = find.byType(TabListPage).first;
    final viewport =
        find.descendant(of: page, matching: find.byType(SmartRefresher));
    final label = find.descendant(of: page, matching: find.text('正在加载...'));
    final spinner = find.descendant(
        of: page, matching: find.byType(CupertinoActivityIndicator));
    expect(label, findsOneWidget);
    expect(spinner, findsOneWidget);
    final indicatorBounds =
        tester.getRect(spinner).expandToInclude(tester.getRect(label));
    expect(
        indicatorBounds.center.dx, closeTo(tester.getCenter(viewport).dx, 1));
    expect(
        indicatorBounds.center.dy, closeTo(tester.getCenter(viewport).dy, 1));
    expect(repository.calls.length, 1);
    await close(tester);
  });

  testWidgets('父组件重建和主题变化复用 TabController、分页数据和滚动位置', (tester) async {
    final parent = register(TagType.project, [1, 2]);
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    await tester.pumpWidget(GetMaterialApp(
        home: ValueListenableBuilder<int>(
      valueListenable: rebuild,
      builder: (context, value, child) => TabsPage(type: parent.type),
    )));
    await settle(tester);
    final tab = tester.widget<TabBar>(find.byType(TabBar)).controller!;
    final list = Get.find<TabListController>(tag: 'project:1');
    await list.onLoadMore();
    await settle(tester);
    final data = List.of(list.dataSource);
    final listFinder = find
        .descendant(
            of: find.byType(TabListPage).first,
            matching: find.byType(SmartRefresher))
        .first;
    await tester.drag(listFinder, const Offset(0, -300));
    await settle(tester);
    final offset = list.refreshController.position!.pixels;
    expect(offset, greaterThan(0));
    final calls = repository.calls.length;
    theme.rxCurrentThemeType.value = ThemeType.dark;
    Get.changeTheme(ThemeData.dark());
    rebuild.value++;
    await settle(tester);
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller, same(tab));
    expect(Get.find<TabListController>(tag: 'project:1'), same(list));
    expect(list.dataSource, orderedEquals(data));
    expect(list.page, 2);
    expect(list.refreshController.position!.pixels, offset);
    expect(repository.calls.length, calls);
    await close(tester);
    expect(list.isClosed, isTrue);
    expect(list.refreshController.headerMode, isNull);
    expect(Get.isRegistered<TabListController>(tag: 'project:1'), isFalse);
  });

  testWidgets('分类增删重排按 ID 保留选中项和实例，删除当前分类选第一项', (tester) async {
    final parent = register(TagType.project, [1, 2]);
    await tester.pumpWidget(
        const GetMaterialApp(home: TabsPage(type: TagType.project)));
    await settle(tester);
    var tab = tester.widget<TabBar>(find.byType(TabBar)).controller!;
    tab.animateTo(1);
    await settle(tester);
    final list = Get.find<TabListController>(tag: 'project:2');
    final oldTab = tab;
    parent.data = _tabs([2, 1, 3]);
    parent.update();
    await settle(tester);
    tab = tester.widget<TabBar>(find.byType(TabBar)).controller!;
    expect(tab, isNot(same(oldTab)));
    expect(oldTab.animation, isNull);
    expect(tab.index, 0);
    expect(Get.find<TabListController>(tag: 'project:2'), same(list));
    expect(repository.calls.where((call) => call.$2 == '2'), hasLength(1));
    parent.data = _tabs([1, 3]);
    parent.update();
    await settle(tester);
    expect(list.isClosed, isTrue);
    expect(list.refreshController.headerMode, isNull);
    expect(Get.isRegistered<TabListController>(tag: 'project:2'), isFalse);
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 0);
    parent.data = [];
    parent.status = ResponseStatus.successNoData;
    parent.update();
    await settle(tester);
    expect(find.byType(TabBar), findsNothing);
    expect(Get.isRegistered<TabListController>(tag: 'project:1'), isFalse);
    await close(tester);
  });

  testWidgets('不同分类类型的同一个 ID 使用不同依赖和请求参数', (tester) async {
    register(TagType.project, [1]);
    register(TagType.publicNumber, [1]);
    await tester.pumpWidget(const GetMaterialApp(
        home: Row(children: [
      Expanded(child: TabsPage(type: TagType.project)),
      Expanded(child: TabsPage(type: TagType.publicNumber)),
    ])));
    await settle(tester);
    final project = Get.find<TabListController>(tag: 'project:1');
    final publicNumber = Get.find<TabListController>(tag: 'publicNumber:1');
    expect(project, isNot(same(publicNumber)));
    expect(
        project.refreshController, isNot(same(publicNumber.refreshController)));
    expect(
        repository.calls,
        containsAll(
            [(TagType.project, '1', 1), (TagType.publicNumber, '1', 1)]));
    await close(tester);
  });

  testWidgets('加载前退出和首次失败退出均不访问未初始化 TabController', (tester) async {
    final parent = register(TagType.project, null);
    await tester.pumpWidget(
        const GetMaterialApp(home: TabsPage(type: TagType.project)));
    await tester.pump();
    expect(find.byType(TabBar), findsNothing);
    parent.status = ResponseStatus.fail;
    parent.update();
    await tester.pump();
    await close(tester);
    expect(repository.calls, isEmpty);
    final repo =
        Get.isRegistered<TabsRepository>(tag: TagType.project.toString())
            ? Get.find<TabsRepository>(tag: TagType.project.toString())
                as _TabsRepository
            : null;
    repo?.pending.complete(BaseEntity(0, '', _tabs([1])));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('分类请求尚未返回时移除分类，释放资源并忽略旧响应', (tester) async {
    repository.deferred =
        Completer<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>();
    final parent = register(TagType.project, [1]);
    await tester.pumpWidget(
        const GetMaterialApp(home: TabsPage(type: TagType.project)));
    await settle(tester);
    final list = Get.find<TabListController>(tag: 'project:1');
    expect(list.isLoading, isTrue);
    parent.data = [];
    parent.status = ResponseStatus.successNoData;
    parent.update();
    await settle(tester);
    expect(list.isClosed, isTrue);
    expect(list.refreshController.headerMode, isNull);
    repository.deferred!.complete(BaseEntity(
        0,
        '',
        PageEntity<List<ArticleInfoDatas>>.fromJson({})
          ..dataSource = [ArticleInfoDatas()]));
    await settle(tester);
    expect(list.dataSource, isEmpty);
    await close(tester);
  });

  testWidgets('页面移除时不删除外部注册的列表依赖', (tester) async {
    register(TagType.project, [1]);
    final external = Get.put(
        TabListController()
          ..tagType = TagType.project
          ..id = '1'
          ..initPage = 1
          ..page = 1
          ..refreshController = RefreshController(),
        tag: 'project:1');
    await tester.pumpWidget(
        const GetMaterialApp(home: TabsPage(type: TagType.project)));
    await settle(tester);
    await close(tester);
    expect(Get.find<TabListController>(tag: 'project:1'), same(external));
    expect(external.isClosed, isFalse);
    expect(external.refreshController.headerMode, isNotNull);
  });
}
