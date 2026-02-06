import 'package:flutter/material.dart';

/// 页面过渡动画辅助类
///
/// 说明：此模块保留用于未来的自定义过渡动画扩展
/// 当前使用 GetX 内置的过渡动画类型
class PageTransitions {
  /// 缩放淡入过渡（可用于手动实现）
  static Widget zoomInTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// 从底部滑入过渡（可用于手动实现）
  static Widget bottomToTopTransition(
      Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// 滑动+淡入过渡（可用于手动实现）
  static Widget slideFadeTransition({
    required Widget child,
    required Animation<double> animation,
    bool beginFromRight = true,
  }) {
    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: beginFromRight ? const Offset(0.05, 0) : const Offset(-0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }
}

/// GetX 过渡动画参考
///
/// 在路由配置中可使用以下内置过渡：
/// - Transition.fadeIn       // 淡入
/// - Transition.rightToLeft  // 从右向左滑入（默认）
/// - Transition.leftToRight  // 从左向右滑入
/// - Transition.upToDown     // 从上向下滑入
/// - Transition.downToUp     // 从下向上滑入
/// - Transition.zoomIn       // 缩放淡入
/// - Transition.cupertino    // iOS 风格
/// - Transition.native       // 原生风格
///
/// 示例：
/// GetPage(
///   name: Routes.myPage,
///   page: () => MyPage(),
///   transition: Transition.rightToLeft,
///   transitionDuration: Duration(milliseconds: 300),
/// );
