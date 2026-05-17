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
    final nominalW = mmToPx(config.cellWidthMm, scale);
    final nominalH = mmToPx(config.cellHeightMm, scale);
    if (nominalW <= 0 || nominalH <= 0) return;

    // セル数を整数に丸めて均等スケーリング → 端数セルなし・枠いっぱいに描画
    final cols = (clip.width  / nominalW).round().clamp(1, 10000);
    final rows = (clip.height / nominalH).round().clamp(1, 10000);
    final cellW = clip.width  / cols;
    final cellH = clip.height / rows;

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.5 : 0.4;
    final paintColor = color.withValues(alpha: opacity);

    Paint makePaint(bool bold) => Paint()
      ..color = paintColor
      ..strokeWidth = bold ? baseStroke * 2 : baseStroke
      ..style = PaintingStyle.stroke;

    if (config.showVertical) {
      for (int c = 0; c <= cols; c++) {
        final x = clip.left + cellW * c;
        final bold = config.boldEvery != null && c % config.boldEvery! == 0;
        drawDashHVLine(canvas, Offset(x, clip.top), Offset(x, clip.bottom),
            makePaint(bold), config.lineStyle);
      }
    }

    if (config.showHorizontal) {
      for (int r = 0; r <= rows; r++) {
        final y = clip.top + cellH * r;
        final bold = config.boldEvery != null && r % config.boldEvery! == 0;
        drawDashHVLine(canvas, Offset(clip.left, y), Offset(clip.right, y),
            makePaint(bold), config.lineStyle);
      }
    }
  }
}
