import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class StaffLayerPdfRenderer extends LayerPdfRendererBase<StaffLayerConfig> {
  const StaffLayerPdfRenderer({
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
    final lineSpacing = toPoints(config.lineSpacingMm);
    final staffGap = toPoints(config.staffGapMm);
    if (lineSpacing <= 0 || staffGap <= 0) return;

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.5);

    final staffH = lineSpacing * 4;
    final stepH = staffH + staffGap;
    final height = top - bottom;

    final offsetY = (height % stepH) / 2;

    double y = bottom + offsetY;
    while (y <= top + 0.5) {
      for (int i = 0; i < 5; i++) {
        final lineY = y + lineSpacing * i;
        if (lineY > top + 0.5) break;
        canvas.drawLine(left, lineY, right, lineY);
        canvas.strokePath();
      }
      y += stepH;
    }
  }
}
