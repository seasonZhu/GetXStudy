import 'dart:async';

import 'package:get/get.dart';
import 'package:getx_study/app_service/account_service.dart';
import 'package:getx_study/repository/collection_repository.dart';

enum CollectionResultType {
  success,
  failure,
  duplicate,
  staleSession,
  notLoggedIn
}

class CollectionResult {
  const CollectionResult(this.type, {this.message});

  final CollectionResultType type;
  final String? message;
}

class CollectionChange {
  const CollectionChange(
      {this.articleId, this.collected, this.sessionChanged = false});

  /// 空 ID 表示会话或请求中状态变化。
  final int? articleId;
  final bool? collected;
  final bool sessionChanged;
}

/// 收藏命令及提交规则由应用持有，页面关闭不终止已发出的命令。
class CollectionService extends GetxService {
  CollectionService(this.account, this.repository);

  final AccountService account;
  final CollectionRepository repository;
  final _changes = StreamController<CollectionChange>.broadcast(sync: true);
  final _pending = <(int, int)>{};
  StreamSubscription<int>? _sessionSubscription;

  Stream<CollectionChange> get changes => _changes.stream;

  @override
  void onInit() {
    super.onInit();
    _sessionSubscription = account.sessionChanges.listen((_) {
      _changes.add(const CollectionChange(sessionChanged: true));
    });
  }

  bool isCollected(int articleId) =>
      account.isLogin &&
      (account.info?.collectIds?.contains(articleId) ?? false);

  bool isPending(int articleId) =>
      _pending.contains((account.sessionRevision, articleId));

  Future<CollectionResult> setCollected(int articleId, bool collected) async {
    final info = account.info;
    if (!account.isLogin || info == null) {
      return const CollectionResult(CollectionResultType.notLoggedIn);
    }
    final revision = account.sessionRevision;
    final key = (revision, articleId);
    if (!_pending.add(key)) {
      return const CollectionResult(CollectionResultType.duplicate);
    }
    bool isCurrent() =>
        !isClosed &&
        account.isLogin &&
        account.sessionRevision == revision &&
        identical(account.info, info);
    _changes.add(const CollectionChange());
    try {
      final result = await repository.setCollected(articleId, collected);
      if (!isCurrent()) {
        return const CollectionResult(CollectionResultType.staleSession);
      }
      if (!result.isSuccess) {
        return CollectionResult(CollectionResultType.failure,
            message: result.errorMsg);
      }
      final ids = info.collectIds ??= [];
      ids.removeWhere((id) => id == articleId);
      if (collected) ids.add(articleId);
      _changes
          .add(CollectionChange(articleId: articleId, collected: collected));
      return const CollectionResult(CollectionResultType.success);
    } catch (_) {
      return CollectionResult(
        isCurrent()
            ? CollectionResultType.failure
            : CollectionResultType.staleSession,
        message: '操作失败，请重试',
      );
    } finally {
      _pending.remove(key);
      if (!isClosed) _changes.add(const CollectionChange());
    }
  }

  @override
  void onClose() {
    _sessionSubscription?.cancel();
    _changes.close();
    super.onClose();
  }
}
