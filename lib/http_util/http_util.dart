import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

import 'api.dart';
import 'http_status.dart' as season;
import 'plugins.dart';
import 'package:getx_study/app_service/account_service.dart';

/// 这个是用来判断是否是生产环境
const bool inProduction = bool.fromEnvironment("dart.vm.product");

abstract class HttpUtils {
  // 超时时间 1min dio中是以毫秒计算的
  static const timeout = Duration(seconds: 60);

  HttpUtils._();

  // 缓存配置
  static final _cacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
    priority: CachePriority.high,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  static final _dio = Dio(
    BaseOptions(
      baseUrl: Api.baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {},
    ),
  )..addPlugins;

  // Get请求
  static Future<Map<String, dynamic>> get(
      {required String api,
      Map<String, dynamic> params = const {},
      Map<String, dynamic> headers = const {},
      bool enableCache = false}) async {
    getCookieHeaderOptions().headers?.addAll(headers);

    final options = getCookieHeaderOptions();
    if (enableCache && !inProduction) {
      options.extra = _cacheOptions.toExtra();
    }

    try {
      Response response = await _dio.get(
        api,
        queryParameters: params,
        options: options,
      );
      Map<String, dynamic> json = response.data;
      return json;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Post请求
  static Future<Map<String, dynamic>> post(
      {required String api,
      Map<String, dynamic> params = const {},
      Map<String, dynamic> headers = const {}}) async {
    getCookieHeaderOptions().headers?.addAll(headers);

    /// 这个地方必须用queryParameters,用data传入就报错了
    /// 这个地方其实是玩安卓的API比较奇葩,一般post请求,参数都是放到request的body中,而它的还是拼接到网址后面
    try {
      Response response = await _dio.post(
        api,
        queryParameters: params,
        options: getCookieHeaderOptions(),
      );
      Map<String, dynamic> json = response.data;
      return json;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Options getCookieHeaderOptions() {
    final value = AccountService.find.cookieHeaderValue;
    Options options = Options(headers: {HttpHeaders.cookieHeader: value});
    return options;
  }

  /// 统一处理Dio错误
  static dynamic _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw '网络连接超时，请检查网络设置';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          throw '登录已过期，请重新登录';
        } else if (statusCode == 403) {
          throw '没有权限访问';
        } else if (statusCode == 404) {
          throw '请求的资源不存在';
        } else if (statusCode! >= 500) {
          throw '服务器错误，请稍后重试';
        }
        throw '请求失败: $statusCode';
      case DioExceptionType.cancel:
        throw '请求已取消';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          throw '网络连接失败，请检查网络设置';
        }
        throw '未知错误: ${error.message}';
      default:
        throw '网络请求失败';
    }
  }

  Future<Response<T>> request<T>(String api,
      {required HTTPMethod method,
      dynamic data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic> headers = const {}}) async {
    try {
      Response response = await _dio.request(
        api,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers, method: method.string),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}

extension Plugins on Dio {
  Dio get addPlugins {
    interceptors.addAll([
      loggerPlugin,
      networkActivityPlugin,
      responseInterceptorPlugin,
    ]);
    return this;
  }

  Dio get addNativeAdapter {
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      httpClientAdapter = NativeAdapter();
    }
    return this;
  }
}

enum HTTPMethod {
  get("GET"),
  post("POST"),
  delete("DELETE"),
  put("PUT"),
  patch("PATCH"),
  head("HEAD");

  final String string;

  const HTTPMethod(this.string);
}

extension EnumStatus on Response {
  season.HttpStatus get status =>
      season.HttpStatus.mappingTable[statusCode] ??
      season.HttpStatus.connectionError;
}
