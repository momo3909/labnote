import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class RuledGridLayerPdfRenderer extends LayerPdfRendererBase<RuledGridLayerConfig> {
  const RuledGridLayerPdfRenderer({
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
    final cellPt = toPoints(config.cellMm);
    final ruledPt = toPoints(config.ruledSpacingMm);
    if (cellPt <= 0 || ruledPt <= 0) return;

    final width = right - left;
    final height = top - bottom;
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    final gridColor = PdfColor(r, g, b, opacity * 0.35);
    final ruledColor = PdfColor(r, g, b, opacity.toDouble());

    final offsetX = (width % cellPt) / 2;
    final offsetY = (height % cellPt) / 2;
    final ruledOffsetY = (height % ruledPt) / 2;

    // Grid verticals
    canvas.setStrokeColor(gridColor);
    canvas.setLineWidth(0.4);
    for (double x = left + offsetX; x <= right + 0.5; x += cellPt) {
      canvas.drawLine(x, bottom, x, top);
      canvas.strokePath();
    }

    // Grid horizontals
    for (double y = bottom + offsetY; y <= top + 0.5; y += cellPt) {
      canvas.drawLine(left, y, right, y);
      canvas.strokePath();
    }

    // Ruled lines (darker)
    canvas.setStrokeColor(ruledColor);
    canvas.setLineWidth(0.7);
    for (double y = bottom + ruledOffsetY; y <= top + 0.5; y += ruledPt) {
      canvas.drawLine(left, y, right, y);
      canvas.strokePath();
    }
  }
}
