import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/pages/common/refresh_header_footer.dart';
import 'package:getx_study/pages/my/view/auth_field.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  testWidgets('短列表的到底提示紧跟内容，无内容时关闭尾部', (tester) async {
    final controller = RefreshController(initialLoadStatus: LoadStatus.noMore);
    final showItems = ValueNotifier(true);
    await _mount(
      tester,
      ValueListenableBuilder<bool>(
        valueListenable: showItems,
        builder: (context, visible, child) => SmartRefresher(
          controller: controller,
          enablePullDown: false,
          enablePullUp: visible,
          footer: const RefreshFooter(),
          child: ListView(
            children: [
              if (visible)
                const SizedBox(height: 50, child: Text('最后一项'))
              else
                const Text('空态'),
            ],
          ),
        ),
      ),
    );
    final end = find.text('我是有底线的');
    expect(end, findsOneWidget);
    final gap = tester.getTopLeft(end).dy -
        tester.getTopLeft(find.text('最后一项')).dy -
        50;
    expect(gap, inInclusiveRange(12, 24));
    showItems.value = false;
    await tester.pump();
    expect(end, findsNothing);
    expect(find.text('空态'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    showItems.dispose();
    controller.dispose();
  });

  testWidgets('加载图标与尾部区域顶部至少相隔 12', (tester) async {
    const footer = RefreshFooter();
    final context = await _mount(tester, const SizedBox());
    final indicator = footer.build(context) as CustomFooter;
    await _mount(
      tester,
      SizedBox(
        key: const ValueKey('footer'),
        height: indicator.height,
        child: indicator.builder(context, LoadStatus.loading),
      ),
    );
    final top = tester.getTopLeft(find.byKey(const ValueKey('footer'))).dy;
    final spinnerTop =
        tester.getTopLeft(find.byType(CupertinoActivityIndicator)).dy;
    expect(spinnerTop - top, greaterThanOrEqualTo(12));
  });

  testWidgets('账号清除按钮有足够触控面积且仅在有文字时显示', (tester) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    await _mount(
      tester,
      AuthField(
        controller: controller,
        focusNode: focus,
        placeholder: '账号',
        textInputAction: TextInputAction.next,
      ),
    );
    final clear = find.byType(CupertinoButton);
    expect(clear, findsNothing);
    await tester.enterText(find.byType(CupertinoTextField), '账号内容');
    await tester.pump();
    expect(tester.getSize(clear), const Size(44, 44));
    await tester.tap(clear);
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(clear, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    focus.dispose();
  });
}

Future<BuildContext> _mount(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(CupertinoApp(
    home: CupertinoPageScaffold(
        child: Align(
      alignment: Alignment.topCenter,
      child: child,
    )),
  ));
  return tester.element(find.byType(CupertinoPageScaffold));
}
