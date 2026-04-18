import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class GridLayerPainter extends CustomPainter {
  const GridLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final GridLayerConfig config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paperWidthMm = pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final scale = scaleFactor(size.width, paperWidthMm);
    final cellW = mmToPx(config.cellWidthMm, scale);
    final cellH = mmToPx(config.cellHeightMm, scale);
    if (cellW <= 0 || cellH <= 0) return;

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.5 : 0.4;
    final paintColor = color.withValues(alpha: opacity);

    Paint makePaint(bool bold) => Paint()
      ..color = paintColor
      ..strokeWidth = bold ? baseStroke * 2 : baseStroke
      ..style = PaintingStyle.stroke;

    int col = 0;
    for (double x = 0; x <= size.width + cellW; x += cellW) {
      final bold = config.boldEvery != null && col % config.boldEvery! == 0;
      _drawLine(canvas, Offset(x, 0), Offset(x, size.height), makePaint(bold));
      col++;
    }

    int row = 0;
    for (double y = 0; y <= size.height + cellH; y += cellH) {
      final bold = config.boldEvery != null && row % config.boldEvery! == 0;
      _drawLine(canvas, Offset(0, y), Offset(size.width, y), makePaint(bold));
      row++;
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

  @override
  bool shouldRepaint(GridLayerPainter old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity;
}
