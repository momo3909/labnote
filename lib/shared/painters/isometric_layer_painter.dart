import 'dart:math';
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class IsometricLayerPainter extends LayerPainterBase<IsometricLayerConfig> {
  const IsometricLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final cellW = mmToPx(config.spacingMm, scale);
    if (cellW <= 0) return;

    final cellH = cellW * sqrt(3.0) / 2.0;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double y = clip.top; y <= clip.bottom + cellH; y += cellH) {
      canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), paint);
    }

    final diagH = clip.height / sqrt(3.0);

    final nStart = (((clip.left - diagH) - clip.left) / cellW).floor() - 1;
    final nEnd = ((clip.right - clip.left) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = clip.left + n * cellW;
      canvas.drawLine(Offset(x0, clip.top), Offset(x0 + diagH, clip.bottom), paint);
    }

    final n2Start = ((-(clip.width + diagH)) / cellW).floor() - 1;
    final n2End = ((clip.width + diagH) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = clip.left + n * cellW;
      canvas.drawLine(Offset(x0, clip.top), Offset(x0 - diagH, clip.bottom), paint);
    }
  }
}
