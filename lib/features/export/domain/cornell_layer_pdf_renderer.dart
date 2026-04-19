import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class CornellLayerPdfRenderer extends LayerPdfRendererBase<CornellLayerConfig> {
  const CornellLayerPdfRenderer({
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
    final leftColW = toPoints(config.leftColMm);
    final bottomRowH = toPoints(config.bottomRowMm);
    final lineSpacing = toPoints(config.lineSpacingMm);

    final dividerX = left + leftColW;
    final dividerY = bottom + bottomRowH;

    if (lineSpacing > 0) {
      final offsetY = (top - dividerY) % lineSpacing / 2;
      for (double y = dividerY + lineSpacing + offsetY; y <= top - 1; y += lineSpacing) {
        canvas.setStrokeColor(color);
        canvas.setLineWidth(0.25);
        canvas.moveTo(dividerX, y);
        canvas.lineTo(right, y);
        canvas.strokePath();
      }
    }

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.6);

    canvas.moveTo(dividerX, dividerY);
    canvas.lineTo(dividerX, top);
    canvas.strokePath();

    canvas.moveTo(left, dividerY);
    canvas.lineTo(right, dividerY);
    canvas.strokePath();
  }
}
