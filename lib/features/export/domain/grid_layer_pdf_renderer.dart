import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';

class GridLayerPdfRenderer {
  const GridLayerPdfRenderer({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final GridLayerConfig config;
  final PageConfig pageConfig;
  final PdfColor color;
  final double opacity;

  pw.Widget build() {
    return pw.CustomPaint(
      painter: (canvas, size) => _paint(canvas, size),
      size: PdfPoint(
        toPoints(pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm),
        toPoints(pageConfig.paperSize == PaperSize.a4 ? a4HeightMm : b5HeightMm),
      ),
    );
  }

  void _paint(PdfGraphics canvas, PdfPoint size) {
    final cellW = toPoints(config.cellWidthMm);
    final cellH = toPoints(config.cellHeightMm);
    if (cellW <= 0 || cellH <= 0) return;

    // Content area in PDF points (PDF origin is bottom-left)
    final left = toPoints(pageConfig.marginLeftMm);
    final right = size.x - toPoints(pageConfig.marginRightMm);
    final bottom = toPoints(pageConfig.marginBottomMm);
    final top = size.y - toPoints(pageConfig.marginTopMm);

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.3 : 0.25;
    canvas.setStrokeColor(color);

    // Clip to content rect
    canvas.saveContext();
    canvas.drawRect(left, bottom, right - left, top - bottom);
    canvas.clipPath();

    // Center grid so partial cells at both edges are equal
    final offsetX = ((right - left) % cellW) / 2;
    final offsetY = ((top - bottom) % cellH) / 2;

    if (config.showVertical) {
      int col = 0;
      for (double x = left + offsetX; x <= right + 0.5; x += cellW) {
        final bold = config.boldEvery != null && col % config.boldEvery! == 0;
        canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
        _drawLine(canvas, x, bottom, x, top, size, vertical: true);
        col++;
      }
    }

    if (config.showHorizontal) {
      int row = 0;
      for (double y = bottom + offsetY; y <= top + 0.5; y += cellH) {
        final bold = config.boldEvery != null && row % config.boldEvery! == 0;
        canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
        _drawLine(canvas, left, y, right, y, size, vertical: false);
        row++;
      }
    }

    canvas.restoreContext();
  }

  // Coordinates are passed in PDF space (y-up from bottom-left); no inversion needed.
  void _drawLine(
    PdfGraphics canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    PdfPoint size, {
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
