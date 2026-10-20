import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/enum/theme_type.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_page.dart';
import 'package:getx_study/pages/my/view/theme_setting_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class _RankController extends CoinRankController {
  // 使用固定列表替代请求初始化，保留真实页面的滚动行为。
  @override
  // ignore: must_call_super
  void onInit() {
    refreshController = RefreshController();
    status = ResponseStatus.successHasContent;
    dataSource = List.generate(
      30,
      (index) => CoinRankDatas()
        ..rank = index + 1
        ..username = '测试用户$index'
        ..level = 10,
    );
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  for (final theme in ThemeType.values) {
    for (final isSettings in [true, false]) {
      final pageName = isSettings ? '主题设置' : '积分排名';
      testWidgets('$pageName 在 ${theme.name} 主题下滚动前后导航栏持续显示', (tester) async {
        // 缩短视口，让主题设置页也能实际滚动。
        tester.view.physicalSize = const Size(400, 280);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (isSettings) {
          Get.put(ThemeService());
        } else {
          Get.put<CoinRankController>(_RankController());
        }
        await tester.pumpWidget(GetCupertinoApp(
          theme: theme.theme,
          home: isSettings ? const ThemeSettingPage() : const CoinRankPage(),
        ));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        void expectVisibleBackground() {
          final bar = find.byType(CupertinoNavigationBar);
          final context = tester.element(bar);
          final expectedColor = CupertinoTheme.of(context).barBackgroundColor;
          final backgrounds = tester.widgetList<DecoratedBox>(
            find.descendant(of: bar, matching: find.byType(DecoratedBox)),
          );
          expect(
            backgrounds.any((box) =>
                box.decoration is BoxDecoration &&
                (box.decoration as BoxDecoration).color == expectedColor),
            isTrue,
            reason: '导航栏应一直使用当前主题的背景色',
          );
          final title =
              find.descendant(of: bar, matching: find.byType(Text)).first;
          final text = tester.widget<Text>(title);
          final color = text.style?.color ??
              DefaultTextStyle.of(tester.element(title)).style.color;
          expect(color, isNotNull);
          expect(color, isNot(expectedColor));
          expect(tester.takeException(), isNull);
        }

        expectVisibleBackground();
        final list = find.byType(Scrollable).hitTestable().first;
        await tester.drag(list, const Offset(0, -180));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        final position = tester.state<ScrollableState>(list).position;
        expect(position.pixels, greaterThan(0));
        expectVisibleBackground();
        // 回到顶部时避免触发下拉刷新和额外的数据请求。
        position.animateTo(
          position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(position.pixels, 0);
        expectVisibleBackground();
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
