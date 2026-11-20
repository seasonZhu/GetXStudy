import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/tree_layout_service.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/enum/main_tag_type.dart';
import 'package:getx_study/pages/main/controller/main_controller.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';
import 'package:getx_study/pages/tree/view/tree_page.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repository extends TabsRepository {
  _Repository() : super(TagType.tree);

  final topic = TabEntity()..name = '子分类';
  int calls = 0;

  @override
  Future<BaseEntity<List<TabEntity>>> getTab() async {
    calls++;
    return BaseEntity(0, '', [
      TabEntity()
        ..name = '分类'
        ..children = [topic],
      for (var index = 0; index < 30; index++)
        TabEntity()
          ..name = '分类 $index'
          ..children = [TabEntity()..name = '子分类 $index'],
    ]);
  }
}

class _FailingPreferences implements SharedPreferences {
  int writes = 0;
  final result = Completer<bool>();

  @override
  Object? get(String key) => null;

  @override
  Future<bool> setString(String key, String value) async {
    writes++;
    return result.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

GetPage<dynamic> get _settingRoute => Routes.routePage
    .singleWhere((page) => page.name == Routes.treeLayoutSetting);

void main() {
  testWidgets('重复选择不写入，保存失败保留原勾选并显示提示', (tester) async {
    final preferences = _FailingPreferences();
    final service = Get.put(TreeLayoutService(preferences));
    addTearDown(() => Get.reset());
    await tester.pumpWidget(
      GetCupertinoApp(home: const SizedBox(), getPages: [_settingRoute]),
    );
    Get.toNamed<void>(Routes.treeLayoutSetting);
    await tester.pumpAndSettle();
    await tester.tap(find.text('换行布局'));
    expect(preferences.writes, 0);
    await tester.tap(find.text('列表布局'));
    await tester.pump();
    expect(
      tester.widgetList<CupertinoListTile>(find.byType(CupertinoListTile)),
      everyElement(isA<CupertinoListTile>()
          .having((tile) => tile.onTap, 'onTap', isNull)),
    );
    preferences.result.complete(false);
    await tester.pumpAndSettle();
    expect(preferences.writes, 1);
    expect(service.selected, TreeLayout.wrap);
    expect(find.text('保存失败，请重试'), findsOneWidget);
  });

  testWidgets('体系使用非收缩列表，保留滚动监听和子项跳转', (tester) async {
    SharedPreferences.setMockInitialValues({
      TreeLayoutService.preferenceKey: 'invalid',
    });
    final preferences = await SharedPreferences.getInstance();
    final service = Get.put(TreeLayoutService(preferences));
    expect(service.selected, TreeLayout.wrap);
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Get.testMode = true;
    addTearDown(() => Get.reset());
    final repository = _Repository();
    final tag = TagType.tree.toString();
    Get.put<TabsRepository>(repository, tag: tag);
    final controller = Get.put(TabsController(TagType.tree), tag: tag);
    TabEntity? selected;
    final brightness = ValueNotifier(Brightness.light);
    addTearDown(brightness.dispose);
    final app = GetCupertinoApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2),
        ),
        child: child!,
      ),
      home: ValueListenableBuilder<Brightness>(
        valueListenable: brightness,
        builder: (context, value, child) => CupertinoTheme(
          data: CupertinoThemeData(brightness: value),
          child: child!,
        ),
        child: const TreePage(),
      ),
      getPages: [
        _settingRoute,
        GetPage(
          name: Routes.treeList,
          page: () {
            selected = Get.arguments as TabEntity;
            return const CupertinoPageScaffold(child: SizedBox());
          },
        ),
      ],
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.shrinkWrap, isFalse);
    expect(list.controller, same(controller.scroll));
    expect(repository.calls, 1);
    final main = MainController();
    controller.scroll.jumpTo(120);
    await tester.pump();
    main.onItemTapped(MainTagType.tree.index);
    expect(controller.scroll.offset, 120);

    Get.toNamed<void>(Routes.treeLayoutSetting);
    await tester.pumpAndSettle();
    await tester.tap(find.text('列表布局'));
    await tester.pumpAndSettle();
    expect(service.selected, TreeLayout.list);
    expect(TreeLayoutService(preferences).selected, TreeLayout.list);
    expect(controller.layout, TreeLayout.wrap);
    Get.back<void>();
    await tester.pumpAndSettle();
    main.onItemTapped(MainTagType.tree.index);
    await tester.pumpAndSettle();
    expect(controller.layout, TreeLayout.list);
    expect(controller.scroll.offset, 0);
    expect(find.byType(CupertinoListTile), findsWidgets);
    expect(repository.calls, 1);
    final sectionScroll = find.byType(CustomScrollView);
    final firstHeader = find.widgetWithText(PinnedHeaderSliver, '分类');
    final headerBackground = find.descendant(
      of: firstHeader,
      matching: find.byType(ColoredBox),
    );
    Color headerColor() => tester.widget<ColoredBox>(headerBackground).color;
    expect(headerColor(), const Color(0xFFF0F0F2));
    brightness.value = Brightness.dark;
    await tester.pumpAndSettle();
    expect(headerColor(), const Color(0xFF2C2C2E));
    final nextHeader = find.descendant(
      of: find.widgetWithText(PinnedHeaderSliver, '分类 0'),
      matching: find.byType(ColoredBox),
    );
    final viewportTop = tester.getTopLeft(sectionScroll).dy;
    expect(
        viewportTop,
        greaterThanOrEqualTo(
            tester.getBottomLeft(find.byType(CupertinoNavigationBar)).dy));
    final firstTitle = find.text('分类');
    final pinnedTitleTop = tester.getTopLeft(firstTitle).dy;
    final nextSectionStart = tester.getTopLeft(nextHeader).dy - viewportTop;
    final firstHeaderHeight = tester
        .getSize(find.descendant(
          of: firstHeader,
          matching: find.byType(ColoredBox),
        ))
        .height;
    controller.scroll.jumpTo(10);
    await tester.pump();
    expect(tester.getTopLeft(firstTitle).dy, closeTo(pinnedTitleTop, 0.01));
    controller.scroll.jumpTo(nextSectionStart - firstHeaderHeight / 2);
    await tester.pump();
    expect(tester.getTopLeft(firstTitle).dy,
        closeTo(pinnedTitleTop - firstHeaderHeight / 2, 0.01));
    controller.scroll.jumpTo(nextSectionStart + 10);
    await tester.pump();
    expect(tester.getTopLeft(nextHeader).dy, closeTo(viewportTop, 0.01));
    controller.scroll.jumpTo(10);
    await tester.pump();
    expect(tester.getTopLeft(firstTitle).dy, closeTo(pinnedTitleTop, 0.01));
    controller.scroll.jumpTo(120);
    await tester.pump();
    main.onItemTapped(MainTagType.tree.index);
    expect(controller.scroll.offset, 120);
    controller.scroll.jumpTo(0);
    await tester.pump();
    await tester.tap(find.text('子分类'));
    await tester.pumpAndSettle();
    expect(selected, same(repository.topic));
    expect(tester.takeException(), isNull);
  });
}
