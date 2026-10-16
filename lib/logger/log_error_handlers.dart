import 'package:flutter/foundation.dart';

import 'logger.dart';

bool _installed = false;

/// 追加异常记录，并保持原有处理器及系统默认报错行为。
void installLogErrorHandlers() {
  if (!kDebugMode || _installed) return;
  _installed = true;
  final previousFlutterHandler = FlutterError.onError;
  final previousPlatformHandler = PlatformDispatcher.instance.onError;

  FlutterError.onError = (details) {
    logger.e(details.exception, details.stack, 'Flutter 框架异常');
    if (previousFlutterHandler != null) {
      previousFlutterHandler(details);
    } else {
      FlutterError.presentError(details);
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e(error, stack, '未处理的 Dart 异步异常');
    return previousPlatformHandler?.call(error, stack) ?? false;
  };
}
