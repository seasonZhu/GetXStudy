import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';
import 'package:getx_study/pages/my/repository/my_collect_repository.dart';

class _Repository extends MyCollectRepository {
  final calls = <int>[];
  final listResult =
      Completer<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>();

  @override
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getCollectArticleList(
          {required int page}) =>
      listResult.future;

  final pending = <int, Completer<BaseEntity<Object?>>>{};

  @override
  Future<BaseEntity<Object?>> unCollectAction({required int originId}) {
    calls.add(originId);
    return (pending[originId] = Completer<BaseEntity<Object?>>()).future;
  }
}

ArticleInfoDatas _article(int id) => ArticleInfoDatas()..originId = id;

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  testWidgets('收藏请求乱序完成仍按 ID 删除，同一文章禁止重复提交', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final account = Get.put(AccountService())
      ..info = (AccountInfoEntity()..collectIds = [1, 2, 3]);
    final repository = _Repository();
    final controller = MyCollectController()
      ..request = repository
      ..dataSource = [_article(1), _article(2), _article(3)];
    final first = controller.unCollectAction(originId: 1);
    await controller.unCollectAction(originId: 1);
    final second = controller.unCollectAction(originId: 2);
    expect(repository.calls, [1, 2]);
    repository.pending[2]!.complete(BaseEntity(0, '', null));
    await second;
    expect(controller.dataSource.map((item) => item.originId), [1, 3]);
    repository.pending[1]!.complete(BaseEntity(0, '', null));
    await first;
    expect(controller.dataSource.single.originId, 3);
    expect(account.info!.collectIds, [3]);
    expect(controller.pendingUncollectIds, isEmpty);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('请求中列表变化不会误删，最后一项移除后显示空态', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    Get.put(AccountService()).info = (AccountInfoEntity()..collectIds = [1, 2]);
    final repository = _Repository();
    final controller = MyCollectController()
      ..request = repository
      ..dataSource = [_article(1)];
    final pending = controller.unCollectAction(originId: 1);
    controller.dataSource = [_article(2)];
    repository.pending[1]!.complete(BaseEntity(0, '', null));
    await pending;
    expect(controller.dataSource.single.originId, 2);
    controller.removeUnCollectItem(_article(99));
    expect(controller.dataSource.single.originId, 2);
    controller.removeUnCollectItem(_article(2));
    expect(controller.status, ResponseStatus.successNoData);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('较早发起的刷新不会带回刚取消的文章', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    Get.put(AccountService()).info = (AccountInfoEntity()..collectIds = [1]);
    final repository = _Repository();
    final controller = MyCollectController()
      ..request = repository
      ..initPage = 0
      ..page = 0
      ..refreshController = RefreshController()
      ..dataSource = [_article(1)];
    addTearDown(controller.refreshController.dispose);
    final refresh = controller.onRefresh();
    final cancel = controller.unCollectAction(originId: 1);
    repository.pending[1]!.complete(BaseEntity(0, '', null));
    await cancel;
    final data = PageEntity<List<ArticleInfoDatas>>.fromJson({})
      ..dataSource = [_article(1)];
    repository.listResult.complete(BaseEntity(0, '', data));
    await refresh;
    expect(controller.dataSource, isEmpty);
    expect(controller.status, ResponseStatus.successNoData);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  test('关闭后忽略取消收藏响应', () async {
    final account = Get.put(AccountService())
      ..info = (AccountInfoEntity()..collectIds = [1]);
    final repository = _Repository();
    final controller = MyCollectController()
      ..request = repository
      ..dataSource = [_article(1)];
    final pending = controller.unCollectAction(originId: 1);
    controller.onDelete();
    repository.pending[1]!.complete(BaseEntity(0, '', null));
    await pending;
    expect(controller.dataSource, hasLength(1));
    expect(account.info!.collectIds, [1]);
  });
}
