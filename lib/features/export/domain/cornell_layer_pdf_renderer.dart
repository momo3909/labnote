import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';

class CornellLayerPdfRenderer {
  const CornellLayerPdfRenderer({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final CornellLayerConfig config;
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
    // Content rect in PDF space (y-up from bottom-left)
    final left = toPoints(pageConfig.marginLeftMm);
    final right = size.x - toPoints(pageConfig.marginRightMm);
    final bottom = toPoints(pageConfig.marginBottomMm);
    final top = size.y - toPoints(pageConfig.marginTopMm);
    if (right <= left || top <= bottom) return;

    final leftColW = toPoints(config.leftColMm);
    final bottomRowH = toPoints(config.bottomRowMm);
    final lineSpacing = toPoints(config.lineSpacingMm);

    final dividerX = left + leftColW;
    final dividerY = bottom + bottomRowH; // PDF y-up: summary is at the bottom

    canvas.saveContext();
    canvas.drawRect(left, bottom, right - left, top - bottom);
    canvas.clipPath();

    // Horizontal ruled lines in main area (PDF y-up: from dividerY to top)
    if (lineSpacing > 0) {
      final mainTop = top;
      final mainBottom = dividerY;
      final offsetY = (mainTop - mainBottom) % lineSpacing / 2;
      for (double y = mainBottom + lineSpacing + offsetY;
          y <= mainTop - 1;
          y += lineSpacing) {
        canvas.setStrokeColor(color);
        canvas.setLineWidth(0.25);
        canvas.moveTo(dividerX, y);
        canvas.lineTo(right, y);
        canvas.strokePath();
      }
    }

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.6);

    // Vertical divider
    canvas.moveTo(dividerX, dividerY);
    canvas.lineTo(dividerX, top);
    canvas.strokePath();

    // Horizontal divider (summary top edge)
    canvas.moveTo(left, dividerY);
    canvas.lineTo(right, dividerY);
    canvas.strokePath();

    canvas.restoreContext();
  }
}
