import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/app_service/collection_service.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/collection_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AccountService account;
  late CollectionService collections;
  late FakeCollectionRepository repository;
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    account = Get.put(AccountService())
      ..isLogin = true
      ..info = (AccountInfoEntity()..collectIds = [1, 1, 2]);
    repository = FakeCollectionRepository();
    collections = Get.put(CollectionService(account, repository));
  });
  tearDown(() async {
    if (!collections.isClosed) collections.onDelete();
    if (!account.isClosed) account.onDelete();
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('同篇文章跨入口防重，不同文章可乱序完成，取消移除全部重复 ID', () async {
    final first = collections.setCollected(1, false);
    expect(collections.isPending(1), isTrue);
    expect((await collections.setCollected(1, true)).type,
        CollectionResultType.duplicate);
    final second = collections.setCollected(3, true);
    repository.calls[1].succeed();
    await second;
    repository.calls[0].succeed();
    await first;
    expect(account.info!.collectIds, [2, 3]);
    expect(collections.isPending(1), isFalse);
  });

  test('空集合初始化，重复收藏不增加重复 ID', () async {
    account.info!.collectIds = null;
    for (var i = 0; i < 2; i++) {
      final pending = collections.setCollected(7, true);
      repository.calls.last.succeed();
      expect((await pending).type, CollectionResultType.success);
    }
    expect(account.info!.collectIds, [7]);
  });

  test('业务失败及异常保留状态并释放锁', () async {
    final first = collections.setCollected(1, false);
    repository.calls.last.result.complete(BaseEntity(-1, '失败', null));
    expect((await first).type, CollectionResultType.failure);
    final second = collections.setCollected(1, false);
    repository.calls.last.result.completeError(Exception('断网'));
    expect((await second).type, CollectionResultType.failure);
    expect(account.info!.collectIds, [1, 1, 2]);
    expect(collections.isPending(1), isFalse);
  });

  test('退出使旧响应失效，未登录不发送请求', () async {
    final pending = collections.setCollected(1, false);
    await account.clear();
    repository.calls.last.succeed();
    expect((await pending).type, CollectionResultType.staleSession);
    expect((await collections.setCollected(1, true)).type,
        CollectionResultType.notLoggedIn);
    expect(repository.calls, hasLength(1));
  });

  test('切换账户后同 ID 可重新操作，旧请求不能释放新锁或修改新账户', () async {
    final old = collections.setCollected(1, false);
    final newInfo = AccountInfoEntity()..collectIds = [1];
    await account.save(info: newInfo, isLogin: true, password: '测试');
    final current = collections.setCollected(1, false);
    repository.calls[0].succeed();
    expect((await old).type, CollectionResultType.staleSession);
    expect(newInfo.collectIds, [1]);
    expect(collections.isPending(1), isTrue);
    repository.calls[1].succeed();
    await current;
    expect(newInfo.collectIds, isEmpty);
  });

  test('账户对象替换即使版本相同也不能接收旧响应', () async {
    final pending = collections.setCollected(1, false);
    account.info = AccountInfoEntity()..collectIds = [1];
    repository.calls.last.succeed();
    expect((await pending).type, CollectionResultType.staleSession);
    expect(account.info!.collectIds, [1]);
  });

  test('保存、保存失败回滚及清除均通知订阅者', () async {
    final snapshots = <AccountInfoEntity?>[];
    final subscription = collections.changes.listen((event) {
      if (event.sessionChanged) snapshots.add(account.info);
    });
    final previous = account.info;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: '写入失败');
    });
    final failedInfo = AccountInfoEntity();
    await expectLater(
        account.save(info: failedInfo, isLogin: true, password: ''),
        throwsA(isA<PlatformException>()));
    expect(snapshots, [failedInfo, previous]);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    await account.clear();
    expect(snapshots.last, isNull);
    await subscription.cancel();
  });
}
