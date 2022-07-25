import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api.dart';

// 这个是用来判断是否是生产环境
const bool inProduction = bool.fromEnvironment("dart.vm.product");

abstract class HttpUtils {
  // 超时时间 1min dio中是以毫秒计算的
  static var timeout = 60000000;

  HttpUtils._();

  static final _dio = Dio(
    BaseOptions(
      baseUrl: Api.baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {},
    ),
  ).addPrettyPrint;

  // Get请求
  static Future<Map<String, dynamic>> get({
    required String api, 
    Map<String, dynamic> params = const {},
    Map<String, dynamic> headers = const {}
    }) async {
    getCookieHeaderOptions().headers?.addAll(headers);
    Response response = await _dio.get(api,
        queryParameters: params, options: getCookieHeaderOptions());
    Map<String, dynamic> json = response.data;
    return json;
  }

  // Post请求
  static Future<Map<String, dynamic>> post({
    required String api, 
    Map<String, dynamic> params = const {},
    Map<String, dynamic> headers = const {}
    }) async {
    getCookieHeaderOptions().headers?.addAll(headers);

    /// 这个地方必须用queryParameters,用data传入就报错了
    Response response = await _dio.post(api,
        queryParameters: params, options: getCookieHeaderOptions());
    Map<String, dynamic> json = response.data;
    return json;
  }

  static Options getCookieHeaderOptions() {
    var value = {}; //AccountManager.getInstance().cookieHeaderValue;
    Options options = Options(headers: {HttpHeaders.cookieHeader: value});
    return options;
  }
}

extension AddPrettyPrint on Dio {
  Dio get addPrettyPrint {
    interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ),
    );
    return this;
  }
}
