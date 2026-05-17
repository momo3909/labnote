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
    final sqrt3 = sqrt(3.0);

    // q は cx にのみ直接影響する軸。q ごとに r 範囲を算出して右上の欠けを防ぐ。
    final qStart = ((-hexR * 2) / colStep).floor() - 1;
    final qEnd   = ((clip.width + hexR * 2) / colStep).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      final cx   = clip.left + colStep * q;
      final qOff = sqrt3 / 2.0 * q;
      // cy = clip.top + hexR * (qOff + sqrt3 * r) を clip 高さで覆う r 範囲
      final rStart = ((-1.0 - qOff) / sqrt3).floor() - 1;
      final rEnd   = ((clip.height / hexR + 1.0 - qOff) / sqrt3).ceil() + 1;
      for (int r = rStart; r <= rEnd; r++) {
        final cy = clip.top + hexR * (qOff + sqrt3 * r);
        _drawHex(canvas, cx, cy, hexR, 0.0, paint);
      }
    }
  }

  void _drawPointyGrid(Canvas canvas, Rect clip, double hexR, Paint paint) {
    final rowStep = hexR * 3.0 / 2.0;
    final sqrt3 = sqrt(3.0);

    // r は cy にのみ直接影響する軸。r ごとに q 範囲を算出する。
    final rStart = ((-hexR * 2) / rowStep).floor() - 1;
    final rEnd   = ((clip.height + hexR * 2) / rowStep).ceil() + 1;

    for (int r = rStart; r <= rEnd; r++) {
      final cy   = clip.top + rowStep * r;
      final rOff = sqrt3 / 2.0 * r;
      // cx = clip.left + hexR * (sqrt3 * q + rOff) を clip 幅で覆う q 範囲
      final qStart = ((-1.0 - rOff) / sqrt3).floor() - 1;
      final qEnd   = ((clip.width / hexR + 1.0 - rOff) / sqrt3).ceil() + 1;
      for (int q = qStart; q <= qEnd; q++) {
        final cx = clip.left + hexR * (sqrt3 * q + rOff);
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
