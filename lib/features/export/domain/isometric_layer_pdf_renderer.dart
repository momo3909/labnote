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

    // Content rect in PDF space (y-up from bottom-left)
    final left = toPoints(pageConfig.marginLeftMm);
    final right = size.x - toPoints(pageConfig.marginRightMm);
    final bottom = toPoints(pageConfig.marginBottomMm);
    final top = size.y - toPoints(pageConfig.marginTopMm);
    final contentH = top - bottom;

    final cellH = cellW * sqrt(3.0) / 2.0;
    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);
    canvas.saveContext();
    canvas.drawRect(left, bottom, right - left, contentH);
    canvas.clipPath();

    // Horizontal lines
    for (double y = bottom; y <= top + cellH; y += cellH) {
      canvas.moveTo(left, y);
      canvas.lineTo(right, y);
      canvas.strokePath();
    }

    final diagH = contentH / sqrt(3.0);

    // Lines going upper-right (slope +√3 in PDF y-up space)
    final nStart = ((-diagH) / cellW).floor() - 1;
    final nEnd = ((right - left + diagH) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = left + n * cellW;
      canvas.moveTo(x0, bottom);
      canvas.lineTo(x0 + diagH, top);
      canvas.strokePath();
    }

    // Lines going upper-left (slope -√3)
    final n2Start = ((-(right - left) - diagH) / cellW).floor() - 1;
    final n2End = ((right - left + diagH) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = left + n * cellW;
      canvas.moveTo(x0, bottom);
      canvas.lineTo(x0 - diagH, top);
      canvas.strokePath();
    }

    canvas.restoreContext();
  }
}
