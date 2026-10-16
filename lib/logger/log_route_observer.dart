import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'log_sanitizer.dart';
import 'logger.dart';

final logRouteObserver = LogRouteObserver();

/// 仅记录页面名称，不保留路由参数和页面对象。
class LogRouteObserver extends NavigatorObserver {
  void _record(String action, Route<dynamic>? route) {
    if (!kDebugMode || route is! PageRoute) return;
    final uri = Uri.tryParse(route.settings.name ?? '未命名页面');
    final name = uri == null ? '未命名页面' : sanitizeLogUri(uri);
    appTalker.logCustom(TalkerLog('$action $name', key: TalkerKey.route));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('进入', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('退出', route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('移除', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _record('退出', oldRoute);
    _record('进入', newRoute);
  }
}
