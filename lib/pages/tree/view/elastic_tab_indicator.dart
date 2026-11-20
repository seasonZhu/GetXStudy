import 'dart:math' as math;

import 'package:flutter/material.dart';

class ElasticTabIndicator extends Decoration {
  const ElasticTabIndicator({
    required this.controller,
    required this.color,
    required this.rebound,
  });

  final TabController controller;
  final Color color;
  final Animation<double> rebound;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ElasticTabPainter(controller, color, rebound, onChanged);
}

class _ElasticTabPainter extends BoxPainter {
  _ElasticTabPainter(
      this.controller, Color color, this.rebound, super.onChanged)
      : _paint = Paint()
          ..isAntiAlias = true
          ..color = color {
    if (onChanged != null) rebound.addListener(onChanged!);
  }

  final Animation<double> rebound;

  @override
  void dispose() {
    if (onChanged != null) rebound.removeListener(onChanged!);
    super.dispose();
  }

  final TabController controller;
  final Paint _paint;
  Rect? _lastRect;
  Rect? _correction;
  int? _lastTarget;
  bool _wasMoving = false;
  double _distanceAtRetarget = 0;

  Rect _trackRect(Rect rect, double distance) {
    final moving = controller.indexIsChanging && distance > 0;
    final previous = _lastRect;
    if (!moving) {
      _correction = null;
    } else if (_lastTarget != controller.index &&
        _wasMoving &&
        previous != null) {
      _distanceAtRetarget = distance;
      _correction = Rect.fromLTRB(
        previous.left - rect.left,
        previous.top - rect.top,
        previous.right - rect.right,
        previous.bottom - rect.bottom,
      );
    }
    final correction = _correction;
    if (correction != null) {
      final weight = (distance / _distanceAtRetarget).clamp(0.0, 1.0);
      rect = Rect.fromLTRB(
        rect.left + correction.left * weight,
        rect.top + correction.top * weight,
        rect.right + correction.right * weight,
        rect.bottom + correction.bottom * weight,
      );
    }
    _lastTarget = controller.index;
    _wasMoving = moving;
    return _lastRect = rect;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    final value = controller.animation?.value ?? controller.index.toDouble();
    final span = (controller.index - controller.previousIndex).abs();
    final distance = (value - controller.index).abs();
    final rect = _trackRect(offset & size, distance);
    if (rect.isEmpty) return;
    final progress = controller.indexIsChanging && span > 0
        ? (1 - distance / span).clamp(0.0, 1.0)
        : distance.clamp(0.0, 1.0);
    final stretch = math.sin(math.pi * progress);
    final bounce = math.sin(2 * math.pi * rebound.value) * (1 - rebound.value);
    final body = Rect.fromCenter(
      center: rect.center,
      width: rect.width * (1 - 0.14 * bounce),
      height: rect.height * (1 + 0.24 * bounce),
    );
    final radius = math.min(24.0, math.min(body.height, body.width) / 2);
    final shoulder = radius;
    final waist = body.height *
        0.36 *
        stretch *
        ((body.width - 2 * shoulder) / body.height).clamp(0.0, 1.0);

    final left = body.left + shoulder;
    final right = body.right - shoulder;
    final center = body.center.dx;
    final top = body.top;
    final bottom = body.bottom;
    final leftHandle = (left + center) / 2;
    final rightHandle = (right + center) / 2;
    final outline = Path()
      ..moveTo(left, top)
      ..cubicTo(leftHandle, top, leftHandle, top + waist, center, top + waist)
      ..cubicTo(rightHandle, top + waist, rightHandle, top, right, top)
      ..lineTo(body.right - radius, top)
      ..arcToPoint(Offset(body.right, top + radius),
          radius: Radius.circular(radius))
      ..lineTo(body.right, bottom - radius)
      ..arcToPoint(Offset(body.right - radius, bottom),
          radius: Radius.circular(radius))
      ..lineTo(right, bottom)
      ..cubicTo(rightHandle, bottom, rightHandle, bottom - waist, center,
          bottom - waist)
      ..cubicTo(leftHandle, bottom - waist, leftHandle, bottom, left, bottom)
      ..lineTo(body.left + radius, bottom)
      ..arcToPoint(Offset(body.left, bottom - radius),
          radius: Radius.circular(radius))
      ..lineTo(body.left, top + radius)
      ..arcToPoint(Offset(body.left + radius, top),
          radius: Radius.circular(radius))
      ..close();
    canvas.drawPath(outline, _paint);
  }
}
