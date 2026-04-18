import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';

class IsometricLayerPdfRenderer {
  const IsometricLayerPdfRenderer({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final IsometricLayerConfig config;
  final PageConfig pageConfig;
  final PdfColor color;
  final double opacity;

  pw.Widget build() {
    final w = toPoints(pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm);
    final h = toPoints(pageConfig.paperSize == PaperSize.a4 ? a4HeightMm : b5HeightMm);
    return pw.CustomPaint(
      painter: (canvas, size) => _paint(canvas, size),
      size: PdfPoint(w, h),
    );
  }

  void _paint(PdfGraphics canvas, PdfPoint size) {
    final cellW = toPoints(config.spacingMm);
    if (cellW <= 0) return;

    final cellH = cellW * sqrt(3.0) / 2.0;
    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);

    // PDF座標系は左下原点: y=0=bottom, y=size.y=top
    // Horizontal lines (in PDF: y = k * cellH from bottom)
    for (double y = 0; y <= size.y + cellH; y += cellH) {
      canvas.moveTo(0, y);
      canvas.lineTo(size.x, y);
      canvas.strokePath();
    }

    final diag = size.y / sqrt(3.0);

    // Lines going upper-right in PDF space (slope +√3 in screen → lower-left to upper-right in PDF)
    // In PDF (y-up): going right and UP = positive slope
    // For a 60° line in PDF: slope = tan(60°) = √3
    // At y=0 (bottom): x = x0; at y=size.y (top): x = x0 + diag
    final nStart = ((-diag) / cellW).floor() - 1;
    final nEnd = ((size.x + diag) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = n * cellW;
      canvas.moveTo(x0, 0);
      canvas.lineTo(x0 + diag, size.y);
      canvas.strokePath();
    }

    // Lines going upper-left in PDF space (slope -√3)
    // At y=0 (bottom): x = x0; at y=size.y (top): x = x0 - diag
    final n2Start = ((-size.x - diag) / cellW).floor() - 1;
    final n2End = ((size.x + diag) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = n * cellW;
      canvas.moveTo(x0, 0);
      canvas.lineTo(x0 - diag, size.y);
      canvas.strokePath();
    }
  }
}
