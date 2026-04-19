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
    final cellW = toPoints(config.cellWidthMm);
    final cellH = toPoints(config.cellHeightMm);
    if (cellW <= 0 || cellH <= 0) return;

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.3 : 0.25;
    canvas.setStrokeColor(color);

    final offsetX = ((right - left) % cellW) / 2;
    final offsetY = ((top - bottom) % cellH) / 2;

    if (config.showVertical) {
      int col = 0;
      for (double x = left + offsetX; x <= right + 0.5; x += cellW) {
        final bold = config.boldEvery != null && col % config.boldEvery! == 0;
        canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
        _drawLine(canvas, x, bottom, x, top, vertical: true);
        col++;
      }
    }

    if (config.showHorizontal) {
      int row = 0;
      for (double y = bottom + offsetY; y <= top + 0.5; y += cellH) {
        final bold = config.boldEvery != null && row % config.boldEvery! == 0;
        canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
        _drawLine(canvas, left, y, right, y, vertical: false);
        row++;
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
