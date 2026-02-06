import 'package:flutter/material.dart';

/// 带缩放效果的按钮组件
///
/// 使用场景：所有需要点击反馈的按钮
/// 效果：按下时缩小到 0.95 倍，松开时恢复
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleDown;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 100),
    this.scaleDown = 0.95,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 带缩放效果的 TextButton
class AnimatedTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration duration;
  final double scaleDown;

  const AnimatedTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.duration = const Duration(milliseconds: 100),
    this.scaleDown = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onPressed: onPressed,
      duration: duration,
      scaleDown: scaleDown,
      child: TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// 带缩放效果的 ElevatedButton
class AnimatedElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration duration;
  final double scaleDown;

  const AnimatedElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.duration = const Duration(milliseconds: 100),
    this.scaleDown = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onPressed: onPressed,
      duration: duration,
      scaleDown: scaleDown,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// 带缩放效果的 OutlinedButton
class AnimatedOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration duration;
  final double scaleDown;

  const AnimatedOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.duration = const Duration(milliseconds: 100),
    this.scaleDown = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onPressed: onPressed,
      duration: duration,
      scaleDown: scaleDown,
      child: OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// 带缩放效果的 IconButton
class AnimatedIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double? iconSize;
  final Duration duration;
  final double scaleDown;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize,
    this.duration = const Duration(milliseconds: 100),
    this.scaleDown = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onPressed: onPressed,
      duration: duration,
      scaleDown: scaleDown,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: iconSize,
      ),
    );
  }
}

/// 带缩放效果的 InkWell（用于卡片、列表项等）
class AnimatedInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Duration duration;
  final double scaleDown;

  const AnimatedInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 100),
    this.scaleDown = 0.97,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onPressed: onTap,
      duration: duration,
      scaleDown: scaleDown,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
