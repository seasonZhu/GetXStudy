import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/app_service/app_launcher_service.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

class _Launcher extends UrlLauncherPlatform {
  late Completer<bool> canResult;
  late Completer<bool> launchResult;
  int checks = 0;
  int launches = 0;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) {
    checks++;
    canResult = Completer<bool>();
    return canResult.future;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) {
    launches++;
    launchResult = Completer<bool>();
    return launchResult.future;
  }
}

void main() {
  late UrlLauncherPlatform previous;
  late _Launcher launcher;
  late AppLauncherService service;

  setUp(() {
    previous = UrlLauncherPlatform.instance;
    launcher = _Launcher();
    UrlLauncherPlatform.instance = launcher;
    service = AppLauncherService();
  });
  tearDown(() {
    UrlLauncherPlatform.instance = previous;
    EasyLoading.dismiss(animation: false);
  });

  Future<void> mount(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(home: const Scaffold(), builder: EasyLoading.init()));

  testWidgets('已关闭的调用不检查或拉起外部 App', (tester) async {
    await mount(tester);
    await service.launchExternalApp('weixin://', isActive: () => false);
    expect(launcher.checks, 0);
    expect(launcher.launches, 0);
    expect(EasyLoading.isShow, isFalse);
  });

  for (final canLaunch in [true, false]) {
    testWidgets('等待能力查询期间关闭，结果 $canLaunch 不再拉起、提示或引导', (tester) async {
      await mount(tester);
      var active = true;
      var fallbacks = 0;
      final pending = service.launchExternalApp('weixin://',
          isActive: () => active, onNotInstalled: (_) => fallbacks++);
      expect(UrlLauncherPlatform.instance, same(launcher));
      expect(launcher.checks, 1);
      active = false;
      launcher.canResult.complete(canLaunch);
      var finished = false;
      pending.then((_) => finished = true);
      await tester.pump();
      expect(finished, isTrue);
      await pending;
      await tester.pump();
      expect(launcher.launches, 0);
      expect(fallbacks, 0);
      expect(EasyLoading.isShow, isFalse);
    });
  }

  for (final throws in [false, true]) {
    testWidgets('已发起系统拉起后关闭，${throws ? '异常' : '成功'}不再提示', (tester) async {
      await mount(tester);
      var active = true;
      final pending =
          service.launchExternalApp('weixin://', isActive: () => active);
      launcher.canResult.complete(true);
      await tester.pump();
      expect(launcher.launches, 1);
      active = false;
      if (throws) {
        launcher.launchResult.completeError(StateError('失败'));
      } else {
        launcher.launchResult.complete(true);
      }
      await pending;
      await tester.pump();
      expect(EasyLoading.isShow, isFalse);
    });
  }

  testWidgets('未传有效性检查保留原有拉起成功提示', (tester) async {
    await mount(tester);
    final pending = service.launchExternalApp('weixin://');
    launcher.canResult.complete(true);
    await tester.pump();
    launcher.launchResult.complete(true);
    await pending;
    await tester.pump();
    expect(launcher.launches, 1);
    expect(EasyLoading.isShow, isTrue);
    EasyLoading.dismiss(animation: false);
    await tester.pump();
  });

  testWidgets('页面有效时保留未安装提示及引导', (tester) async {
    await mount(tester);
    var fallback = '';
    final pending = service.launchExternalApp('weixin://',
        isActive: () => true, onNotInstalled: (url) => fallback = url);
    launcher.canResult.complete(false);
    await pending;
    expect(fallback, 'weixin://');
    expect(EasyLoading.isShow, isTrue);
    EasyLoading.dismiss(animation: false);
    await tester.pump();
  });
}
