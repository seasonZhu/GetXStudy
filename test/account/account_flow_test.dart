import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/entity/account_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/pages/my/controller/login_controller.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/controller/register_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AccountService extends AccountService {
  int saveCalls = 0;

  @override
  Future<void> save({
    required AccountInfoEntity info,
    required bool isLogin,
    required String password,
  }) async {
    saveCalls++;
    sessionRevision++;
    this.info = info;
    this.isLogin = isLogin;
    userInfo = '等级 --  排名 --  积分 --';
  }

  @override
  Future<String> getLastLoginUserName() async => '测试账户';

  @override
  Future<String> getLastLoginPassword() async => '测试密码';
}

class _Repository extends MyRepository {
  int loginCalls = 0;
  int registerCalls = 0;
  final loginResult = Completer<BaseEntity<AccountInfoEntity>>();
  final coinResult = Completer<BaseEntity<CoinRankDatas>>();

  @override
  Future<BaseEntity<AccountInfoEntity>> login({
    required String username,
    required String password,
  }) {
    loginCalls++;
    return loginResult.future;
  }

  @override
  Future<BaseEntity<AccountInfoEntity>> register({
    required String username,
    required String password,
    required String rePassword,
  }) {
    registerCalls++;
    return loginResult.future;
  }

  @override
  Future<BaseEntity<CoinRankDatas>> getUserCoinInfo() => coinResult.future;
}

