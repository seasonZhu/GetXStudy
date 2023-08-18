export type SubscribeCallback = (params?: any) => void;
 
const MESSAGE_TYPE_REQUEST = 'request';
const MESSAGE_TYPE_PUBLISHER = 'publisher';
const NATIVE_CHANNEL = 'nativeChannel'; // 原生通信通道名称
const JAVASCRIPT_CHANNEL = 'javascriptChannel'; // js通信通道名称
const REQUEST_TIME_OUT = 20000;
 
interface BridgeMessage {
  id: string;
  type: string;
  eventName: string;
  params: any;
}
 
class JSBridge {
  private native: any = window[NATIVE_CHANNEL];
  private subscribeCallbackMap = {};
  private requestCallbackMap = {};
 
  constructor() {
    window[JAVASCRIPT_CHANNEL] = (jsonStr) => {
      const message = JSON.parse(decodeURIComponent(atob(jsonStr))) as BridgeMessage;
      const id = message.id;
      const type = message.type;
      const eventName = message.eventName;
      const params = message.params;
      if (type === MESSAGE_TYPE_REQUEST) {
        this.requestCallbackMap[id] && this.requestCallbackMap[id](params);
      } else if (type === MESSAGE_TYPE_PUBLISHER) {
        const callbacks = this.subscribeCallbackMap[eventName];
        if (callbacks) {
          callbacks.forEach((callback) => callback(params));
        }
      }
    };
  }
 
  // 请求响应
  request = (eventName: string, params: any, timeout = REQUEST_TIME_OUT): Promise<any> => {
    return new Promise((resolve: any) => {
      const id: string = generateRandomString(36);
      let timer;
      this.requestCallbackMap[id] = (params) => {
        clearTimeout(timer);
        delete this.requestCallbackMap[id];
        resolve(params);
      };
 
      timer = setTimeout(() => {
        // code == -1表示响应超时
        this.requestCallbackMap[id] && this.requestCallbackMap[id](JSON.stringify({ code: -1, data: '访问超时' }));
      }, timeout);
 
      this.native &&
        this.native.postMessage(JSON.stringify({ type: 'request', id: id, eventName: eventName, params: params }));
    });
  };
 
  // 发布
  publisher = (eventName: string, params: any): void => {
    this.native && this.native.postMessage(JSON.stringify({ type: 'publisher', eventName: eventName, params: params }));
  };
 
  // 订阅
  subscribe = (eventName: string, callback: SubscribeCallback): SubscribeCallback => {
    if (!this.subscribeCallbackMap[eventName]) {
      this.subscribeCallbackMap[eventName] = [];
    }
    this.subscribeCallbackMap[eventName].push(callback);
    return () => this.unsubscribe(eventName, callback);
  };
 
  // 取消订阅
  unsubscribe = (eventName: string, callback: SubscribeCallback): void => {
    const callbacks = this.subscribeCallbackMap[eventName];
    if (callbacks) {
      callbacks.forEach((item, index) => {
        if (item === callback) {
          callbacks.splice(index, 1);
        }
      });
    }
  };
}
 
export default JSBridge;

function generateRandomString(length:number): string {
  return new Array(length)
    .fill(0)
    .map(() => Math.floor(Math.random() * 36).toString(36))
    .join('')
    .toUpperCase();
}

/**
import React, { useEffect } from 'react';
import { Button } from 'antd';
import JSBridge from '@common/JSBridge';
import './index.less';
 
// 1、创建JSBridge对象
const jsBridge = new JSBridge();
 
function Test() {
  useEffect(() => {
     // 2、订阅消息：“test”
    const unsubscribe = jsBridge.subscribe('test', (params) => {
      console.info('web收到一条订阅消息：eventName=test, params=', params);
    });
 
    return () => {
      // 3、取消订阅消息：“test”
      unsubscribe();
    };
  });
 
  return (
    <div styleName="container">
      <div styleName="add-button">
        <Button
          type="primary"
          onClick={() => {
            // 4、发布订阅消息：“test”。native端订阅test消息，请参考上面原生端代码
            jsBridge.publisher('test', { data: '这是H5端发布消息' });
          }}
        >
          发布消息
        </Button>
      </div>
      <div styleName="delete-button">
        <Button
          type="primary"
          onClick={async () => {
            // 5、发送请求消息：“/test”，异步接收响应数据。native端注册响应消息，请参考上面原生端代码
            const res = await jsBridge.request('/test', { data: '这是H5端请求消息' });
            console.info('web收到一条响应消息：eventName=/test, res=', res.data);
          }}
        >
          请求消息
        </Button>
      </div>
    </div>
  );
}
 
export default Test;

作者：SugarTurboS
链接：https://juejin.cn/post/7156901434489831461
来源：稀土掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
 */