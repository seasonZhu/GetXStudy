import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_study/logger/log_route_observer.dart';
import 'package:getx_study/logger/log_config.dart';
import 'package:getx_study/logger/log_sanitizer.dart';
import 'package:getx_study/logger/logger.dart';
import 'package:getx_study/logger/network_log_interceptor.dart';
import 'package:talker_dio_logger/dio_logs.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter({this.fail = false, this.status = 200});

  final bool fail;
  final int status;
  RequestOptions? received;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    received = options;
    if (fail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'Authorization: Bearer message-secret',
        error: '原始错误正文',
      );
    }
    return ResponseBody.fromString(
      jsonEncode({'secret': 'response-secret', 'title': '示例文章'}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'set-cookie': ['response-cookie'],
        'x-request-id': ['trace-123'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Talker talker;

  setUp(() {
    LogConfig.redactCookies = true;
    LogConfig.redactSensitiveData = true;
    talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    appTalker.configure(
        settings: TalkerSettings(useConsoleLogs: false, maxHistoryItems: 300));
    appTalker.cleanHistory();
  });

  tearDown(() {
    LogConfig.redactCookies = false;
    LogConfig.redactSensitiveData = false;
  });

  test('全部脱敏关闭时原文可见，两项开关可独立启用', () {
    const input = {
      'Cookie': 'token=cookie-value',
      'Authorization': 'Bearer auth-value',
      'password': 'password-value',
      'nested': {'accessToken': 'token-value'},
    };
    LogConfig.redactSensitiveData = false;
    LogConfig.redactCookies = false;
    expect(sanitizeLogData(input), input);
    const text = 'Authorization: Bearer auth-value';
    expect(sanitizeLogText(text), text);
    final uri =
        Uri.parse('https://user:pass@example.com/?token=token-value#value');
    expect(sanitizeLogUri(uri), uri.toString());
    LogConfig.redactCookies = true;
    final cookieOnly = sanitizeLogData(input) as Map;
    expect(cookieOnly['Cookie'], '***');
    expect(cookieOnly['password'], 'password-value');
    expect(sanitizeLogText(text), text);
    expect(sanitizeLogText('Cookie: token=cookie-value'), 'Cookie: ***');
    LogConfig.redactCookies = false;
    LogConfig.redactSensitiveData = true;
    final sensitiveOnly = sanitizeLogData(input) as Map;
    expect(sensitiveOnly['Cookie'], 'token=cookie-value');
    expect(sensitiveOnly['Authorization'], '***');
    expect(sensitiveOnly['password'], '***');
    expect(sensitiveOnly['nested'], {'accessToken': '***'});
  });

  test('Cookie 默认配置关闭脱敏，可在请求与成功及错误响应间切换', () async {
    // 其他用例显式开启脱敏，本例覆盖默认值及动态切换。
    LogConfig.redactCookies = false;
    for (final redact in [false, true]) {
      LogConfig.redactCookies = redact;
      for (final status in [200, 400]) {
        talker.cleanHistory();
        final adapter = _Adapter(status: status);
        final dio = Dio()..httpClientAdapter = adapter;
        dio.interceptors.add(NetworkLogInterceptor(talker: talker));
        const cookie = 'token=cookie-token; loginUserPassword=cookie-password';
        try {
          await dio.post('https://example.com/login',
              data: {'password': 'body-secret'},
              options: Options(headers: {
                'cOoKiE': cookie,
                'Authorization': 'Bearer auth-secret',
              }));
        } on DioException {
          expect(status, 400);
        }
        final text = talker.history.map((e) => e.generateTextMessage()).join();
        expect(text.contains(cookie), !redact);
        expect(text.contains('response-cookie'), !redact);
        expect(text, isNot(contains('auth-secret')));
        expect(text, isNot(contains('body-secret')));
        expect(adapter.received!.headers['cOoKiE'], cookie);
        dio.close();
      }
    }
  });

  test('Cookie 文本按配置保留原文或整体遮盖，其他字段继续脱敏', () {
    const cookie = 'Cookie: token=visible; password=visible-password';
    LogConfig.redactCookies = false;
    expect(sanitizeLogText(cookie), cookie);
    expect(
        sanitizeLogData({
          'Set-Cookie': ['token=visible']
        }),
        {
          'Set-Cookie': ['token=visible']
        });
    LogConfig.redactCookies = true;
    expect(sanitizeLogText(cookie), 'Cookie: ***');
    expect(
        sanitizeLogData({
          'Set-Cookie': ['token=visible']
        }),
        {'Set-Cookie': '***'});
  });

  test('网址移除凭据、片段及全部查询值，业务字段脱敏', () {
    final url = sanitizeLogUri(Uri.parse(
        'https://user:pass@example.com/login?password=secret&next=nested#token'));
    expect(url, contains('example.com/login'));
    for (final value in ['user', 'pass@', 'secret', 'nested', '#token']) {
      expect(url, isNot(contains(value)));
    }
    expect(sanitizeLogText('{"password":"secret", token: abc}'),
        isNot(contains('secret')));
    expect(sanitizeLogText('token: abc'), isNot(contains('abc')));
    expect(sanitizeLogText('Authorization: Bearer header-secret'),
        isNot(contains('header-secret')));
    expect(sanitizeLogText('Cookie: a=one; b=two'), isNot(contains('two')));
  });

  test('网络日志仅持有脱敏副本，保留请求和响应的原有内容', () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(NetworkLogInterceptor(talker: talker));
    final response = await dio.post(
      'https://example.com/login?password=query-secret',
      data: {'password': 'body-secret'},
      options: Options(headers: {'Cookie': 'header-secret'}),
    );

    expect(adapter.received!.uri.queryParameters['password'], 'query-secret');
    expect(adapter.received!.headers['Cookie'], 'header-secret');
    expect(adapter.received!.data, {'password': 'body-secret'});
    expect(response.data, {'secret': 'response-secret', 'title': '示例文章'});
    expect(response.headers.value('set-cookie'), 'response-cookie');
    final requestLog = talker.history.whereType<DioRequestLog>().single;
    final responseLog = talker.history.whereType<DioResponseLog>().single;
    expect(requestLog.requestOptions.data, {'password': '***'});
    expect(requestLog.requestOptions.headers['Cookie'], '***');
    expect(responseLog.response.headers.value('set-cookie'), '***');
    expect(responseLog.response.data, {'secret': '***', 'title': '示例文章'});
    expect(responseLog.responseTime, greaterThanOrEqualTo(0));
    final exported = talker.history.map((e) => e.generateTextMessage()).join();
    expect(exported, contains('Status: 200'));
    expect(exported, contains('POST'));
    for (final value in [
      'query-secret',
      'body-secret',
      'header-secret',
      'response-secret',
      'response-cookie',
    ]) {
      expect(exported, isNot(contains(value)));
    }
    dio.close();
  });

  test('详细网络日志在控制台及历史中包含普通查询参数和请求响应正文', () async {
    final output = <String>[];
    final detailedTalker = Talker(
      logger: TalkerLogger(output: output.add),
      settings: TalkerSettings(useConsoleLogs: true),
    );
    final dio = Dio()..httpClientAdapter = _Adapter();
    dio.interceptors.add(NetworkLogInterceptor(talker: detailedTalker));
    await dio.post(
      'https://example.com/article?page=2&password=query-secret',
      data: {'articleId': 42, 'password': 'body-secret'},
      options: Options(headers: {
        'Accept': 'application/json',
        'aUtHoRiZaTiOn': 'Bearer auth-secret',
        'X-Api-Key': 'api-secret',
      }),
    );
    final history = detailedTalker.history
        .map((entry) => entry.generateTextMessage())
        .join();
    for (final text in [history, output.join()]) {
      expect(text, contains('page=2'));
      expect(text, contains('articleId'));
      expect(text, contains('42'));
      expect(text, contains('Data:'));
      expect(text, contains('示例文章'));
      expect(text, contains('Headers:'));
      expect(text, contains('application/json'));
      expect(text, contains('trace-123'));
      expect(text, isNot(contains('body-secret')));
      expect(text, isNot(contains('query-secret')));
      expect(text, isNot(contains('auth-secret')));
      expect(text, isNot(contains('api-secret')));
      expect(text, isNot(contains('response-cookie')));
    }
    dio.close();
  });

  test('错误响应同样保留脱敏后的详细正文', () async {
    final dio = Dio()..httpClientAdapter = _Adapter(status: 400);
    dio.interceptors.add(NetworkLogInterceptor(talker: talker));
    await expectLater(
        dio.get('https://example.com/article'), throwsA(isA<DioException>()));
    final log = talker.history.whereType<DioErrorLog>().single;
    final text = log.generateTextMessage();
    expect(text, contains('400'));
    expect(text, contains('示例文章'));
    expect(text, contains('trace-123'));
    expect(text, isNot(contains('response-cookie')));
    expect(text, isNot(contains('response-secret')));
    dio.close();
  });

  test('嵌套正文与表单副本脱敏且保留普通字段，不消耗上传数据', () {
    final source = {
      'items': [
        {'accessToken': 'nested-secret', 'name': '文章'}
      ],
      'pages': [1, 2],
    };
    final copy = sanitizeLogData(source);
    expect(copy, {
      'items': [
        {'accessToken': '***', 'name': '文章'}
      ],
      'pages': [1, 2],
    });
    expect((source['items'] as List).first['accessToken'], 'nested-secret');
    final form = FormData.fromMap({
      'password': 'form-secret',
      'name': '文章',
      'file': MultipartFile.fromBytes([1, 2, 3], filename: 'demo.txt'),
    });
    final formCopy = sanitizeLogData(form) as Map;
    expect(formCopy['password'], '***');
    expect(formCopy['name'], '文章');
    expect(formCopy['file'], {'文件': 'demo.txt', '字节数': 3});
    expect(form.isFinalized, isFalse);
    expect(form.fields.first.value, 'form-secret');
  });

  test('统一日志实际通过 Flutter 控制台输出', () {
    final previousPrint = debugPrint;
    final output = <String>[];
    debugPrint = (message, {wrapWidth}) => output.add(message ?? '');
    try {
      appTalker.configure(settings: TalkerSettings(useConsoleLogs: true));
      logger.d('控制台测试事件');
      expect(output.join(), contains('控制台测试事件'));
    } finally {
      debugPrint = previousPrint;
    }
  });

  test('失败请求保留原异常，日志包含脱敏错误摘要及耗时', () async {
    final dio = Dio()..httpClientAdapter = _Adapter(fail: true);
    dio.interceptors.add(NetworkLogInterceptor(talker: talker));
    await expectLater(
      dio.get('https://example.com/login?token=query-secret'),
      throwsA(isA<DioException>().having(
        (e) => e.message,
        '原异常',
        contains('message-secret'),
      )),
    );
    final log = talker.history.whereType<DioErrorLog>().single;
    expect(log.dioException.error, isNull);
    expect(log.responseTime, greaterThanOrEqualTo(0));
    final exported = log.generateTextMessage();
    expect(exported, contains('connectionError'));
    expect(exported, isNot(contains('query-secret')));
    expect(exported, isNot(contains('message-secret')));
    dio.close();
  });

  test('业务日志记录异常上下文并限制历史数量', () {
    final entry = AppLogger(talker);
    entry.e(
        Exception('password=secret'), StackTrace.fromString('测试堆栈'), '测试异常');
    expect(talker.history.single.generateTextMessage(), contains('测试异常'));
    expect(
        talker.history.single.generateTextMessage(), isNot(contains('secret')));
    for (var i = 0; i < 305; i++) {
      logger.d('事件 $i');
    }
    expect(appTalker.history.length, 300);
    expect(appTalker.history.last.message, '事件 304');
  });

  test('路由进出不记录路由参数，查询值脱敏', () {
    final route = MaterialPageRoute<void>(
      settings: const RouteSettings(
        name: '/login?password=route-secret',
        arguments: {'token': 'argument-secret'},
      ),
      builder: (_) => const SizedBox(),
    );
    final observer = LogRouteObserver();
    observer.didPush(route, null);
    observer.didPop(route, null);
    final exported =
        appTalker.history.map((e) => e.generateTextMessage()).join();
    expect(exported, contains('进入'));
    expect(exported, contains('退出'));
    expect(exported, isNot(contains('route-secret')));
    expect(exported, isNot(contains('argument-secret')));
  });
}
