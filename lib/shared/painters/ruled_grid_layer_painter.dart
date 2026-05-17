import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class RuledGridLayerPainter extends LayerPainterBase<RuledGridLayerConfig> {
  const RuledGridLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final cellPx = mmToPx(config.cellMm, scale);
    final ruledPx = mmToPx(config.ruledSpacingMm, scale);
    if (cellPx <= 0 || ruledPx <= 0) return;

    final gridPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.35)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final ruledPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final offsetX = (clip.width % cellPx) / 2;
    final offsetY = (clip.height % cellPx) / 2;

    // Draw faint grid verticals
    for (double x = clip.left + offsetX; x <= clip.right + 0.5; x += cellPx) {
      canvas.drawLine(Offset(x, clip.top), Offset(x, clip.bottom), gridPaint);
    }

    // Draw faint grid horizontals, but skip ruled lines (will be drawn darker)
    final ruledOffsetY = (clip.height % ruledPx) / 2;
    for (double y = clip.top + offsetY; y <= clip.bottom + 0.5; y += cellPx) {
      canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), gridPaint);
    }

    // Draw ruled lines (darker, override grid lines at those positions)
    for (double y = clip.top + ruledOffsetY; y <= clip.bottom + 0.5; y += ruledPx) {
      canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), ruledPaint);
    }
  }
}
