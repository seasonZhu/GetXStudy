import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/home/controller/search_result_controller.dart';
import 'package:getx_study/pages/home/repository/search_result_repository.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _Page = BaseEntity<PageEntity<List<ArticleInfoDatas>>>;

ArticleInfoDatas _article(int id) => ArticleInfoDatas()..id = id;

_Page _page(int current, List<int> ids, {bool over = false}) {
  final data = PageEntity<List<ArticleInfoDatas>>.fromJson({})
    ..curPage = current
    ..pageCount = 10
    ..over = over
    ..dataSource = ids.map(_article).toList();
  return BaseEntity(0, '', data);
}

class _RefreshController extends RefreshController {
  bool loadFailedCalled = false;
  bool noMoreCalled = false;

  @override
  void loadFailed() {
    loadFailedCalled = true;
    super.loadFailed();
  }

  @override
  void loadNoData() {
    noMoreCalled = true;
    super.loadNoData();
  }
}

class _SearchRepository extends SearchResultRepository {
  final calls = <(int, String)>[];
  final pending = <Completer<_Page>>[];

  @override
  Future<_Page> searchKeyword({required int page, required String keyword}) {
    calls.add((page, keyword));
    final result = Completer<_Page>();
    pending.add(result);
    return result.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  test('列表异常保留旧数据与页码，重试成功后才提交页码', () async {
    final repository = _SearchRepository();
    final controller = SearchResultController()
      ..request = repository
      ..keyword = '固定关键词'
      ..initPage = 0
      ..page = 2
      ..dataSource = [_article(1)]
      ..refreshController = _RefreshController();
    addTearDown(controller.refreshController.dispose);

    final failed = controller.onLoadMore();
    await controller.onRefresh();
    expect(repository.calls, [(3, '固定关键词')]);
    repository.pending[0].completeError(Exception('断网'));
    await failed;
    expect(controller.page, 2);
    expect(controller.dataSource.single.id, 1);
    expect(controller.status, ResponseStatus.successHasContent);
    expect(
        (controller.refreshController as _RefreshController).loadFailedCalled,
        isTrue);
    expect(controller.isLoading, isFalse);

    final retried = controller.onLoadMore();
    repository.pending[1].complete(_page(3, [2], over: true));
    await retried;
    expect(controller.page, 3);
    expect(controller.dataSource.map((item) => item.id), [1, 2]);
    expect((controller.refreshController as _RefreshController).noMoreCalled,
        isTrue);
  });

  test('刷新业务失败不清空数据，不提前重置页码', () async {
    final repository = _SearchRepository();
    final controller = SearchResultController()
      ..request = repository
      ..keyword = '关键词'
      ..initPage = 0
      ..page = 3
      ..dataSource = [_article(1)]
      ..refreshController = _RefreshController();
    addTearDown(controller.refreshController.dispose);
    final pending = controller.onRefresh();
    repository.pending.single.complete(BaseEntity(-1, '业务失败', null));
    await pending;
    expect(controller.page, 3);
    expect(controller.dataSource.single.id, 1);
    expect(controller.refreshController.headerStatus, RefreshStatus.failed);
  });

  test('首次请求失败可重试；关闭后不接收结果', () async {
    final repository = _SearchRepository();
    final controller = SearchResultController()
      ..request = repository
      ..keyword = '关键词'
      ..initPage = 0
      ..page = 0
      ..refreshController = _RefreshController();
    addTearDown(controller.refreshController.dispose);
    final first = controller.onRefresh();
    repository.pending[0].completeError('超时');
    await first;
    expect(controller.status, ResponseStatus.fail);
    final next = controller.onRefresh();
    controller.onDelete();
    repository.pending[1].complete(_page(0, [1]));
    await next;
    expect(controller.dataSource, isEmpty);
    expect(controller.isLoading, isFalse);
  });
}
