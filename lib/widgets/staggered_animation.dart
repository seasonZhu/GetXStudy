import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 列表项交错入场动画
///
/// 使用场景：ListView、GridView 等列表的子项
/// 效果：列表项按顺序依次淡入并从下方滑入
class StaggeredListView extends StatefulWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final Duration staggerDelay;
  final Offset slideBeginOffset;
  final Curve curve;

  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.slideBeginOffset = const Offset(0, 0.3),
    this.curve = Curves.easeOut,
  });

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _StaggeredAnimationItem(
          index: index,
          duration: widget.duration,
          delay: Duration(milliseconds: widget.staggerDelay.inMilliseconds * index),
          slideBeginOffset: widget.slideBeginOffset,
          curve: widget.curve,
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}

/// 单个列表项的交错动画组件
class _StaggeredAnimationItem extends StatefulWidget {
  final int index;
  final Widget? child;
  final Duration duration;
  final Duration delay;
  final Offset slideBeginOffset;
  final Curve curve;

  const _StaggeredAnimationItem({
    required this.index,
    required this.child,
    required this.duration,
    required this.delay,
    required this.slideBeginOffset,
    required this.curve,
  });

  @override
  State<_StaggeredAnimationItem> createState() => _StaggeredAnimationItemState();
}

class _StaggeredAnimationItemState extends State<_StaggeredAnimationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideBeginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // 延迟启动动画
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Wrap 列表的交错动画版本
class StaggeredWrap extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Offset slideBeginOffset;
  final Curve curve;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;

  const StaggeredWrap({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.slideBeginOffset = const Offset(0, 0.3),
    this.curve = Curves.easeOut,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
  });

  @override
  State<StaggeredWrap> createState() => _StaggeredWrapState();
}

class _StaggeredWrapState extends State<StaggeredWrap> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: widget.alignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: List.generate(
        widget.children.length,
        (index) {
          return _StaggeredAnimationItem(
            index: index,
            duration: widget.duration,
            delay: Duration(
              milliseconds: widget.staggerDelay.inMilliseconds * index,
            ),
            slideBeginOffset: widget.slideBeginOffset,
            curve: widget.curve,
            child: widget.children[index],
          );
        },
      ),
    );
  }
}

/// Column 的交错动画版本
class StaggeredColumn extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Offset slideBeginOffset;
  final Curve curve;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.slideBeginOffset = const Offset(0, 0.3),
    this.curve = Curves.easeOut,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: List.generate(
        widget.children.length,
        (index) {
          return _StaggeredAnimationItem(
            index: index,
            duration: widget.duration,
            delay: Duration(
              milliseconds: widget.staggerDelay.inMilliseconds * index,
            ),
            slideBeginOffset: widget.slideBeginOffset,
            curve: widget.curve,
            child: widget.children[index],
          );
        },
      ),
    );
  }
}

/// 单个入场动画组件（可独立使用）
class StaggeredAnimationWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset slideBeginOffset;
  final Curve curve;

  const StaggeredAnimationWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.slideBeginOffset = const Offset(0, 0.3),
    this.curve = Curves.easeOut,
  });

  @override
  State<StaggeredAnimationWrapper> createState() =>
      _StaggeredAnimationWrapperState();
}

class _StaggeredAnimationWrapperState extends State<StaggeredAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideBeginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
