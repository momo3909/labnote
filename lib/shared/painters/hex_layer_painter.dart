import 'dart:math';
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class HexLayerPainter extends LayerPainterBase<HexLayerConfig> {
  const HexLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final hexR = mmToPx(config.hexSizeMm, scale);
    if (hexR <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    if (config.orientation == HexOrientation.flat) {
      _drawFlatGrid(canvas, clip, hexR, paint);
    } else {
      _drawPointyGrid(canvas, clip, hexR, paint);
    }
  }

  void _drawFlatGrid(Canvas canvas, Rect clip, double hexR, Paint paint) {
    final colStep = hexR * 3.0 / 2.0;
    final rowStep = hexR * sqrt(3.0);

    final qStart = ((clip.left - hexR * 2) / colStep).floor() - 1;
    final qEnd = ((clip.right + hexR * 2) / colStep).ceil() + 1;
    final rStart = ((clip.top - hexR * 2) / rowStep).floor() - 1;
    final rEnd = ((clip.bottom + hexR * 2) / rowStep).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      for (int r = rStart; r <= rEnd; r++) {
        final cx = clip.left + hexR * 3.0 / 2.0 * q;
        final cy = clip.top + hexR * (sqrt(3.0) / 2.0 * q + sqrt(3.0) * r);
        _drawHex(canvas, cx, cy, hexR, 0.0, paint);
      }
    }
  }

  void _drawPointyGrid(Canvas canvas, Rect clip, double hexR, Paint paint) {
    final colStep = hexR * sqrt(3.0);
    final rowStep = hexR * 3.0 / 2.0;

    final qStart = ((clip.left - hexR * 2) / colStep).floor() - 1;
    final qEnd = ((clip.right + hexR * 2) / colStep).ceil() + 1;
    final rStart = ((clip.top - hexR * 2) / rowStep).floor() - 1;
    final rEnd = ((clip.bottom + hexR * 2) / rowStep).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      for (int r = rStart; r <= rEnd; r++) {
        final cx = clip.left + hexR * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r);
        final cy = clip.top + hexR * 3.0 / 2.0 * r;
        _drawHex(canvas, cx, cy, hexR, 30.0, paint);
      }
    }
  }

  void _drawHex(Canvas canvas, double cx, double cy, double r, double offsetDeg, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60.0 * i + offsetDeg) * pi / 180.0;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}
