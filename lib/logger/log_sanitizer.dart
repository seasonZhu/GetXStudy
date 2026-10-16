import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'log_config.dart';

bool _isCookieKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return normalized == 'cookie' || normalized == 'setcookie';
}

bool _isSensitiveKey(String key) {
  if (_isCookieKey(key)) return LogConfig.redactCookies;
  if (!LogConfig.redactSensitiveData) return false;
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return const {
    'password',
    'repassword',
    'passwd',
    'pwd',
    'token',
    'accesstoken',
    'refreshtoken',
    'authorization',
    'proxyauthorization',
    'secret',
    'apikey',
    'xapikey',
    'xauthtoken',
    'loginuserpassword',
    'sessionid',
  }.contains(normalized);
}

/// 按配置处理网址，默认完整保留；开启脱敏后网络详情保留普通参数。
String sanitizeLogUri(Uri uri, {bool hideAllQueryValues = true}) {
  if (!LogConfig.redactSensitiveData && !LogConfig.redactCookies) {
    return uri.toString();
  }
  final safe = uri.replace(
    userInfo: LogConfig.redactSensitiveData ? '' : null,
    queryParameters: uri.hasQuery
        ? {
            for (final entry in uri.queryParametersAll.entries)
              entry.key: (_isCookieKey(entry.key)
                      ? LogConfig.redactCookies
                      : (hideAllQueryValues && LogConfig.redactSensitiveData) ||
                          _isSensitiveKey(entry.key))
                  ? ['***']
                      : _isCookieKey(entry.key) && !LogConfig.redactCookies
                          ? entry.value
                          : entry.value.map(sanitizeLogText).toList(),
          }
        : null,
  );
  return (LogConfig.redactSensitiveData ? safe.removeFragment() : safe)
      .toString();
}

/// 为日志复制正文；上传文件和流只记录说明，不读取或消耗原始数据。
Object? sanitizeLogData(Object? data) {
  if (data is FormData) {
    return sanitizeLogData({
      for (final field in data.fields) field.key: field.value,
      for (final file in data.files)
        file.key: {'文件': file.value.filename, '字节数': file.value.length},
    });
  }
  if (data is Uint8List) {
    return '[二进制数据：${data.length} 字节]';
  }
  if (data is Stream) return '[流数据]';
  if (data is Map) {
    return {
      for (final entry in data.entries)
        entry.key.toString(): _isCookieKey(entry.key.toString()) &&
                !LogConfig.redactCookies
            ? (entry.value is List ? List.of(entry.value as List) : entry.value)
            : _isSensitiveKey(entry.key.toString())
                ? '***'
                : sanitizeLogData(entry.value),
    };
  }
  if (data is List) return data.map(sanitizeLogData).toList();
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map || decoded is List) return sanitizeLogData(decoded);
    } on FormatException {
      // 普通文本按字段与网址规则脱敏。
    }
    return sanitizeLogText(data);
  }
  if (data == null || data is num || data is bool) return data;
  return sanitizeLogText('$data');
}

final _urlPattern = RegExp(r'''[a-zA-Z][a-zA-Z0-9+.-]*://[^\s<>"']+''');
final _headerPattern = RegExp(
  r'''(["']?(?:authorization|cookie|set-cookie)["']?\s*[:=]\s*)[^\r\n]*''',
  caseSensitive: false,
);
final _cookiePattern = RegExp(
  r'''(["']?(?:cookie|set-cookie)["']?\s*[:=]\s*)[^\r\n]*''',
  caseSensitive: false,
);
final _secretPattern = RegExp(
  r'''(["']?(?:password|repassword|passwd|pwd|token|access_token|refresh_token|authorization|cookie|set-cookie|secret|api_key)["']?\s*[:=]\s*)(?:"[^"]*"|'[^']*'|[^\s,;&}\]]+)''',
  caseSensitive: false,
);

/// 业务消息与异常文本也经过同一脱敏入口。
String sanitizeLogText(String text) {
  if (!LogConfig.redactSensitiveData && !LogConfig.redactCookies) return text;
  // Cookie 原文可能包含 token/password 等字段，先保留完整值再处理其余文本。
  if (!LogConfig.redactCookies) {
    final result = StringBuffer();
    var offset = 0;
    for (final match in _cookiePattern.allMatches(text)) {
      result.write(_sanitizeLogText(text.substring(offset, match.start)));
      result.write(match[0]);
      offset = match.end;
    }
    result.write(_sanitizeLogText(text.substring(offset)));
    return result.toString();
  }
  return _sanitizeLogText(text);
}

String _sanitizeLogText(String text) {
  final urlsRemoved = text.replaceAllMapped(_urlPattern, (match) {
    final uri = Uri.tryParse(match[0]!);
    return uri == null ? '[无效网址]' : sanitizeLogUri(uri);
  });
  final headersRemoved = urlsRemoved.replaceAllMapped(
    LogConfig.redactSensitiveData ? _headerPattern : _cookiePattern,
    (match) => '${match[1]}***',
  );
  if (!LogConfig.redactSensitiveData) return headersRemoved;
  return headersRemoved.replaceAllMapped(
    _secretPattern,
    (match) => '${match[1]}***',
  );
}
