import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';

class ManuscriptLayerPainter extends LayerPainterBase<ManuscriptLayerConfig> {
  const ManuscriptLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final cols = config.columns;
    final rows = config.rows;
    final cellW = clip.width / cols;
    final cellH = clip.height / rows;

    final thin = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;
    final thick = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 横罫線
    for (int row = 0; row <= rows; row++) {
      final y = clip.top + cellH * row;
      final isEdge = row == 0 || row == rows;
      canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), isEdge ? thick : thin);
    }

    // 縦罫線
    for (int col = 0; col <= cols; col++) {
      final x = clip.left + cellW * col;
      final isEdge = col == 0 || col == cols;
      canvas.drawLine(Offset(x, clip.top), Offset(x, clip.bottom), isEdge ? thick : thin);
    }

    // 各セルの中央に薄い縦の補助線
    final guide = Paint()
      ..color = color.withValues(alpha: opacity * 0.25)
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;
    for (int col = 0; col < cols; col++) {
      final x = clip.left + cellW * col + cellW / 2;
      canvas.drawLine(Offset(x, clip.top), Offset(x, clip.bottom), guide);
    }
  }
}
