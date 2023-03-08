import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getx_study/http_util/network_activity_interceptor.dart';
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
final networkActivityPlugin = NetworkActivityInterceptor(
  changeTypeCallback: (change, options) {
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
