import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/logger/log_error_handlers.dart';
import 'package:getx_study/logger/logger.dart';

void main() {
  test('框架和异步异常记录后仍调用原处理器，保留未处理返回值', () {
    final oldFlutter = FlutterError.onError;
    final oldPlatform = PlatformDispatcher.instance.onError;
    var flutterCalls = 0;
    var platformCalls = 0;
    FlutterError.onError = (_) => flutterCalls++;
    PlatformDispatcher.instance.onError = (error, stack) {
      platformCalls++;
      return false;
    };
    try {
      appTalker.cleanHistory();
      installLogErrorHandlers();
      installLogErrorHandlers();
      FlutterError.onError!(FlutterErrorDetails(exception: Exception('框架测试')));
      final handled = PlatformDispatcher.instance.onError!(
        Exception('异步测试'),
        StackTrace.fromString('测试堆栈'),
      );
      expect(flutterCalls, 1);
      expect(platformCalls, 1);
      expect(handled, isFalse);
      expect(appTalker.history.length, 2);
      final text = appTalker.history.map((e) => e.generateTextMessage()).join();
      expect(text, contains('Flutter 框架异常'));
      expect(text, contains('未处理的 Dart 异步异常'));
    } finally {
      FlutterError.onError = oldFlutter;
      PlatformDispatcher.instance.onError = oldPlatform;
    }
  });
}
