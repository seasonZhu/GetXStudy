import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/pages/common/scroll_to_top.dart';
import 'package:getx_study/enum/theme_type.dart';

void main() {
  testWidgets('回顶按钮跟随五套 Cupertino 主题', (tester) async {
    final selected = ValueNotifier(ThemeType.light);
    addTearDown(selected.dispose);
    await tester.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<ThemeType>(
        valueListenable: selected,
        builder: (context, type, child) => CupertinoTheme(
          data: type.theme,
          child: child!,
        ),
        child: Stack(children: [
          ScrollToTopButton(onPressed: () {}),
        ]),
      ),
    ));
    final backgrounds = {
      ThemeType.light: const Color(0xFF13578D),
      ThemeType.blue: const Color(0xFF13578D),
      ThemeType.green: const Color(0xFF2C662E),
      ThemeType.red: const Color(0xFF8E271F),
      ThemeType.dark: const Color(0xFFE5E5EA),
    };
    for (final entry in backgrounds.entries) {
      selected.value = entry.key;
      await tester.pump();
      final button = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(button.backgroundColor!.toARGB32(), entry.value.toARGB32());
      expect(button.foregroundColor,
          entry.key == ThemeType.dark ? const Color(0xFF1C1C1E) : Colors.white);
    }
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform 超过一屏后可回顶，尺寸变化时重新判断', (tester) async {
      final controller = ScrollController();
      final height = ValueNotifier(300.0);
      addTearDown(controller.dispose);
      addTearDown(height.dispose);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: platform),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: platform == TargetPlatform.iOS,
          ),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: ValueListenableBuilder<double>(
              valueListenable: height,
              builder: (context, value, child) =>
                  SizedBox(height: value, child: child),
              child: ScrollToTop(
                child: ListView.builder(
                  controller: controller,
                  itemExtent: 60,
                  itemCount: 100,
                  itemBuilder: (_, index) => Text('项目 $index'),
                ),
              ),
            ),
          ),
        ),
      ));
      final button = find.byType(FloatingActionButton);
      controller.jumpTo(300);
      await tester.pumpAndSettle();
      expect(button, findsNothing);

      controller.jumpTo(350);
      await tester.pumpAndSettle();
      expect(button, findsOneWidget);
      height.value = 400;
      await tester.pumpAndSettle();
      expect(button, findsNothing);
      height.value = 300;
      await tester.pumpAndSettle();
      expect(button, findsOneWidget);

      await tester.tap(button);
      if (platform == TargetPlatform.iOS) {
        expect(controller.offset, controller.position.minScrollExtent);
      }
      await tester.pumpAndSettle();
      expect(controller.offset, controller.position.minScrollExtent);
      expect(button, findsNothing);

      if (platform == TargetPlatform.android) {
        controller.jumpTo(2400);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.offset, greaterThan(0));
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(ListView)),
        );
        await gesture.moveBy(const Offset(0, -80));
        await tester.pump();
        final interruptedOffset = controller.offset;
        await tester.pump(const Duration(milliseconds: 500));
        expect(controller.offset, interruptedOffset);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(controller.offset, greaterThan(0));
      }
    });
  }
}
