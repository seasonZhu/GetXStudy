import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/base/base_paged_list_controller.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _Page = BaseEntity<PageEntity<List<int>>>;

_Page _page(List<int>? ids,
        {int current = 2, int total = 10, bool over = false}) =>
    BaseEntity(
        0,
        '',
        PageEntity<List<int>>.fromJson({})
          ..curPage = current
          ..pageCount = total
          ..over = over
          ..dataSource = ids);

class _Repository extends IRepository {}

class _Controller extends BasePagedListController<_Repository, int> {
  final calls = <int>[];
  final pending = <Completer<_Page>>[];
  int updates = 0;

  @override
  Future<_Page> fetchPage(int page) {
    calls.add(page);
    final result = Completer<_Page>();
    pending.add(result);
    return result.future;
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    updates++;
    super.update(ids, condition);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Controller controller;
  setUp(() {
    Get.testMode = true;
    controller = _Controller()
      ..initPage = 0
      ..page = 2
      ..dataSource = [1]
      ..response = _page([1])
      ..refreshController = RefreshController();
  });
  tearDown(() {
    if (!controller.isClosed) controller.onDelete();
    controller.refreshController.dispose();
    Get.reset();
  });

  testWidgets('刷新和加载更多互斥，失败保留旧页码、列表、响应，重试成功才提交', (tester) async {
    final previousResponse = controller.response;
    final failed = controller.onLoadMore();
    await controller.onRefresh();
    await controller.onLoadMore();
    expect(controller.calls, [3]);
    expect(controller.page, 2);
    controller.pending.last.completeError(Exception('断网'));
    await failed;
    tester.binding.scheduleFrame();
    await tester.pump();
    expect(controller.page, 2);
    expect(controller.dataSource, [1]);
    expect(controller.response, same(previousResponse));
    expect(controller.status, ResponseStatus.successHasContent);
    expect(controller.refreshController.footerStatus, LoadStatus.failed);
    expect(controller.isLoading, isFalse);
    final retry = controller.onLoadMore();
    controller.pending.last.complete(_page([2], over: true));
    await retry;
    tester.binding.scheduleFrame();
    await tester.pump();
    expect(controller.calls, [3, 3]);
    expect(controller.page, 3);
    expect(controller.dataSource, [1, 2]);
    expect(controller.refreshController.footerStatus, LoadStatus.noMore);
  });

  for (final initial in [0, 1]) {
    testWidgets('起始页 $initial 刷新替换，提交请求页而非响应页，随后加载追加', (tester) async {
      controller.initPage = initial;
      final refresh = controller.onRefresh();
      await controller.onLoadMore();
      expect(controller.calls, [initial]);
      expect(controller.page, 2);
      final source = [8];
      final result = _page(source, current: 99);
      controller.pending.last.complete(result);
      await refresh;
      tester.binding.scheduleFrame();
      await tester.pump();
      source.add(9);
      expect(controller.dataSource, [8]);
      expect(controller.response, same(result));
      expect(controller.page, initial);
      expect(
          controller.refreshController.headerStatus, RefreshStatus.completed);
      final more = controller.onLoadMore();
      controller.pending.last.complete(_page([10]));
      await more;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(controller.calls, [initial, initial + 1]);
      expect(controller.dataSource, [8, 10]);
      expect(controller.refreshController.footerStatus, LoadStatus.idle);
    });
  }

  for (final type in ScrollViewActionType.values) {
    testWidgets('$type 业务失败保留旧内容、响应及页码', (tester) async {
      final response = controller.response;
      final pending = controller.aRequest(type: type);
      controller.pending.last.complete(BaseEntity(-1, '失败', null));
      await pending;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(controller.page, 2);
      expect(controller.dataSource, [1]);
      expect(controller.response, same(response));
      expect(controller.status, ResponseStatus.successHasContent);
      expect(controller.isLoading, isFalse);
      if (type == ScrollViewActionType.refresh) {
        expect(controller.refreshController.headerStatus, RefreshStatus.failed);
      } else {
        expect(controller.refreshController.footerStatus, LoadStatus.failed);
      }
    });
  }

  testWidgets('首次请求异常显示失败，retry 与 emptyTap 均走共享刷新', (tester) async {
    controller.dataSource = [];
    final first = controller.onRefresh();
    controller.pending.last.completeError('超时');
    await first;
    tester.binding.scheduleFrame();
    await tester.pump();
    expect(controller.status, ResponseStatus.fail);
    controller.retry();
    controller.pending.last.complete(_page([]));
    tester.binding.scheduleFrame();
    await tester.pump();
    expect(controller.status, ResponseStatus.successNoData);
    controller.emptyTap();
    controller.pending.last.complete(_page([7]));
    tester.binding.scheduleFrame();
    await tester.pump();
    expect(controller.calls, [0, 0, 0]);
    expect(controller.dataSource, [7]);
  });

  for (final nullPage in [false, true]) {
    testWidgets('成功空数据（空分页对象：$nullPage）加载不增加、刷新清空', (tester) async {
      final more = controller.onLoadMore();
      controller.pending.last
          .complete(nullPage ? BaseEntity(0, '', null) : _page(null));
      await more;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(controller.dataSource, [1]);
      expect(controller.page, 3);
      final refresh = controller.onRefresh();
      controller.pending.last
          .complete(nullPage ? BaseEntity(0, '', null) : _page(null));
      await refresh;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(controller.dataSource, isEmpty);
      expect(controller.page, 0);
      expect(controller.status, ResponseStatus.successNoData);
    });
  }

  for (final byOver in [true, false]) {
    testWidgets('结束判断 ${byOver ? 'over' : 'curPage == pageCount'}，刷新重置页脚',
        (tester) async {
      final more = controller.onLoadMore();
      controller.pending.last
          .complete(_page([2], over: byOver, current: byOver ? 2 : 10));
      await more;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(controller.refreshController.footerStatus, LoadStatus.noMore);
      final refresh = controller.onRefresh();
      controller.pending.last.complete(_page([3]));
      await refresh;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(controller.refreshController.footerStatus, LoadStatus.idle);
    });
  }

  for (final fail in [false, true]) {
    testWidgets('关闭后${fail ? '异常' : '成功'}不提交、不通知，释放请求锁且不再请求', (tester) async {
      final response = controller.response;
      final pending = controller.onLoadMore();
      controller.onDelete();
      final updates = controller.updates;
      if (fail) {
        controller.pending.last.completeError('断网');
      } else {
        controller.pending.last.complete(_page([2]));
      }
      await pending;
      tester.binding.scheduleFrame();
      await tester.pump();
      await controller.onRefresh();
      expect(controller.calls, [3]);
      expect(controller.page, 2);
      expect(controller.response, same(response));
      expect(controller.dataSource, [1]);
      expect(controller.isLoading, isFalse);
      expect(controller.updates, updates);
    });
  }
}
