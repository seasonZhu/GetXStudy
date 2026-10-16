/// 调试日志配置，修改后对后续产生的日志生效。
abstract final class LogConfig {
  /// 是否隐藏 Cookie 和 Set-Cookie 的完整值，默认保留原文。
  static bool redactCookies = false;

  /// 是否隐藏密码、Token、Authorization 等其他敏感值，默认保留原文。
  static bool redactSensitiveData = false;
}
