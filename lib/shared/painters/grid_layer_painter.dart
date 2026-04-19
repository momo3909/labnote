import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class GridLayerPainter extends LayerPainterBase<GridLayerConfig> {
  const GridLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final cellW = mmToPx(config.cellWidthMm, scale);
    final cellH = mmToPx(config.cellHeightMm, scale);
    if (cellW <= 0 || cellH <= 0) return;

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.5 : 0.4;
    final paintColor = color.withValues(alpha: opacity);

    Paint makePaint(bool bold) => Paint()
      ..color = paintColor
      ..strokeWidth = bold ? baseStroke * 2 : baseStroke
      ..style = PaintingStyle.stroke;

    final offsetX = (clip.width % cellW) / 2;
    final offsetY = (clip.height % cellH) / 2;

    if (config.showVertical) {
      int col = 0;
      for (double x = clip.left + offsetX; x <= clip.right + 0.5; x += cellW) {
        final bold = config.boldEvery != null && col % config.boldEvery! == 0;
        _drawLine(canvas, Offset(x, clip.top), Offset(x, clip.bottom), makePaint(bold));
        col++;
      }
    }

    if (config.showHorizontal) {
      int row = 0;
      for (double y = clip.top + offsetY; y <= clip.bottom + 0.5; y += cellH) {
        final bold = config.boldEvery != null && row % config.boldEvery! == 0;
        _drawLine(canvas, Offset(clip.left, y), Offset(clip.right, y), makePaint(bold));
        row++;
      }
    }
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    if (config.lineStyle == LineStyle.solid) {
      canvas.drawLine(start, end, paint);
      return;
    }

    final dashLen = config.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
    final gapLen = config.lineStyle == LineStyle.dotted ? 2.0 : 3.0;
    final isHorizontal = (end.dy - start.dy).abs() < (end.dx - start.dx).abs();
    final totalLen = isHorizontal
        ? (end.dx - start.dx).abs()
        : (end.dy - start.dy).abs();
    final sign = isHorizontal
        ? (end.dx >= start.dx ? 1.0 : -1.0)
        : (end.dy >= start.dy ? 1.0 : -1.0);

    double pos = 0;
    bool drawing = true;
    while (pos < totalLen) {
      final next = (pos + (drawing ? dashLen : gapLen)).clamp(0.0, totalLen);
      if (drawing) {
        final s = isHorizontal
            ? Offset(start.dx + pos * sign, start.dy)
            : Offset(start.dx, start.dy + pos * sign);
        final e = isHorizontal
            ? Offset(start.dx + next * sign, start.dy)
            : Offset(start.dx, start.dy + next * sign);
        canvas.drawLine(s, e, paint);
      }
      pos = next;
      drawing = !drawing;
    }
  }
}
