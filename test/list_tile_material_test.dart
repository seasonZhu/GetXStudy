import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/app_service/theme_service.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/my_coin_history_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';
import 'package:getx_study/pages/coin_rank/view/coin_rank_page.dart';
import 'package:getx_study/pages/my/controller/my_coin_history_controller.dart';
import 'package:getx_study/pages/my/view/my_coin_history_page.dart';
import 'package:getx_study/pages/my/view/theme_setting_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 仅替换依赖初始化，使用实际页面与列表数据，避免测试发起网络请求。
class _HistoryController extends MyCoinHistoryController {
  // 测试使用固定数据，刻意跳过基类的仓库查找与请求依赖初始化。
  @override
  // ignore: must_call_super
  void onInit() {
    refreshController = RefreshController();
    status = ResponseStatus.successHasContent;
    dataSource = [
      MyCoinHistoryDatas()
        ..reason = '签到'
        ..desc = '每日签到积分'
        ..coinCount = 10,
    ];
  }
}

class _RankController extends CoinRankController {
  // 测试使用固定数据，刻意跳过基类的仓库查找与请求依赖初始化。
  @override
  // ignore: must_call_super
  void onInit() {
    refreshController = RefreshController();
    status = ResponseStatus.successHasContent;
    dataSource = [
      CoinRankDatas()
        ..rank = 1
        ..username = '测试用户'
        ..level = 10,
    ];
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  for (final brightness in Brightness.values) {
    for (final page in ['我的积分', '积分排名', '主题设置']) {
      testWidgets('$page 在 ${brightness.name} 主题下无 ListTile 背景异常', (tester) async {
        late Widget home;
        switch (page) {
          case '我的积分':
            Get.put<MyCoinHistoryController>(_HistoryController());
            home = const MyCoinHistoryPage();
          case '积分排名':
            Get.put<CoinRankController>(_RankController());
            home = const CoinRankPage();
          default:
            Get.put(ThemeService());
            home = const ThemeSettingPage();
        }
        await tester.pumpWidget(GetCupertinoApp(
          theme: CupertinoThemeData(brightness: brightness),
          home: Material(child: home),
        ));
        await tester.pump();
        expect(find.byType(ListTile), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
