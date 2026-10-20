import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/collection_service.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/my/controller/my_collect_controller.dart';
import 'package:getx_study/pages/my/repository/my_collect_repository.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/collection_fakes.dart';

typedef _Page = BaseEntity<PageEntity<List<ArticleInfoDatas>>>;

class _Repository extends MyCollectRepository {
  final pending = <Completer<_Page>>[];
  @override
  Future<_Page> getCollectArticleList({required int page}) {
    final result = Completer<_Page>();
    pending.add(result);
    return result.future;
  }
}

ArticleInfoDatas _article(int id) => ArticleInfoDatas()..originId = id;
_Page _page(List<int> ids) => BaseEntity(
    0,
    '',
    PageEntity<List<ArticleInfoDatas>>.fromJson({})
      ..dataSource = ids.map(_article).toList());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AccountService account;
  late CollectionService collections;
  late FakeCollectionRepository commands;
  late _Repository repository;
  late MyCollectController controller;
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    account = Get.put(AccountService())
      ..isLogin = true
      ..info = (AccountInfoEntity()..collectIds = [1, 2, 3]);
    commands = FakeCollectionRepository();
    collections = Get.put(CollectionService(account, commands));
    repository = _Repository();
    Get.put<MyCollectRepository>(repository);
    Get.put<int>(0, tag: className(MyCollectController));
    Get.put(RefreshController(), tag: className(MyCollectController));
    controller = Get.put(MyCollectController())
      ..dataSource = [_article(1), _article(2), _article(3)];
  });
  tearDown(() async {
    if (!controller.isClosed) controller.onDelete();
    if (!collections.isClosed) collections.onDelete();
    if (!account.isClosed) account.onDelete();
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('共享命令乱序完成按 ID 即时删除，最后一项取消显示空态', () async {
    final first = collections.setCollected(1, false);
    final second = collections.setCollected(2, false);
    commands.calls[1].succeed();
    await second;
    expect(controller.dataSource.map((e) => e.originId), [1, 3]);
    commands.calls[0].succeed();
    await first;
    final last = collections.setCollected(3, false);
    commands.calls.last.succeed();
    await last;
    expect(controller.dataSource, isEmpty);
    expect(controller.status, ResponseStatus.successNoData);
  });

  test('较早刷新不会带回刚取消的文章，重新收藏后以最终变更为准', () async {
    final refresh = controller.onRefresh();
    final cancel = collections.setCollected(1, false);
    commands.calls.last.succeed();
    await cancel;
    repository.pending.last.complete(_page([1, 2]));
    await refresh;
    expect(controller.dataSource.map((e) => e.originId), [2]);

    final next = controller.onRefresh();
    final cancelAgain = collections.setCollected(2, false);
    commands.calls.last.succeed();
    await cancelAgain;
    final restore = collections.setCollected(2, true);
    commands.calls.last.succeed();
    await restore;
    expect(controller.dataSource, isEmpty);
    repository.pending.last.complete(_page([2]));
    await next;
    expect(controller.dataSource.single.originId, 2);
  });

  test('会话切换立即清空，旧分页完成不能提交或释放新请求状态', () async {
    final old = controller.onRefresh();
    await account.save(
        info: AccountInfoEntity()..collectIds = [9],
        isLogin: true,
        password: '测试');
    expect(controller.dataSource, isEmpty);
    expect(controller.isLoading, isFalse);
    final current = controller.onRefresh();
    repository.pending[0].complete(_page([1]));
    await old;
    expect(controller.isLoading, isTrue);
    expect(controller.dataSource, isEmpty);
    repository.pending[1].complete(_page([9]));
    await current;
    expect(controller.dataSource.single.originId, 9);
  });

  test('列表关闭后请求仍提交共享状态，列表订阅释放', () async {
    final pending = controller.unCollectAction(originId: 1);
    controller.onDelete();
    commands.calls.last.succeed();
    await pending;
    expect(collections.isCollected(1), isFalse);
    expect(controller.dataSource, hasLength(3));
    expect(controller.refreshController.headerMode, isNull);
  });
}
