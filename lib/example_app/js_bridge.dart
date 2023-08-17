import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

typedef SubscribeCallback = void Function(dynamic value);

typedef ResponseCallback = void Function(
    dynamic value, Function(dynamic value) next);

/// 传输消息体
class BridgeMessage {
  static const String messageTypeRequest = 'request';

  static const String messageTypePublisher = 'publisher';

  String id = '';
  String type = '';
  String eventName = '';
  dynamic params;

  BridgeMessage({
    required this.id,
    required this.type,
    required this.eventName,
    required this.params,
  });

  BridgeMessage.fromJson(json) {
    id = json['id'] ?? '';
    type = json['type'];
    eventName = json['eventName'];
    params = json['params'];
  }

  dynamic toJson() {
    return {
      'id': id,
      'type': type,
      'eventName': eventName,
      'params': params,
    };
  }

  @override
  String toString() {
    return 'id=$id type=$type eventName=$eventName params=$params';
  }
}

// 注册响应句柄
class RegisterResponseHandle {
  final ResponseCallback registerResponseCallback; // 注册的回调
  final Function(BridgeMessage message) callback; // 中间触发的回调

  RegisterResponseHandle({
    required this.registerResponseCallback,
    required this.callback,
  });
}

class JSBridge {
  static const String nativeChannel = 'nativeChannel'; // 原生通信通道名称
  static const String javascriptChannel = 'javascriptChannel'; // js通信通道名称
  WebViewController? _controller;
  final Map<String, List<SubscribeCallback>> _subscribeCallbackMap = {};
  final Map<String, List<RegisterResponseHandle>> _registerResponseHandleMap = {};

  /// 设置WebViewController 必须
  void setWebViewController(WebViewController controller) {
    _controller = controller;
  }

  /// webView设置JavascriptChannel
  void addJavaScriptChannel() {
    _controller?.addJavaScriptChannel(nativeChannel,
        onMessageReceived: (javaScriptMessage) {
      BridgeMessage message =
          BridgeMessage.fromJson(jsonDecode(javaScriptMessage.message));
      if (message.type == BridgeMessage.messageTypePublisher) {
        // 处理订阅消息
        _subscribeCallbackMap[message.eventName]
            ?.forEach((callback) => callback(message.params));
      } else if (message.type == BridgeMessage.messageTypeRequest) {
        // 处理请求消息
        _registerResponseHandleMap[message.eventName]
            ?.forEach((element) => element.callback(message));
      }
    });
  }

  /// 发送消息
  Future<dynamic> postMessage(BridgeMessage bridgeMessage) async {
    String str = Uri.encodeComponent(json.encode(bridgeMessage.toJson()));
    List<int> content = utf8.encode(str);
    String data = base64Encode(content);
    try {
      return await _controller?.runJavaScriptReturningResult(
          """window['$javascriptChannel']('$data')""");
    } catch (e) {
      print('runJavascript error: $e');
    }
  }

  /// 注册响应
  void registerResponse(String eventName, ResponseCallback callback) {
    if (_registerResponseHandleMap[eventName] == null) {
      _registerResponseHandleMap[eventName] = [];
    }
    _registerResponseHandleMap[eventName]?.add(
      RegisterResponseHandle(
        callback: (BridgeMessage message) {
          callback(
            message.params,
            (dynamic params) => postMessage(
              BridgeMessage(
                id: message.id,
                type: message.type,
                eventName: message.eventName,
                params: {'code': 0, 'data': params}, // code == 0表示响应成功
              ),
            ),
          );
        },
        registerResponseCallback: callback,
      ),
    );
  }

  /// 注销响应
  void logoutResponse(String eventName, ResponseCallback callback) {
    List<RegisterResponseHandle>? registerResponseHandle =
        _registerResponseHandleMap[eventName];
    registerResponseHandle?.forEach(
      (item) {
        if (item.callback == callback) {
          registerResponseHandle.remove(item);
        }
      },
    );
  }

  /// 发布消息
  Future publisher(String eventName, dynamic params) async {
    await postMessage(BridgeMessage(
      id: '',
      type: BridgeMessage.messageTypePublisher,
      eventName: eventName,
      params: params,
    ));
  }

  /// 订阅消息，@return 取消订阅回调
  Function subscribe(String eventName, SubscribeCallback callback) {
    if (_subscribeCallbackMap[eventName] == null) {
      _subscribeCallbackMap[eventName] = [];
    }

    _subscribeCallbackMap[eventName]?.add(callback);
    return () => unsubscribe(eventName, callback);
  }

  /// 取消订阅
  void unsubscribe(String eventName, SubscribeCallback callback) {
    _subscribeCallbackMap[eventName]?.remove(callback);
  }
}
