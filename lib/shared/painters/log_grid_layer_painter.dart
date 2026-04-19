import 'dart:math';
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class LogGridLayerPainter extends LayerPainterBase<LogGridLayerConfig> {
  const LogGridLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final paintThin = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;

    final paintBold = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    if (config.xScale == LogScale.log) {
      _drawLogAxis(canvas, clip, config.xDecades, horizontal: false,
          paintThin: paintThin, paintBold: paintBold);
    } else {
      _drawLinearAxis(canvas, clip, scale, horizontal: false, paint: paintThin);
    }

    if (config.yScale == LogScale.log) {
      _drawLogAxis(canvas, clip, config.yDecades, horizontal: true,
          paintThin: paintThin, paintBold: paintBold);
    } else {
      _drawLinearAxis(canvas, clip, scale, horizontal: true, paint: paintThin);
    }
  }

  void _drawLogAxis(
    Canvas canvas,
    Rect clip,
    int decades, {
    required bool horizontal,
    required Paint paintThin,
    required Paint paintBold,
  }) {
    final length = horizontal ? clip.height : clip.width;
    final decadeSize = length / decades;

    for (int d = 0; d <= decades; d++) {
      final pos = horizontal ? clip.top + d * decadeSize : clip.left + d * decadeSize;
      _drawLine(canvas, clip, pos, horizontal, paintBold);

      if (d < decades) {
        for (int i = 2; i <= 9; i++) {
          final offset = log(i) / log(10) * decadeSize;
          final mpos = horizontal
              ? clip.top + d * decadeSize + offset
              : clip.left + d * decadeSize + offset;
          _drawLine(canvas, clip, mpos, horizontal, paintThin);
        }
      }
    }
  }

  void _drawLinearAxis(
    Canvas canvas,
    Rect clip,
    double scale, {
    required bool horizontal,
    required Paint paint,
  }) {
    final step = mmToPx(5.0, scale);
    final length = horizontal ? clip.height : clip.width;
    final origin = horizontal ? clip.top : clip.left;
    final offset = (length % step) / 2;

    for (double p = origin + offset; p <= origin + length + 0.5; p += step) {
      _drawLine(canvas, clip, p, horizontal, paint);
    }
  }

  void _drawLine(Canvas canvas, Rect clip, double pos, bool horizontal, Paint paint) {
    if (horizontal) {
      canvas.drawLine(Offset(clip.left, pos), Offset(clip.right, pos), paint);
    } else {
      canvas.drawLine(Offset(pos, clip.top), Offset(pos, clip.bottom), paint);
    }
  }
}
