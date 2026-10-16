import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/logger/debug_logs_page.dart';
import 'package:getx_study/logger/logger.dart';

void main() {
  testWidgets('Cupertino 应用中查看、搜索、筛选、清空日志并返回', (tester) async {
    appTalker.configure(
        settings: TalkerSettings(useConsoleLogs: false, maxHistoryItems: 300));
    appTalker.cleanHistory();
    Map<dynamic, dynamic>? shared;
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        shared = call.arguments as Map<dynamic, dynamic>;
        return '测试分享目标';
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    logger.i('页面测试事件');
    await tester.pumpWidget(CupertinoApp(
      home: Builder(builder: (context) {
        return CupertinoPageScaffold(
          child: CupertinoButton(
            child: const Text('打开日志'),
            onPressed: () =>
                Navigator.of(context).push(CupertinoPageRoute<void>(
              builder: (_) => const DebugLogsPage(),
            )),
          ),
        );
      }),
    ));
    await tester.tap(find.text('打开日志'));
    await tester.pumpAndSettle();
    expect(find.text('调试日志'), findsOneWidget);
    expect(find.textContaining('页面测试事件'), findsWidgets);
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('分享当前筛选日志'), findsOneWidget);
    await tester.tap(find.byTooltip('分享当前筛选日志'));
    await tester.pumpAndSettle();
    expect(shared?['text'], contains('页面测试事件'));
    expect(shared?['originWidth'], greaterThan(0));
    expect(shared?['originHeight'], greaterThan(0));
    await tester.enterText(find.byType(TextField), '不存在的事件');
    await tester.pumpAndSettle();
    expect(find.text('暂无匹配日志'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('业务'));
    await tester.pumpAndSettle();
    expect(find.textContaining('页面测试事件'), findsWidgets);
    await tester.tap(find.byTooltip('清空日志'));
    await tester.pumpAndSettle();
    expect(find.text('暂无匹配日志'), findsOneWidget);
    expect(appTalker.history, isEmpty);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('打开日志'), findsOneWidget);
  });
}
