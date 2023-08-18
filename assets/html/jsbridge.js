"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var MESSAGE_TYPE_REQUEST = 'request';
var MESSAGE_TYPE_PUBLISHER = 'publisher';
var NATIVE_CHANNEL = 'nativeChannel'; // 原生通信通道名称
var JAVASCRIPT_CHANNEL = 'javascriptChannel'; // js通信通道名称
var REQUEST_TIME_OUT = 20000;
var JSBridge = /** @class */ (function () {
    function JSBridge() {
        var _this = this;
        this.native = window[NATIVE_CHANNEL];
        this.subscribeCallbackMap = {};
        this.requestCallbackMap = {};
        // 请求响应
        this.request = function (eventName, params, timeout) {
            if (timeout === void 0) { timeout = REQUEST_TIME_OUT; }
            return new Promise(function (resolve) {
                var id = generateRandomString(36);
                var timer;
                _this.requestCallbackMap[id] = function (params) {
                    clearTimeout(timer);
                    delete _this.requestCallbackMap[id];
                    resolve(params);
                };
                timer = setTimeout(function () {
                    // code == -1表示响应超时
                    _this.requestCallbackMap[id] && _this.requestCallbackMap[id](JSON.stringify({ code: -1, data: '访问超时' }));
                }, timeout);
                _this.native &&
                    _this.native.postMessage(JSON.stringify({ type: 'request', id: id, eventName: eventName, params: params }));
            });
        };
        // 发布
        this.publisher = function (eventName, params) {
            _this.native && _this.native.postMessage(JSON.stringify({ type: 'publisher', eventName: eventName, params: params }));
        };
        // 订阅
        this.subscribe = function (eventName, callback) {
            if (!_this.subscribeCallbackMap[eventName]) {
                _this.subscribeCallbackMap[eventName] = [];
            }
            _this.subscribeCallbackMap[eventName].push(callback);
            return function () { return _this.unsubscribe(eventName, callback); };
        };
        // 取消订阅
        this.unsubscribe = function (eventName, callback) {
            var callbacks = _this.subscribeCallbackMap[eventName];
            if (callbacks) {
                callbacks.forEach(function (item, index) {
                    if (item === callback) {
                        callbacks.splice(index, 1);
                    }
                });
            }
        };
        window[JAVASCRIPT_CHANNEL] = function (jsonStr) {
            var message = JSON.parse(decodeURIComponent(atob(jsonStr)));
            var id = message.id;
            var type = message.type;
            var eventName = message.eventName;
            var params = message.params;
            if (type === MESSAGE_TYPE_REQUEST) {
                _this.requestCallbackMap[id] && _this.requestCallbackMap[id](params);
            }
            else if (type === MESSAGE_TYPE_PUBLISHER) {
                var callbacks = _this.subscribeCallbackMap[eventName];
                if (callbacks) {
                    callbacks.forEach(function (callback) { return callback(params); });
                }
            }
        };
    }
    return JSBridge;
}());
exports.default = JSBridge;
function generateRandomString(length) {
    return new Array(length)
        .fill(0)
        .map(function () { return Math.floor(Math.random() * 36).toString(36); })
        .join('')
        .toUpperCase();
}