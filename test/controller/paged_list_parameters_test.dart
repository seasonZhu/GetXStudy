import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/coin_rank_entity.dart';
import 'package:getx_study/entity/my_coin_history_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/tag_type.dart';
import 'package:getx_study/pages/coin_rank/controller/coin_rank_controller.dart';
import 'package:getx_study/pages/coin_rank/repository/coin_rank_repository.dart';
import 'package:getx_study/pages/home/controller/search_result_controller.dart';
import 'package:getx_study/pages/home/repository/search_result_repository.dart';
import 'package:getx_study/pages/my/controller/my_coin_history_controller.dart';
import 'package:getx_study/pages/my/repository/my_coin_history_repository.dart';
import 'package:getx_study/pages/tree/controller/tab_list_controller.dart';
import 'package:getx_study/pages/tree/controller/tree_list_controller.dart';
import 'package:getx_study/pages/tree/repository/tab_list_repository.dart';
import 'package:getx_study/pages/tree/repository/tree_list_repository.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _Articles = BaseEntity<PageEntity<List<ArticleInfoDatas>>>;

class _Search extends SearchResultRepository {
  final calls = <(int, String)>[];
  @override
  Future<_Articles> searchKeyword(
      {required int page, required String keyword}) async {
    calls.add((page, keyword));
    return BaseEntity(0, '', null);
  }
}

class _Tabs extends TabListRepository {
  final calls = <(int, String, TagType)>[];
  @override
  Future<_Articles> getList(
      {required int page, required String id, required TagType tagType}) async {
    calls.add((page, id, tagType));
    return BaseEntity(0, '', null);
  }
}

class _Tree extends TreeListRepository {
  final calls = <(int, String)>[];
  @override
  Future<_Articles> getTreeArticleList(
      {required int page, required String id}) async {
    calls.add((page, id));
    return BaseEntity(0, '', null);
  }
}

class _Rank extends CoinRankRepository {
  final pages = <int>[];
  @override
  Future<BaseEntity<PageEntity<List<CoinRankDatas>>>> getCoinRankList(
      int page) async {
    pages.add(page);
    return BaseEntity(0, '', null);
  }
}

class _History extends MyCoinHistoryRepository {
  final pages = <int>[];
  @override
  Future<BaseEntity<PageEntity<List<MyCoinHistoryDatas>>>> getCoinRankList(
      int page) async {
    pages.add(page);
    return BaseEntity(0, '', null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());

  test('搜索刷新和加载始终传递原关键词与目标页', () async {
    final repository = _Search();
    final controller = SearchResultController()
      ..request = repository
      ..keyword = 'Flutter 状态'
      ..initPage = 1
      ..page = 5
      ..refreshController = RefreshController();
    addTearDown(controller.refreshController.dispose);
    await controller.onRefresh();
    await controller.onLoadMore();
    expect(repository.calls, [(1, 'Flutter 状态'), (2, 'Flutter 状态')]);
  });

  for (final type in TagType.values) {
    test('分类 $type 保留类型、ID 与起始页', () async {
      final repository = _Tabs();
      final controller = TabListController()
        ..request = repository
        ..tagType = type
        ..id = '123'
        ..initPage = type.pageNum
        ..page = 5
        ..refreshController = RefreshController();
      addTearDown(() => controller.onDelete());
      await controller.onRefresh();
      await controller.onLoadMore();
      expect(repository.calls,
          [(type.pageNum, '123', type), (type.pageNum + 1, '123', type)]);
    });
  }

  test('体系文章保留体系 ID，刷新从零开始', () async {
    final repository = _Tree();
    final controller = TreeListController()
      ..request = repository
      ..treeId = '456'
      ..initPage = 0
      ..page = 5
      ..refreshController = RefreshController();
    addTearDown(controller.refreshController.dispose);
    await controller.onRefresh();
    await controller.onLoadMore();
    expect(repository.calls, [(0, '456'), (1, '456')]);
  });

  test('积分排行刷新从一开始，加载传递下一页', () async {
    final repository = _Rank();
    final controller = CoinRankController()
      ..request = repository
      ..initPage = 1
      ..page = 5
      ..refreshController = RefreshController();
    addTearDown(controller.refreshController.dispose);
    await controller.onRefresh();
    await controller.onLoadMore();
    expect(repository.pages, [1, 2]);
  });

  test('积分记录刷新从一开始，加载传递下一页', () async {
    final repository = _History();
    final controller = MyCoinHistoryController()
      ..request = repository
      ..initPage = 1
      ..page = 5
      ..refreshController = RefreshController();
    addTearDown(controller.refreshController.dispose);
    await controller.onRefresh();
    await controller.onLoadMore();
    expect(repository.pages, [1, 2]);
  });
}
