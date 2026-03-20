import UIKit
import Flutter

/// AppDelegate向SceneDelegate迁移文档 https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "com.getStudy.app/popIsEnable"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: FlutterImplicitEngineDelegate {
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        // Create method channels with `engineBridge.applicationRegistrar.messenger()`
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: engineBridge.applicationRegistrar.messenger())
        channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "sendMessage" {
                self?.handleMessage(call.arguments)
                result("Message received")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

extension AppDelegate {
    private func handleMessage(_ message: Any?) {
        guard let dict = message as? [String: Bool],
              let canGoBack = dict["canGoBack"] else {
            return
        }
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = !canGoBack
    }
}
