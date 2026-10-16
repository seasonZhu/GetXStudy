import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'log_sanitizer.dart';

/// 本次运行共用的调试日志，Profile 和 Release 均关闭。
final appTalker = TalkerFlutter.init(
  // 使用 Flutter 控制台输出，保持原有网络日志在终端和 Xcode 中的可见性。
  logger: TalkerLogger(output: (message) => debugPrint(message)),
  settings: TalkerSettings(
    enabled: kDebugMode,
    useConsoleLogs: kDebugMode,
    useHistory: kDebugMode,
    maxHistoryItems: 300,
  ),
);

final logger = AppLogger(appTalker);

/// 保留旧入口，统一汇入同一份日志历史。
final loggerNoStack = logger;

class AppLogger {
  AppLogger(this._talker);

  final Talker _talker;

  void d(Object? message) {
    if (kDebugMode) _talker.debug(sanitizeLogText('$message'));
  }

  void i(Object? message) {
    if (kDebugMode) _talker.info(sanitizeLogText('$message'));
  }

  void w(Object? message) {
    if (kDebugMode) _talker.warning(sanitizeLogText('$message'));
  }

  void e(Object error, [StackTrace? stackTrace, String? message]) {
    if (!kDebugMode) return;
    // DioException 持有原始请求和响应，仅记录类型摘要。
    final summary = error is DioException ? error.type.name : '$error';
    _talker.handle(
      Exception(sanitizeLogText(summary)),
      stackTrace == null
          ? null
          : StackTrace.fromString(sanitizeLogText('$stackTrace')),
      message == null ? null : sanitizeLogText(message),
    );
  }
}
