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

    final baseStroke = config.lineStyle == LineStyle.solid ? 0.3 : 0.25;

    canvas.setStrokeColor(color);

    int col = 0;
    for (double x = 0; x <= size.x + cellW; x += cellW) {
      final bold = config.boldEvery != null && col % config.boldEvery! == 0;
      canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
      _drawLine(canvas, x, 0, x, size.y, size);
      col++;
    }

    int row = 0;
    for (double y = 0; y <= size.y + cellH; y += cellH) {
      final bold = config.boldEvery != null && row % config.boldEvery! == 0;
      canvas.setLineWidth(bold ? baseStroke * 2 : baseStroke);
      _drawLine(canvas, 0, y, size.x, y, size);
      row++;
    }
  }

  void _drawLine(PdfGraphics canvas, double x1, double y1, double x2, double y2, PdfPoint size) {
    // PDF座標系は左下原点なので y を反転
    final fy1 = size.y - y1;
    final fy2 = size.y - y2;

    if (config.lineStyle == LineStyle.solid) {
      canvas
        ..moveTo(x1, fy1)
        ..lineTo(x2, fy2)
        ..strokePath();
      return;
    }

    final dashLen = config.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
    final gapLen = config.lineStyle == LineStyle.dotted ? 2.0 : 3.0;
    final isHorizontal = (y2 - y1).abs() < (x2 - x1).abs();
    final totalLen = isHorizontal ? (x2 - x1).abs() : (y2 - y1).abs();
    final sign = isHorizontal
        ? (x2 >= x1 ? 1.0 : -1.0)
        : (fy2 >= fy1 ? 1.0 : -1.0);

    double pos = 0;
    bool drawing = true;
    while (pos < totalLen) {
      final next = (pos + (drawing ? dashLen : gapLen)).clamp(0.0, totalLen);
      if (drawing) {
        final sx = isHorizontal ? x1 + pos * sign : x1;
        final sy = isHorizontal ? fy1 : fy1 + pos * sign;
        final ex = isHorizontal ? x1 + next * sign : x2;
        final ey = isHorizontal ? fy2 : fy1 + next * sign;
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
