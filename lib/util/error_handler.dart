import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// 统一的异常处理工具类
class ErrorHandler {
  ErrorHandler._();

  /// 处理Dio异常并显示提示
  static void handleDioError(dynamic error, {String? defaultMsg}) {
    String msg;

    if (error is DioException) {
      msg = _getDioErrorMessage(error);
    } else if (error is Exception) {
      msg = error.toString().replaceAll('Exception: ', '');
    } else {
      msg = defaultMsg ?? '发生未知错误';
    }

    // 显示错误提示
    _showError(msg);
  }

  /// 获取Dio错误消息
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.badResponse:
        return _getResponseErrorMessage(error);
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return '网络连接失败，请检查网络设置';
        }
        return '网络请求失败';
    }
  }

  /// 获取响应错误消息
  static String _getResponseErrorMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // 尝试从响应数据中提取错误信息
    if (data is Map<String, dynamic>) {
      final errorMsg = data['errorMsg'] ?? data['message'] ?? data['error'];
      if (errorMsg is String) {
        return errorMsg;
      }
    }

    // 根据状态码返回错误信息
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '登录已过期，请重新登录';
      case 403:
        return '没有权限访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败: $statusCode';
    }
  }

  /// 显示错误提示
  static void _showError(String message) {
    // 避免重复显示相同的错误
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    EasyLoading.showError(message, duration: const Duration(seconds: 2));
  }

  /// 显示Toast提示
  static void showToast(String message) {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    EasyLoading.showToast(message);
  }

  /// 显示成功提示
  static void showSuccess(String message) {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    EasyLoading.showSuccess(message);
  }

  /// 处理异步操作的异常
  static Future<T?> tryCatch<T>(
    Future<T> Function() operation, {
    String? errorMsg,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (showError) {
        handleDioError(e, defaultMsg: errorMsg);
      }
      return null;
    }
  }
}
