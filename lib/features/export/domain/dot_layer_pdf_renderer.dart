import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class DotLayerPdfRenderer extends LayerPdfRendererBase<DotLayerConfig> {
  const DotLayerPdfRenderer({
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
    final spacing = toPoints(config.spacingMm);
    final radius = toPoints(config.dotRadiusMm);
    if (spacing <= 0 || radius <= 0) return;

    canvas.setFillColor(color);

    final offsetX = config.alignToOrigin
        ? ((right - left) / 2) % spacing
        : ((right - left) % spacing) / 2;
    final offsetY = config.alignToOrigin
        ? ((top - bottom) / 2) % spacing
        : ((top - bottom) % spacing) / 2;

    for (double x = left + offsetX; x <= right + 0.5; x += spacing) {
      for (double y = bottom + offsetY; y <= top + 0.5; y += spacing) {
        canvas.drawEllipse(x, y, radius, radius);
        canvas.fillPath();
      }
    }
  }
}
