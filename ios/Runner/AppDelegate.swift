import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "com.getStudy.app/popIsEnable"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "sendMessage" {
                self?.handleMessage(call.arguments)
                result("Message received")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func handleMessage(_ message: Any?) {
        print(message)
        guard let dict = message as? [String: Bool],
              let canGoBack = dict["canGoBack"] else {
            return
        }
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        
        /// 这里其实有很本质的问题,那就是navigationController根本不存在,所以这个方法调用没有意义
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = !canGoBack
    }
}
