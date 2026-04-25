import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class GuideLayerPainter extends LayerPainterBase<GuideLayerConfig> {
  const GuideLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    switch (config.guideType) {
      case GuideType.axis:
        _paintAxis(canvas, clip);
      case GuideType.bondAngle60:
        _paintAngles(canvas, clip, const [0, 60, 120]);
      case GuideType.bondAngle109:
        _paintAngles(canvas, clip, const [0, 109.47, 229.47, 349.47]);
      case GuideType.bondAngle120:
        _paintAngles(canvas, clip, const [90, 210, 330]);
      case GuideType.scale:
        _paintScale(canvas, clip, scale);
    }
  }

  Paint _makePaint() => Paint()
    ..color = color.withValues(alpha: opacity)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  void _paintAxis(Canvas canvas, Rect clip) {
    final p = _makePaint();
    final cx = (clip.left + clip.right) / 2;
    final cy = (clip.top + clip.bottom) / 2;
    canvas.drawLine(Offset(cx, clip.top), Offset(cx, clip.bottom), p);
    canvas.drawLine(Offset(clip.left, cy), Offset(clip.right, cy), p);
  }

  void _paintAngles(Canvas canvas, Rect clip, List<double> degList) {
    final p = _makePaint();
    final cx = (clip.left + clip.right) / 2;
    final cy = (clip.top + clip.bottom) / 2;
    final r = math.sqrt(clip.width * clip.width + clip.height * clip.height);
    for (final deg in degList) {
      final rad = deg * math.pi / 180;
      final dx = math.cos(rad) * r;
      final dy = math.sin(rad) * r;
      canvas.drawLine(Offset(cx - dx, cy - dy), Offset(cx + dx, cy + dy), p);
    }
  }

  void _paintScale(Canvas canvas, Rect clip, double scale) {
    final p = _makePaint();
    final intervalPx = mmToPx(10.0, scale);
    final y = clip.bottom - mmToPx(3.0, scale);
    final tickH = mmToPx(2.5, scale);
    final halfH = tickH / 2;

    canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), p);
    int tick = 0;
    for (double x = clip.left; x <= clip.right + 0.5; x += intervalPx) {
      final h = tick % 5 == 0 ? tickH : halfH;
      canvas.drawLine(Offset(x, y - h), Offset(x, y), p);
      tick++;
    }
  }
}
