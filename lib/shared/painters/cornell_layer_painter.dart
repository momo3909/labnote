import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class CornellLayerPainter extends LayerPainterBase<CornellLayerConfig> {
  const CornellLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final leftColW = mmToPx(config.leftColMm, scale);
    final bottomRowH = mmToPx(config.bottomRowMm, scale);
    final lineSpacing = mmToPx(config.lineSpacingMm, scale);

    final dividerX = clip.left + leftColW;
    final dividerY = clip.bottom - bottomRowH;

    final paintLine = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;

    final paintDivider = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (lineSpacing > 0) {
      final mainTop = clip.top;
      final mainBottom = dividerY;
      final offsetY = (mainBottom - mainTop) % lineSpacing / 2;
      for (double y = mainTop + offsetY + lineSpacing; y <= mainBottom - 1; y += lineSpacing) {
        canvas.drawLine(Offset(dividerX, y), Offset(clip.right, y), paintLine);
      }
    }

    canvas.drawLine(Offset(dividerX, clip.top), Offset(dividerX, dividerY), paintDivider);
    canvas.drawLine(Offset(clip.left, dividerY), Offset(clip.right, dividerY), paintDivider);
  }
}
