import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';

class PolarLayerPainter extends LayerPainterBase<PolarLayerConfig> {
  const PolarLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final cx = (clip.left + clip.right) / 2;
    final cy = (clip.top + clip.bottom) / 2;
    final maxR = math.min(clip.width, clip.height) / 2;
    final ringStep = maxR / config.rings;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 同心円
    for (int i = 1; i <= config.rings; i++) {
      canvas.drawCircle(Offset(cx, cy), ringStep * i, paint);
    }

    // 放射線
    final outerR = ringStep * config.rings;
    for (int i = 0; i < config.sectors; i++) {
      final angle = 2 * math.pi * i / config.sectors;
      final dx = math.cos(angle) * outerR;
      final dy = math.sin(angle) * outerR;
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx, cy + dy), paint);
    }
  }
}
