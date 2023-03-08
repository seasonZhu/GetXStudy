import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getx_study/http_util/network_activity_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api.dart';

/// 白名单
const kWhiteList = [Api.postLogin, Api.postRegister];

final loggerPlugin = PrettyDioLogger(
  requestHeader: false,
  requestBody: true,
  responseBody: true,
  responseHeader: false,
  compact: false,
);

final networkActivityPlugin = NetworkActivityInterceptor(
  changeTypeCallback: (change, options) {
    print("path: ${options.path}");
    if (kWhiteList.contains(options.path)) {
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
