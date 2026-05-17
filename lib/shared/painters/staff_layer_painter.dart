import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class StaffLayerPainter extends LayerPainterBase<StaffLayerConfig> {
  const StaffLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final lineSpacing = mmToPx(config.lineSpacingMm, scale);
    final staffGap = mmToPx(config.staffGapMm, scale);
    if (lineSpacing <= 0 || staffGap <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    // Height of one staff (4 gaps between 5 lines)
    final staffH = lineSpacing * 4;
    final stepH = staffH + staffGap;

    final offsetY = (clip.height % stepH) / 2;

    double y = clip.top + offsetY;
    while (y <= clip.bottom + 0.5) {
      for (int i = 0; i < 5; i++) {
        final lineY = y + lineSpacing * i;
        if (lineY > clip.bottom + 0.5) break;
        canvas.drawLine(Offset(clip.left, lineY), Offset(clip.right, lineY), paint);
      }
      y += stepH;
    }
  }
}
