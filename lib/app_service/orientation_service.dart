import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 屏幕方向服务
///
/// 提供全局屏幕方向管理功能，支持：
/// - 竖屏模式
/// - 横屏模式
/// - 自适应模式（竖屏 + 横屏）
/// - 监听屏幕方向变化
///
/// 使用方式：
/// ```dart
/// // 在需要锁屏的页面
/// OrientationService.find.enablePortraitOnly();
///
/// // 在需要横屏的页面
/// OrientationService.find.enableLandscapeOnly();
///
/// // 在需要自适应的页面（如 WebView）
/// OrientationService.find.enableAutoRotation();
///
/// // 页面退出时恢复默认
/// OrientationService.find.resetToDefault();
/// ```
class OrientationService extends GetxService with WidgetsBindingObserver {
  static OrientationService get find => Get.find<OrientationService>();

  /// 当前屏幕方向模式
  final rxOrientationMode = OrientationMode.portrait.obs;

  /// 屏幕方向变化回调
  void Function(Orientation orientation)? onOrientationChanged;

  @override
  void onInit() {
    super.onInit();
    // 注册生命周期监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    super.onClose();
    // 移除监听
    WidgetsBinding.instance.removeObserver(this);
    // 恢复默认竖屏
    resetToDefault();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 页面恢复时重新应用方向设置
    if (state == AppLifecycleState.resumed) {
      _applyCurrentMode();
    }
  }

  /// 启用竖屏模式
  void enablePortraitOnly() {
    rxOrientationMode.value = OrientationMode.portrait;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 启用横屏模式
  void enableLandscapeOnly() {
    rxOrientationMode.value = OrientationMode.landscape;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 启用横屏模式（仅左侧）
  void enableLandscapeLeftOnly() {
    rxOrientationMode.value = OrientationMode.landscape;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 启用横屏模式（仅右侧）
  void enableLandscapeRightOnly() {
    rxOrientationMode.value = OrientationMode.landscape;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 启用自适应模式（竖屏 + 横屏）
  void enableAutoRotation() {
    rxOrientationMode.value = OrientationMode.auto;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 恢复默认竖屏模式
  void resetToDefault() {
    rxOrientationMode.value = OrientationMode.portrait;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 应用当前模式
  void _applyCurrentMode() {
    switch (rxOrientationMode.value) {
      case OrientationMode.portrait:
        enablePortraitOnly();
        break;
      case OrientationMode.landscape:
        enableLandscapeOnly();
        break;
      case OrientationMode.auto:
        enableAutoRotation();
        break;
    }
  }

  /// 获取当前方向
  Orientation? get currentOrientation {
    final size = Get.context?.mediaQuery.size;
    if (size == null) return null;
    return size.width > size.height
        ? Orientation.landscape
        : Orientation.portrait;
  }

  /// 是否是横屏
  bool get isLandscape => currentOrientation == Orientation.landscape;

  /// 是否是竖屏
  bool get isPortrait => currentOrientation == Orientation.portrait;
}

/// 屏幕方向模式
enum OrientationMode {
  /// 竖屏
  portrait,

  /// 横屏
  landscape,

  /// 自适应
  auto,
}
