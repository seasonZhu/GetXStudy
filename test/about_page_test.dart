import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/enum/my.dart';
import 'package:getx_study/pages/my/view/about_page.dart';
import 'package:getx_study/routes/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  tearDown(Get.reset);

  test('游客与登录菜单均在体系布局之后展示关于入口', () {
    for (final items in [
      Extension.visitorDataSource,
      Extension.userDataSource,
    ]) {
      expect(items[items.indexOf(My.treeLayoutSetting) + 1], My.about);
      expect(items, isNot(contains(My.myGitHub)));
      expect(items, isNot(contains(My.myJueJin)));
    }
    expect(My.about.path, Routes.about);
  });

  testWidgets('版本读取期间显示占位，失败后显示提示', (tester) async {
    const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
    final messenger = tester.binding.defaultBinaryMessenger;
    final gate = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (_) async {
      await gate.future;
      throw PlatformException(code: 'fixture');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(const GetCupertinoApp(home: AboutPage()));
    expect(find.text('正在读取…'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
    final tiles = find.byType(ListTile);
    expect(tiles, findsNWidgets(3));
    final height = tester.getSize(tiles.first).height;
    expect(tester.getSize(tiles.at(1)).height, height);
    expect(tester.getSize(tiles.last).height, height);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('版本信息读取失败'), findsOneWidget);
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final nativeBuild in [null, '7']) {
      testWidgets('$platform 版本信息与构建号渠道结果 $nativeBuild', (tester) async {
        PackageInfo.setMockInitialValues(
          appName: 'GetXStudy',
          packageName: 'com.example.getx_study',
          version: '1.2.3',
          buildNumber: '2007',
          buildSignature: '',
        );
        const channel = MethodChannel('getx_study/build_info');
        final messenger = tester.binding.defaultBinaryMessenger;
        var channelCalls = 0;
        messenger.setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'buildNumber');
          channelCalls++;
          if (nativeBuild == null) throw MissingPluginException();
          return nativeBuild;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

        WebLoadInfoEntity? destination;
        await tester.pumpWidget(GetCupertinoApp(
          home: const CupertinoPageScaffold(child: SizedBox()),
          getPages: [
            Routes.routePage.singleWhere((page) => page.name == Routes.about),
            GetPage(
              name: Routes.web,
              page: () {
                destination = Get.arguments as WebLoadInfoEntity;
                return const CupertinoPageScaffold(child: SizedBox());
              },
            ),
          ],
        ));
        Get.toNamed<void>(Routes.about);
        await tester.pumpAndSettle();
        final android = platform == TargetPlatform.android;
        final expectedBuild = android ? nativeBuild ?? '2007' : '2007';
        expect(find.text('版本号 1.2.3 · 构建号 $expectedBuild'), findsOneWidget);
        expect(channelCalls, android ? 1 : 0);

        for (final item in [My.myGitHub, My.myJueJin]) {
          await tester.tap(find.text(item.title));
          await tester.pumpAndSettle();
          expect(destination?.link, item.entity!.link);
          expect(destination?.title, item.title);
          Get.back<void>();
          await tester.pumpAndSettle();
        }
        expect(channelCalls, android ? 1 : 0);
      }, variant: TargetPlatformVariant({platform}));
    }
  }
}
