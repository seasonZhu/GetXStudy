package com.example.getx_study

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "getx_study/build_info")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "buildNumber" -> result.success(getString(R.string.display_build_number))
                    else -> result.notImplemented()
                }
            }
    }
}
