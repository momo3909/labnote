import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class DotLayerPainter extends LayerPainterBase<DotLayerConfig> {
  const DotLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final spacing = mmToPx(config.spacingMm, scale);
    final radius = mmToPx(config.dotRadiusMm, scale);
    if (spacing <= 0 || radius <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final offsetX = (clip.width % spacing) / 2;
    final offsetY = (clip.height % spacing) / 2;

    for (double x = clip.left + offsetX; x <= clip.right + 0.5; x += spacing) {
      for (double y = clip.top + offsetY; y <= clip.bottom + 0.5; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }
}