AccountInfoEntity _info(String username) =>
    AccountInfoEntity()..username = username;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _AccountService account;
  late _Repository repository;

  setUp(() {
    Get.testMode = true;
    account = _AccountService();
    repository = _Repository();
    Get.put<AccountService>(account);
    Get.put<MyRepository>(repository);
  });

  tearDown(() {
    Get.reset();
  });

  test('输入监听覆盖程序赋值、清空和确认密码相等检查', () {
    final controller = Get.put(RegisterController());
    controller.userNameTextFiledController.text = '测试账户';
    controller.passwordTextFiledController.text = '密码';
    controller.rePasswordTextFiledController.text = '密码';
    expect(controller.isShowRegisterButton, isTrue);
    controller.rePasswordTextFiledController.text = '其他密码';
    expect(controller.isShowRegisterButton, isFalse);
    controller.rePasswordTextFiledController.text = '密码';
    controller.userNameTextFiledController.clear();
    expect(controller.userNameIsNotEmpty.value, isFalse);
    expect(controller.isShowRegisterButton, isFalse);
  });

  test('确认密码不匹配不发起注册', () async {
    final controller = Get.put(RegisterController());
    await controller.register(
      username: '账户',
      password: '密码',
      rePassword: '不同密码',
    );
    expect(repository.registerCalls, 0);
  });

  test('登录防重，关闭后响应不保存账户', () async {
    final controller = Get.put(LoginController());
    final first = controller.login(username: '账户', password: '密码');
    await controller.login(username: '账户', password: '密码');
    expect(repository.loginCalls, 1);
    await Get.delete<LoginController>();
    repository.loginResult.complete(BaseEntity(0, '', _info('账户')));
    await first;
    expect(account.saveCalls, 0);
  });

  test('自动登录防重，积分失败不撤销已完成登录', () async {
    final controller = Get.put(MyController());
    final first = controller.autoLogin();
    await controller.autoLogin();
    await Future<void>.delayed(Duration.zero);
    expect(repository.loginCalls, 1);
    repository.loginResult.complete(BaseEntity(0, '', _info('账户')));
    await first;
    expect(controller.isLogin.value, isTrue);
    repository.coinResult.completeError(Exception('积分不可用'));
    await Future<void>.delayed(Duration.zero);
    expect(account.isLogin, isTrue);
    expect(controller.isLogin.value, isTrue);
  });

  test('切换会话后丢弃旧积分响应', () async {
    final controller = Get.put(MyController());
    await account.save(info: _info('旧账户'), isLogin: true, password: '密码');
    final pending = controller.getUserCoinInfo();
    await account.save(info: _info('新账户'), isLogin: true, password: '密码');
    repository.coinResult.complete(
      BaseEntity(0, '', CoinRankDatas()..coinCount = 100),
    );
    await pending;
    expect(account.info?.username, '新账户');
    expect(account.userInfo, '等级 --  排名 --  积分 --');
  });

  test('积分完成后同步我的页，不依赖已关闭登录页的生命周期', () async {
    await account.save(info: _info('账户'), isLogin: true, password: '密码');
    final myController = Get.put(MyController());
    final loginController = Get.put(LoginController());
    final pending = loginController.getUserCoinInfo();
    await Get.delete<LoginController>();
    repository.coinResult.complete(
      BaseEntity(0, '', CoinRankDatas()..coinCount = 100),
    );
    await pending;
    expect(myController.rxUserInfo.value, contains('积分 100'));
  });

  for (final isRegister in [false, true]) {
    testWidgets('${isRegister ? '注册' : '登录'}成功立即返回统一结果，积分仍可在后台等待',
        (tester) async {
      Map<String, dynamic>? result;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Get.to<Map<String, dynamic>>(
                  () => const Scaffold(body: Text('登录页面')),
                );
              },
              child: const Text('打开登录'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开登录'));
      await tester.pumpAndSettle();
      final controller = isRegister
          ? Get.put(RegisterController())
          : Get.put(LoginController());
      await tester.runAsync(() async {
        final pending = isRegister
            ? (controller as RegisterController)
                .register(username: '账户', password: '密码', rePassword: '密码')
            : controller.login(username: '账户', password: '密码');
        repository.loginResult.complete(BaseEntity(0, '', _info('账户')));
        await pending;
      });
      await tester.pumpAndSettle();
      expect(result, {'isLogin': true, 'userInfo': '等级 --  排名 --  积分 --'});
      expect(repository.coinResult.isCompleted, isFalse);
      await tester.runAsync(() async {
        repository.coinResult
            .complete(BaseEntity(0, '', CoinRankDatas()..coinCount = 100));
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }

  test('空白用户名或空密码不发起登录', () async {
    final controller = Get.put(LoginController());
    await controller.login(username: '   ', password: '密码');
    await controller.login(username: '账户', password: '');
    expect(repository.loginCalls, 0);
  });

  test('账户落盘失败恢复登录前的内存状态', () async {
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: '保存失败');
    });
    final service = AccountService();
    try {
      await expectLater(
        service.save(info: _info('账户'), isLogin: true, password: '密码'),
        throwsA(isA<PlatformException>()),
      );
      expect(service.isLogin, isFalse);
      expect(service.info, isNull);
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
  });

  test('保存中退出，退出清理在旧保存之后落盘', () async {
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    final writing = Completer<void>();
    final started = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'write') {
        started.complete();
        await writing.future;
      }
      return null;
    });
    final service = AccountService();
    try {
      final saving = service.save(
        info: _info('账户'),
        isLogin: true,
        password: '密码',
      );
      await started.future;
      final clearing = service.clear();
      writing.complete();
      await Future.wait([saving, clearing]);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('kAccountInfo'), isNull);
      expect(preferences.getString('kLastLoginUserName'), isNull);
      expect(service.info, isNull);
      expect(service.isLogin, isFalse);
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
  });

  test('保存账户沿用现有 JSON 格式与安全存储写入', () async {
    SharedPreferences.setMockInitialValues({});
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    try {
      await AccountService()
          .save(info: _info('账户'), isLogin: true, password: '密码');
      final preferences = await SharedPreferences.getInstance();
      expect(
          preferences.getString('kAccountInfo'), contains('"password":"密码"'));
      expect(preferences.getString('kLastLoginUserName'), '账户');
      expect(calls.single.method, 'write');
      expect(calls.single.arguments['value'], '密码');
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
  });

  test('退出时清除账户缓存且保留主题偏好', () async {
    SharedPreferences.setMockInitialValues({
      'kLastLoginUserName': '账户',
      'kAccountInfo': '{"password":"密码"}',
      'kThemeSetting': 1,
    });
    const channel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    final service = AccountService()
      ..info = _info('账户')
      ..isLogin = true;
    try {
      await service.clear();
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('kAccountInfo'), isNull);
      expect(preferences.getString('kLastLoginUserName'), isNull);
      expect(preferences.getInt('kThemeSetting'), 1);
      expect(service.isLogin, isFalse);
      expect(service.info, isNull);
      expect(calls.single.method, 'delete');
    } finally {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
  });
}
