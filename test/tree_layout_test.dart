import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';
import 'package:getx_study/pages/tree/view/tree_page.dart';
import 'package:getx_study/routes/routes.dart';

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
    ]);
  }
}

void main() {
  testWidgets('体系使用非收缩列表，保留滚动监听和子项跳转', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Get.testMode = true;
    addTearDown(() => Get.reset());
    final repository = _Repository();
    final tag = TagType.tree.toString();
    Get.put<TabsRepository>(repository, tag: tag);
    final controller = Get.put(TabsController(TagType.tree), tag: tag);
    TabEntity? selected;
    final app = GetCupertinoApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(2),
        ),
        child: child!,
      ),
      home: const TreePage(),
      getPages: [
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
    await tester.tap(find.text('子分类'));
    await tester.pumpAndSettle();
    expect(selected, same(repository.topic));
    expect(tester.takeException(), isNull);
  });
}
