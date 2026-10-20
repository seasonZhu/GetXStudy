import 'package:getx_study/base/base_refresh_controller.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/entity/page_entity.dart';
import 'package:getx_study/enum/scroll_view_action_type.dart';

/// 普通列表共用分页事务，子类仅提供目标页的取数方式。
abstract class BasePagedListController<R extends IRepository, T>
    extends BaseRefreshController<R, T> {
  Future<BaseEntity<PageEntity<List<T>>>> fetchPage(int page);

  @override
  Future<void> onRefresh() => aRequest(type: ScrollViewActionType.refresh);

  @override
  Future<void> onLoadMore() => aRequest(type: ScrollViewActionType.loadMore);

  @override
  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {
    if (isLoading || isClosed) return;
    isLoading = true;
    final targetPage =
        type == ScrollViewActionType.refresh ? initPage : page + 1;
    try {
      final result = await fetchPage(targetPage);
      if (isClosed) return;
      if (!result.isSuccess) {
        failHandle(type);
        return;
      }
      response = result;
      page = targetPage;
      final models = result.data?.dataSource ?? [];
      if (type == ScrollViewActionType.refresh) {
        dataSource = List.of(models);
      } else {
        dataSource.addAll(models);
      }
      checkDataSourceAndStatus();
      refreshControllerStatusUpdate(type);
    } catch (_) {
      if (!isClosed) failHandle(type);
    } finally {
      isLoading = false;
      if (!isClosed) update();
    }
  }
}
