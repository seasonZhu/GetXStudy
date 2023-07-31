import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dio/dio.dart';

import 'package:getx_study/http_util/network_activity_plugin.dart';
import 'package:getx_study/resource/constant.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api.dart';

/// 白名单
const kWhiteList = [
  Api.postLogin,
  Api.postRegister,
  Api.getLogout,
  Api.postCollectArticle,
  Api.postUnCollectArticle,
];

/// 网络请求日志插件
final loggerPlugin = PrettyDioLogger(
  requestHeader: false,
  requestBody: true,
  responseBody: true,
  responseHeader: false,
  compact: false,
);

/// 网络请求loading与dismiss插件
final networkActivityPlugin = NetworkActivityPlugin(
  networkActivityCallback: (change, options) {
    final result =
        kWhiteList.where((element) => options.path.contains(element));
    if (result.isNotEmpty) {
      switch (change) {
        case NetworkActivityChangeType.began:
          EasyLoading.show(
            indicator: const CupertinoActivityIndicator(
              color: Colors.white,
              radius: 15,
            ),
            maskType: EasyLoadingMaskType.none,
            dismissOnTap: false,
          );
          break;
        case NetworkActivityChangeType.ended:
          EasyLoading.dismiss();
          break;
      }
    }
  },
);

/// 网络请求拦截器
final responseInterceptorPlugin = InterceptorsWrapper(
  onError: (error, handler) {
    /// 在这里对DioError进行加工
    handler.next(error);
  },
  onRequest: (options, handler) {
    /// 在这里对Request进行加工
    handler.next(options);
  },
  onResponse: (response, handler) {
    /// 通过请求配置做拦截
    final requestOptions = response.requestOptions;
    requestOptions.path;

    /// 通过响应做拦截
    Map<String, dynamic> json = response.data;
    int code = json[Constant.errorCode];
    String message = json[Constant.errorMsg];

    if (code == 0) {
      /// 0正常业务码
    } else {
      EasyLoading.showToast(message);
    }
    handler.next(response);
  },
);