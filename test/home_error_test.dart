import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/base/class_name.dart';
import 'package:getx_study/pages/my/controller/my_controller.dart';
import 'package:getx_study/pages/my/repository/my_repository.dart';
import 'package:getx_study/entity/banner_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/response_status.dart';
import 'package:getx_study/http_util/plugins.dart';
import 'package:getx_study/pages/common/empty_view.dart';
import 'package:getx_study/pages/common/error_view.dart';
import 'package:getx_study/pages/common/loading_view.dart';
import 'package:getx_study/pages/home/controller/home_controller.dart';
import 'package:getx_study/pages/home/repository/home_repository.dart';
import 'package:getx_study/pages/home/view/home_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _Page = BaseEntity<PageEntity<List<ArticleInfoDatas>>>;

ArticleInfoDatas _article(int id) => ArticleInfoDatas()
  ..id = id
  ..title = '文章$id'
  ..envelopePic = '';

_Page _page(int current, List<int> ids) => BaseEntity(
    0,
    '',
    PageEntity<List<ArticleInfoDatas>>.fromJson({})
      ..curPage = current
      ..pageCount = 10
      ..dataSource = ids.map(_article).toList());

class _Repository extends HomeRepository {
  final pages = <int>[];
  final articles = <Completer<_Page>>[];
  final banners = <Completer<BaseEntity<List<BannerEntity>>>>[];
  final tops = <Completer<BaseEntity<List<ArticleInfoDatas>>>>[];

  @override
  Future<_Page> getArticleList({required int page}) {
    pages.add(page);
    final result = Completer<_Page>();
    articles.add(result);
    return result.future;
  }

  @override
  Future<BaseEntity<List<BannerEntity>>> getBanner() {
    final result = Completer<BaseEntity<List<BannerEntity>>>();
    banners.add(result);
    return result.future;
  }

  @override
  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList() {
    final result = Completer<BaseEntity<List<ArticleInfoDatas>>>();
    tops.add(result);
    return result.future;
  }

  void succeed(
      {List<int> articleIds = const [1], List<int> topIds = const []}) {
    articles.last.complete(_page(pages.last, articleIds));
    banners.last.complete(BaseEntity(0, '', []));
    tops.last.complete(BaseEntity(0, '', topIds.map(_article).toList()));
  }

  void fail() {
    articles.last.completeError(Exception('文章断网'));
    banners.last.complete(BaseEntity(-1, '横幅业务失败', null));
    tops.last.completeError(Exception('置顶超时'));
  }
}

class _MyController extends MyController {
  @override
  Future<void> autoLogin() async {}
}

