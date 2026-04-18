import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';

class DotLayerPdfRenderer {
  const DotLayerPdfRenderer({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final DotLayerConfig config;
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
    final spacing = toPoints(config.spacingMm);
    final radius = toPoints(config.dotRadiusMm);
    if (spacing <= 0 || radius <= 0) return;

    // Content rect in PDF space (y-up from bottom-left)
    final left = toPoints(pageConfig.marginLeftMm);
    final right = size.x - toPoints(pageConfig.marginRightMm);
    final bottom = toPoints(pageConfig.marginBottomMm);
    final top = size.y - toPoints(pageConfig.marginTopMm);

    canvas.setFillColor(color);
    canvas.saveContext();
    canvas.drawRect(left, bottom, right - left, top - bottom);
    canvas.clipPath();

    // Center dots in content area
    final offsetX = ((right - left) % spacing) / 2;
    final offsetY = ((top - bottom) % spacing) / 2;

    for (double x = left + offsetX; x <= right + 0.5; x += spacing) {
      for (double y = bottom + offsetY; y <= top + 0.5; y += spacing) {
        canvas.drawEllipse(x - radius, y - radius, radius * 2, radius * 2);
        canvas.fillPath();
      }
    }

    canvas.restoreContext();
  }
}
