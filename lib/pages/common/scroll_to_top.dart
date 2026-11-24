import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getx_study/i18n/app_text.dart';

class ScrollToTop extends StatefulWidget {
  const ScrollToTop({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  static bool supports(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android;
  }

  @override
  State<ScrollToTop> createState() => _ScrollToTopState();
}

class _ScrollToTopState extends State<ScrollToTop> {
  ScrollableState? _scrollable;
  bool _visible = false;
  bool _updateScheduled = false;

  void _track(int depth, ScrollMetrics metrics, BuildContext? source) {
    if (depth != 0 || metrics.axis != Axis.vertical || source == null) return;
    _scrollable = Scrollable.maybeOf(source);
    if (_updateScheduled) return;
    _updateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      if (!mounted) return;
      final scrollable = _scrollable;
      final position =
          scrollable != null && scrollable.mounted ? scrollable.position : null;
      final visible = position != null &&
          position.hasContentDimensions &&
          position.hasViewportDimension &&
          position.extentBefore > position.viewportDimension;
      if (_visible != visible) setState(() => _visible = visible);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _scrollToTop() {
    final scrollable = _scrollable;
    if (scrollable == null || !scrollable.mounted) return;
    final position = scrollable.position;
    if (MediaQuery.disableAnimationsOf(context)) {
      position.jumpTo(position.minScrollExtent);
    } else {
      position.animateTo(
        position.minScrollExtent,
        duration: Duration(
          milliseconds: 250 +
              (50 * (position.extentBefore / position.viewportDimension - 1))
                  .clamp(0, 200)
                  .round(),
        ),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ScrollToTop.supports(context)) {
      return widget.child;
    }
    return Stack(
      fit: StackFit.passthrough,
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            _track(
                notification.depth, notification.metrics, notification.context);
            return false;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _track(notification.depth, notification.metrics,
                  notification.context);
              return false;
            },
            child: widget.child,
          ),
        ),
        if (widget.enabled && _visible)
          ScrollToTopButton(onPressed: _scrollToTop),
      ],
    );
  }
}

class ScrollToTopButton extends StatelessWidget {
  const ScrollToTopButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final color = CupertinoDynamicColor.resolve(theme.primaryColor, context);
    return Positioned(
      right: 16,
      bottom: 16,
      child: SafeArea(
        left: false,
        top: false,
        child: FloatingActionButton.small(
          heroTag: null,
          backgroundColor: dark
              ? const Color(0xFFE5E5EA)
              : Color.lerp(color, Colors.black, 0.42),
          foregroundColor: dark ? const Color(0xFF1C1C1E) : Colors.white,
          tooltip: AppText.t('common.scroll_to_top'),
          onPressed: onPressed,
          child: const Icon(Icons.arrow_upward),
        ),
      ),
    );
  }
}