void main() {
  late _Repository repository;
  late HomeController controller;
  late int toastCount;

  Future<void> mount(WidgetTester tester,
      {bool showPage = true, bool initialRefresh = false}) async {
    repository = _Repository();
    Get.put(AccountService());
    Get.put<MyRepository>(MyRepository());
    Get.put<MyController>(_MyController());
    Get.put<HomeRepository>(repository);
    Get.put<int>(0, tag: className(HomeController));
    Get.put<RefreshController>(
        RefreshController(initialRefresh: initialRefresh),
        tag: className(HomeController));
    controller = Get.put(HomeController());
    toastCount = 0;
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.show) toastCount++;
    });
    await tester.pumpWidget(GetMaterialApp(
      builder: EasyLoading.init(),
      home: showPage ? const HomePage() : const Scaffold(),
    ));
  }

  Future<void> render(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await EasyLoading.dismiss(animation: false);
    await tester.pumpWidget(const SizedBox());
  }

  setUp(() => Get.testMode = true);
  tearDown(() {
    EasyLoading.dismiss(animation: false);
    EasyLoading.removeAllCallbacks();
    Get.reset();
  });

  testWidgets('首屏自动请求保持挂载，全失败仅一个错误页，重试三个接口各一次', (tester) async {
    await mount(tester, initialRefresh: true);
    await tester.pump(const Duration(seconds: 1));
    expect(repository.pages, [0]);
    expect(repository.banners, hasLength(1));
    expect(repository.tops, hasLength(1));
    expect(find.byType(LoadingView), findsOneWidget);
    repository.fail();
    await render(tester);
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.textContaining('加载失败，点击重试'), findsNothing);
    expect(find.byType(SmartRefresher), findsOneWidget);
    expect(toastCount, 0);

    await tester.tap(find.text('重试'));
    await render(tester);
    expect(repository.pages, [0, 0]);
    expect(repository.banners, hasLength(2));
    expect(repository.tops, hasLength(2));
    repository.succeed();
    await render(tester);
    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('文章1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('首次部分成功渐进展示，其余失败仅一次吐司', (tester) async {
    await mount(tester);
    final loading = controller.onRefresh();
    repository.articles.single.complete(_page(0, [1]));
    await render(tester);
    expect(find.text('文章1'), findsOneWidget);
    expect(controller.isLoading, isTrue);
    repository.banners.single.completeError('失败');
    repository.tops.single.complete(BaseEntity(-1, '失败', null));
    await loading;
    await render(tester);
    expect(controller.status, ResponseStatus.successHasContent);
    expect(find.byType(ErrorView), findsNothing);
    expect(find.textContaining('点击重试'), findsNothing);
    expect(find.text('加载失败，请重试'), findsOneWidget);
    expect(toastCount, 1);
    await finish(tester);
  });

  testWidgets('已有内容刷新全部失败，保留原渲染且只提示一次', (tester) async {
    await mount(tester);
    final first = controller.onRefresh();
    repository.succeed(topIds: [9]);
    await first;
    await render(tester);
    final oldData = List.of(controller.dataSource);
    final refresh = controller.onRefresh();
    repository.fail();
    await refresh;
    await render(tester);
    expect(controller.dataSource, orderedEquals(oldData));
    expect(controller.page, 0);
    expect(find.text('文章1'), findsOneWidget);
    expect(find.text('文章9'), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);
    expect(find.textContaining('点击重试'), findsNothing);
    expect(toastCount, 1);
    await finish(tester);
  });

  testWidgets('刷新部分失败保留旧分块，成功分块更新', (tester) async {
    await mount(tester, showPage: false);
    final first = controller.onRefresh();
    repository.articles.last.complete(_page(0, [1]));
    repository.banners.last.complete(BaseEntity(0, '', [BannerEntity()]));
    repository.tops.last.complete(BaseEntity(0, '', [_article(9)]));
    await first;
    final oldBanner = controller.banners.single;
    final refresh = controller.onRefresh();
    repository.articles.last.complete(_page(0, [2]));
    repository.banners.last.completeError('失败');
    repository.tops.last.complete(BaseEntity(-1, '失败', null));
    await refresh;
    await render(tester);
    expect(controller.banners.single, same(oldBanner));
    expect(controller.dataSource.map((item) => item.id), [9, 2]);
    expect(toastCount, 1);
    await finish(tester);
  });

  testWidgets('仅横幅成功也保留内容，不显示整页错误', (tester) async {
    await mount(tester, showPage: false);
    final first = controller.onRefresh();
    repository.articles.last.completeError('失败');
    repository.banners.last.complete(BaseEntity(0, '', [BannerEntity()]));
    repository.tops.last.completeError('失败');
    await first;
    await render(tester);
    expect(controller.hasContent, isTrue);
    expect(controller.status, ResponseStatus.successHasContent);
    expect(toastCount, 1);
    await finish(tester);
  });

  testWidgets('分页失败保留数据页码，重试仍为同一页且不加载横幅置顶', (tester) async {
    await mount(tester);
    final first = controller.onRefresh();
    repository.succeed();
    await first;
    await render(tester);
    final failed = controller.onLoadMore();
    repository.articles.last.completeError('断网');
    await failed;
    await render(tester);
    expect(controller.page, 0);
    expect(controller.dataSource.single.id, 1);
    expect(find.text('加载失败，请上拉重试'), findsNothing);
    expect(toastCount, 1);
    final retry = controller.onLoadMore();
    repository.articles.last.complete(_page(1, [2]));
    await retry;
    expect(repository.pages, [0, 1, 1]);
    expect(repository.banners, hasLength(1));
    expect(repository.tops, hasLength(1));
    expect(controller.dataSource.map((item) => item.id), [1, 2]);
    await finish(tester);
  });

  testWidgets('全部成功但为空仅显示空态', (tester) async {
    await mount(tester);
    final first = controller.onRefresh();
    repository.succeed(articleIds: []);
    await first;
    await render(tester);
    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);
    expect(toastCount, 0);
    await finish(tester);
  });

  testWidgets('关闭后忽略结果并不弹吐司', (tester) async {
    await mount(tester, showPage: false);
    final first = controller.onRefresh();
    controller.onDelete();
    repository.articles.last.complete(_page(0, [1]));
    repository.banners.last.complete(BaseEntity(0, '', [BannerEntity()]));
    repository.tops.last.completeError('置顶失败');
    await first;
    await render(tester);
    expect(controller.dataSource, isEmpty);
    expect(controller.banners, isEmpty);
    expect(toastCount, 0);
    await finish(tester);
  });

  testWidgets('全局业务错误吐司默认开启，首页可单独关闭', (tester) async {
    await mount(tester, showPage: false);
    Response<dynamic> response({bool? showToast}) => Response(
          requestOptions: RequestOptions(path: '/test', extra: {
            if (showToast != null) 'showBusinessErrorToast': showToast,
          }),
          data: {'errorCode': -1, 'errorMsg': '业务失败'},
        );
    responseInterceptorPlugin.onResponse(
        response(showToast: false), ResponseInterceptorHandler());
    await render(tester);
    expect(toastCount, 0);
    responseInterceptorPlugin.onResponse(
        response(), ResponseInterceptorHandler());
    await render(tester);
    expect(toastCount, 1);
    expect(find.text('业务失败'), findsOneWidget);
    await finish(tester);
  });
}
