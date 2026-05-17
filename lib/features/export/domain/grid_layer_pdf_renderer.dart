import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class GridLayerPdfRenderer extends LayerPdfRendererBase<GridLayerConfig> {
  const GridLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    final nominalW = toPoints(config.cellWidthMm);
    final nominalH = toPoints(config.cellHeightMm);
    if (nominalW <= 0 || nominalH <= 0) return;

    final w = right - left;
    final h = top - bottom;
    final cols = (w / nominalW).round().clamp(1, 10000);
    final rows = (h / nominalH).round().clamp(1, 10000);
    final cellW = w / cols;
    final cellH = h / rows;

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.3 : 0.25;
    canvas.setStrokeColor(color);

    if (config.showVertical) {
      for (int c = 0; c <= cols; c++) {
        final x = left + cellW * c;
        final bold = config.boldEvery != null && c % config.boldEvery! == 0;
        canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
        _drawLine(canvas, x, bottom, x, top, vertical: true);
      }
    }

    if (config.showHorizontal) {
      for (int r = 0; r <= rows; r++) {
        final y = bottom + cellH * r;  // PDF y-up: bottom + offset
        final bold = config.boldEvery != null && r % config.boldEvery! == 0;
        canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
        _drawLine(canvas, left, y, right, y, vertical: false);
      }
    }
  }

  void _drawLine(
    PdfGraphics canvas,
    double x1,
    double y1,
    double x2,
    double y2, {
    required bool vertical,
  }) {
    if (config.lineStyle == LineStyle.solid) {
      canvas
        ..moveTo(x1, y1)
        ..lineTo(x2, y2)
        ..strokePath();
      return;
    }

    final dashLen = config.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
    final gapLen = config.lineStyle == LineStyle.dotted ? 2.0 : 3.0;
    final totalLen = vertical ? (y2 - y1).abs() : (x2 - x1).abs();
    final sign = vertical
        ? (y2 >= y1 ? 1.0 : -1.0)
        : (x2 >= x1 ? 1.0 : -1.0);

    double pos = 0;
    bool drawing = true;
    while (pos < totalLen) {
      final next = (pos + (drawing ? dashLen : gapLen)).clamp(0.0, totalLen);
      if (drawing) {
        final sx = vertical ? x1 : x1 + pos * sign;
        final sy = vertical ? y1 + pos * sign : y1;
        final ex = vertical ? x2 : x1 + next * sign;
        final ey = vertical ? y1 + next * sign : y2;
        canvas
          ..moveTo(sx, sy)
          ..lineTo(ex, ey)
          ..strokePath();
      }
      pos = next;
      drawing = !drawing;
    }
  }
}
