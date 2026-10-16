import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/logger/log_config.dart';

void main() {
  test('所有脱敏配置默认关闭', () {
    expect(LogConfig.redactCookies, isFalse);
    expect(LogConfig.redactSensitiveData, isFalse);
  });
}
