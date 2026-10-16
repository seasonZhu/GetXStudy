import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/dio_logs.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'log_sanitizer.dart';
import 'logger.dart';

/// Talker 的日志对象只持有脱敏副本，原始网络数据继续交给业务处理。
class NetworkLogInterceptor extends Interceptor {
  NetworkLogInterceptor({Talker? talker}) : _talker = talker ?? appTalker;

  final Talker _talker;
  final _timers = Expando<Stopwatch>();
  static const _settings = TalkerDioLoggerSettings(
    printRequestData: true,
    printRequestHeaders: true,
    printResponseData: true,
    printResponseHeaders: true,
    printResponseMessage: true,
    printErrorData: true,
    printErrorHeaders: true,
    printErrorMessage: true,
    printResponseTime: true,
  );

  RequestOptions _snapshot(RequestOptions options) {
    final elapsed = _timers[options]?.elapsedMilliseconds ?? 0;
    return RequestOptions(
      path: sanitizeLogUri(options.uri, hideAllQueryValues: false),
      method: options.method,
      data: sanitizeLogData(options.data),
      headers: sanitizeLogData(options.headers) as Map<String, dynamic>,
      extra: {
        TalkerDioLogger.kDioLogsTimeStampKey:
            DateTime.now().millisecondsSinceEpoch - elapsed,
      },
    );
  }

  Headers _responseHeaders(Headers headers) {
    final safe = sanitizeLogData(headers.map) as Map<String, dynamic>;
    return Headers.fromMap(safe.map((key, value) => MapEntry(
          key,
          value is List ? value.map((item) => '$item').toList() : ['$value'],
        )));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _timers[options] = Stopwatch()..start();
      final snapshot = _snapshot(options);
      _talker.logCustom(DioRequestLog(
        snapshot.path,
        requestOptions: snapshot,
        settings: _settings,
      ));
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final snapshot = _snapshot(response.requestOptions);
      _talker.logCustom(DioResponseLog(
        snapshot.path,
        response: Response(
          requestOptions: snapshot,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage == null
              ? null
              : sanitizeLogText(response.statusMessage!),
          data: sanitizeLogData(response.data),
          headers: _responseHeaders(response.headers),
        ),
        settings: _settings,
      ));
      _timers[response.requestOptions] = null;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final snapshot = _snapshot(err.requestOptions);
      _talker.logCustom(DioErrorLog(
        snapshot.path,
        dioException: DioException(
          requestOptions: snapshot,
          type: err.type,
          message: sanitizeLogText('${err.type.name}: ${err.message ?? ''}'),
          response: err.response == null
              ? null
              : Response(
                  requestOptions: snapshot,
                  statusCode: err.response?.statusCode,
                  data: sanitizeLogData(err.response?.data),
                  headers: _responseHeaders(err.response!.headers),
                ),
        ),
        settings: _settings,
      ));
      _timers[err.requestOptions] = null;
    }
    handler.next(err);
  }
}
