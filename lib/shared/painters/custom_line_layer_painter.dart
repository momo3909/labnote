import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class CustomLineLayerPainter extends LayerPainterBase<CustomLineLayerConfig> {
  const CustomLineLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  void _drawSubLines(Canvas canvas, LineSet set, double spacing, double scale,
      double mainPos, Rect clip, {required bool horizontal}) {
    if (set.subLines.isEmpty || spacing <= 0) return;
    for (final sub in set.subLines) {
      final ratio = sub.positionRatio.clamp(0.01, 0.99);
      final subOffset = spacing * ratio;
      final subStroke = mmToPx(sub.strokeWidthMm.clamp(0.05, 2.0), scale);
      final subPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.6)
        ..strokeWidth = subStroke
        ..style = PaintingStyle.stroke;
      if (horizontal) {
        final subY = mainPos + subOffset;
        if (subY > clip.bottom) continue;
        drawDashHVLine(canvas, Offset(clip.left, subY), Offset(clip.right, subY), subPaint, sub.lineStyle);
      } else {
        final subX = mainPos + subOffset;
        if (subX > clip.right) continue;
        drawDashHVLine(canvas, Offset(subX, clip.top), Offset(subX, clip.bottom), subPaint, sub.lineStyle);
      }
    }
  }

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    for (final set in config.lineSets) {
      if (set.count <= 0) continue;
      final stroke = mmToPx(set.strokeWidthMm.clamp(0.1, 5.0), scale);
      final spacing = mmToPx(set.spacingMm, scale);
      final start = mmToPx(set.startMm, scale);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke;

      for (var i = 0; i < set.count; i++) {
        final offset = start + spacing * i;
        if (set.isHorizontal) {
          final y = clip.top + offset;
          if (y > clip.bottom) break;
          drawDashHVLine(canvas, Offset(clip.left, y), Offset(clip.right, y), paint, set.lineStyle);
          _drawSubLines(canvas, set, spacing, scale, y, clip, horizontal: true);
        } else {
          final x = clip.left + offset;
          if (x > clip.right) break;
          drawDashHVLine(canvas, Offset(x, clip.top), Offset(x, clip.bottom), paint, set.lineStyle);
          _drawSubLines(canvas, set, spacing, scale, x, clip, horizontal: false);
        }
      }
    }
  }
}
