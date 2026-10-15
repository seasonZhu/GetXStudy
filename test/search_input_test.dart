import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/pages/home/view/search_text_field.dart';

void main() {
  testWidgets('搜索输入在父组件重建后保留，空白不提交，卸载无异常', (tester) async {
    final results = <String>[];
    Widget build() => MaterialApp(
          home: Scaffold(body: SearchValueField(keywordCallback: results.add)),
        );
    await tester.pumpWidget(build());
    await tester.enterText(find.byType(CupertinoTextField), '  Flutter  ');
    await tester.pumpWidget(build());
    expect(find.text('  Flutter  '), findsOneWidget);
    await tester.tap(find.text('搜索'));
    expect(results, ['Flutter']);
    await tester.enterText(find.byType(CupertinoTextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(results, ['Flutter']);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
