import 'package:dio/dio.dart';

enum NetworkActivityChangeType { began, ended }

typedef ChangeTypeCallback = void Function(NetworkActivityChangeType change, RequestOptions options);

typedef OnRequestCallback = void Function(
    RequestOptions options, RequestInterceptorHandler handler);

typedef OnErrorCallback = void Function(
    DioError err, ErrorInterceptorHandler handler);

typedef OnResponseCallback = void Function(
    Response response, ResponseInterceptorHandler handler);

class NetworkActivityInterceptor extends Interceptor {
  late ChangeTypeCallback changeTypeCallback;

  OnRequestCallback? onRequestCallback;

  OnErrorCallback? onErrorCallback;

  OnResponseCallback? onResponseCallback;

  NetworkActivityInterceptor({
    required this.changeTypeCallback,
    this.onRequestCallback,
    this.onErrorCallback,
    this.onResponseCallback,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    changeTypeCallback(NetworkActivityChangeType.began, options);

    if (onRequestCallback != null) {
      onRequestCallback!(options, handler);
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    changeTypeCallback(NetworkActivityChangeType.ended, err.requestOptions);

    if (onErrorCallback != null) {
      onErrorCallback!(err, handler);
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    changeTypeCallback(NetworkActivityChangeType.ended, response.requestOptions);

    if (onResponseCallback != null) {
      onResponseCallback!(response, handler);
    }

    super.onResponse(response, handler);
  }
}
