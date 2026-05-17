import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class TableLayerPainter extends LayerPainterBase<TableLayerConfig> {
  const TableLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    if (config.rows <= 0 || config.cols <= 0) return;

    final cellH = mmToPx(config.cellHeightMm, scale);
    final cellW = clip.width / config.cols;
    final tableH = cellH * config.rows;

    final thinPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = (scale * 0.25).clamp(0.5, 1.5)
      ..style = PaintingStyle.stroke;
    final boldPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = (scale * 0.6).clamp(1.0, 3.0)
      ..style = PaintingStyle.stroke;

    final left = clip.left;
    final top = clip.top;

    // 水平線
    for (int r = 0; r <= config.rows; r++) {
      final y = top + cellH * r;
      if (y > clip.bottom + 1) break;
      final isHeader = config.showHeaderRow && r == 1;
      final isOuter = r == 0 || r == config.rows;
      canvas.drawLine(Offset(left, y), Offset(left + cellW * config.cols, y),
          (isHeader || isOuter) ? boldPaint : thinPaint);
    }

    // 垂直線
    for (int c = 0; c <= config.cols; c++) {
      final x = left + cellW * c;
      final isHeader = config.showHeaderCol && c == 1;
      final isOuter = c == 0 || c == config.cols;
      canvas.drawLine(Offset(x, top), Offset(x, (top + tableH).clamp(top, clip.bottom)),
          (isHeader || isOuter) ? boldPaint : thinPaint);
    }
  }
}
