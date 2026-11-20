import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/pages/common/info_cell.dart';

void main() {
  testWidgets('窄屏大字体下仍能显示标题和分享者并响应点击', (tester) async {
    final article = ArticleInfoDatas()
      ..title = List.filled(12, '文章长标题').join()
      ..author = '  '
      ..shareUser = '分享者'
      ..niceShareDate = '昨天';
    ArticleInfoDatas? selected;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(
              width: 180,
              child: InfoCell(
                model: article,
                callback: (value) => selected = value,
                isNeedBottomLine: false,
              ),
            ),
          ),
        ),
      ),
    ));
    expect(tester.widget<Text>(find.text(article.title!)).maxLines, 2);
    expect(find.text('分享者'), findsOneWidget);
    expect(find.text('昨天'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(article.title!));
    expect(selected, same(article));
  });

  testWidgets('没有元信息时只显示标题和默认分隔线', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfoCell(
          model: ArticleInfoDatas()..title = '标题',
          callback: (_) {},
        ),
      ),
    ));
    expect(find.text('标题'), findsOneWidget);
    expect(find.byType(Wrap), findsNothing);
    expect(find.byType(Divider), findsOneWidget);
  });
}
