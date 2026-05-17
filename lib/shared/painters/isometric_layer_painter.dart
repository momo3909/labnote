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
    final isSolid = config.lineStyle == LineStyle.solid;
    final dashLen = config.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
    final gapLen  = config.lineStyle == LineStyle.dotted ? 2.0 : 3.0;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = isSolid ? 0.5 : 0.4
      ..style = PaintingStyle.stroke;

    void drawLine(Offset a, Offset b) {
      if (isSolid) { canvas.drawLine(a, b, paint); return; }
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = sqrt(dx * dx + dy * dy);
      if (len == 0) return;
      final ux = dx / len; final uy = dy / len;
      double pos = 0; bool on = true;
      while (pos < len) {
        final next = (pos + (on ? dashLen : gapLen)).clamp(0.0, len);
        if (on) {
          canvas.drawLine(
            Offset(a.dx + ux * pos, a.dy + uy * pos),
            Offset(a.dx + ux * next, a.dy + uy * next),
            paint,
          );
        }
        pos = next; on = !on;
      }
    }

    for (double y = clip.top; y <= clip.bottom + cellH; y += cellH) {
      drawLine(Offset(clip.left, y), Offset(clip.right, y));
    }

    final diagH = clip.height / sqrt(3.0);

    final nStart = ((-diagH) / cellW).floor() - 1;
    final nEnd = ((clip.width + diagH) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = clip.left + n * cellW;
      drawLine(Offset(x0, clip.top), Offset(x0 + diagH, clip.bottom));
    }

    final n2Start = ((-(clip.width + diagH)) / cellW).floor() - 1;
    final n2End = ((clip.width + diagH) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = clip.left + n * cellW;
      drawLine(Offset(x0, clip.top), Offset(x0 - diagH, clip.bottom));
    }
  }
}
