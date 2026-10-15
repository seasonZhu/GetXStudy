import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/hot_key_entity.dart';
import 'package:getx_study/entity/tab_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/home/controller/hot_key_controller.dart';
import 'package:getx_study/pages/home/repository/hot_key_repository.dart';
import 'package:getx_study/pages/tree/controller/tabs_controller.dart';
import 'package:getx_study/pages/tree/repository/tabs_repository.dart';

class _HotRepository extends HotKeyRepository {
  final pending = <Completer<BaseEntity<List<HotKeyEntity>>>>[];
  @override
  Future<BaseEntity<List<HotKeyEntity>>> getHotKey() {
    final result = Completer<BaseEntity<List<HotKeyEntity>>>();
    pending.add(result);
    return result.future;
  }
}

class _TabsRepository extends TabsRepository {
  _TabsRepository() : super(TagType.project);
  final pending = <Completer<BaseEntity<List<TabEntity>>>>[];
  @override
  Future<BaseEntity<List<TabEntity>>> getTab() {
    final result = Completer<BaseEntity<List<TabEntity>>>();
    pending.add(result);
    return result.future;
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() {
    EasyLoading.dismiss(animation: false);
    Get.reset();
  });

  for (final tabs in [false, true]) {
    final name = tabs ? '分类入口' : '热门搜索';
    testWidgets('$name 网络失败可重试，业务失败不进入成功分支，成功空数据展示空态', (tester) async {
      final hotRepository = _HotRepository();
      final tabsRepository = _TabsRepository();
      final dynamic controller = tabs
          ? (TabsController(TagType.project)..request = tabsRepository)
          : (HotKeyController()..request = hotRepository);
      final Future<void> first = controller.aRequest();
      (tabs ? tabsRepository.pending : hotRepository.pending)
          .last
          .completeError('断网');
      await first;
      expect(controller.status, ResponseStatus.fail);
      expect(controller.data, isNull);
      final Future<void> retry = controller.aRequest();
      expect(controller.status, ResponseStatus.loading);
      if (tabs) {
        tabsRepository.pending.last.complete(BaseEntity(-1, '业务失败', null));
      } else {
        hotRepository.pending.last.complete(BaseEntity(-1, '业务失败', null));
      }
      await retry;
      expect(controller.status, ResponseStatus.fail);
      expect(controller.response, isNull);
      final Future<void> empty = controller.aRequest();
      if (tabs) {
        tabsRepository.pending.last.complete(BaseEntity(0, '', []));
      } else {
        hotRepository.pending.last.complete(BaseEntity(0, '', []));
      }
      await empty;
      expect(controller.status, ResponseStatus.successNoData);
    });

    testWidgets('$name 请求防重且关闭后丢弃成功响应', (tester) async {
      final hotRepository = _HotRepository();
      final tabsRepository = _TabsRepository();
      final dynamic controller = tabs
          ? (TabsController(TagType.project)..request = tabsRepository)
          : (HotKeyController()..request = hotRepository);
      final Future<void> first = controller.aRequest();
      await controller.aRequest();
      expect(
          tabs ? tabsRepository.pending.length : hotRepository.pending.length,
          1);
      controller.onDelete();
      if (tabs) {
        tabsRepository.pending.last.complete(BaseEntity(0, '', [TabEntity()]));
      } else {
        hotRepository.pending.last
            .complete(BaseEntity(0, '', [HotKeyEntity()]));
      }
      await first;
      expect(controller.data, isNull);
      expect(controller.response, isNull);
    });

    testWidgets('$name 已有数据失败保持内容并吐司一次', (tester) async {
      await tester.pumpWidget(
          MaterialApp(builder: EasyLoading.init(), home: const Scaffold()));
      final hotRepository = _HotRepository();
      final tabsRepository = _TabsRepository();
      final dynamic controller = tabs
          ? (TabsController(TagType.project)..request = tabsRepository)
          : (HotKeyController()..request = hotRepository);
      final Future<void> success = controller.aRequest();
      if (tabs) {
        tabsRepository.pending.last.complete(BaseEntity(0, '', [TabEntity()]));
      } else {
        hotRepository.pending.last
            .complete(BaseEntity(0, '', [HotKeyEntity()]));
      }
      await success;
      final oldData = controller.data;
      final oldResponse = controller.response;
      final Future<void> failure = controller.aRequest();
      expect(controller.status, ResponseStatus.successHasContent);
      (tabs ? tabsRepository.pending : hotRepository.pending)
          .last
          .completeError('断网');
      await failure;
      await tester.pump();
      expect(controller.data, same(oldData));
      expect(controller.response, same(oldResponse));
      expect(controller.status, ResponseStatus.successHasContent);
      expect(find.text('加载失败，请重试'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  }

  test('分类初始化直接取得有 tag 的 Repository', () async {
    final repository = _TabsRepository();
    Get.put<TabsRepository>(repository, tag: TagType.project.toString());
    final controller = Get.put(TabsController(TagType.project));
    expect(controller.request, same(repository));
    expect(Get.isRegistered<TabsRepository>(), isFalse);
    expect(repository.pending, hasLength(1));
    repository.pending.single.complete(BaseEntity(0, '', []));
    await Future<void>.delayed(Duration.zero);
    expect(controller.status, ResponseStatus.successNoData);
  });
}
