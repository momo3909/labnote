import 'dart:math';
import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class IsometricLayerPdfRenderer extends LayerPdfRendererBase<IsometricLayerConfig> {
  const IsometricLayerPdfRenderer({
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
    final cellW = toPoints(config.spacingMm);
    if (cellW <= 0) return;

    final cellH = cellW * sqrt(3.0) / 2.0;
    final contentH = top - bottom;
    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);

    for (double y = bottom; y <= top + cellH; y += cellH) {
      canvas.moveTo(left, y);
      canvas.lineTo(right, y);
      canvas.strokePath();
    }

    final diagH = contentH / sqrt(3.0);

    final nStart = ((-diagH) / cellW).floor() - 1;
    final nEnd = ((right - left + diagH) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = left + n * cellW;
      canvas.moveTo(x0, bottom);
      canvas.lineTo(x0 + diagH, top);
      canvas.strokePath();
    }

    final n2Start = ((-(right - left) - diagH) / cellW).floor() - 1;
    final n2End = ((right - left + diagH) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = left + n * cellW;
      canvas.moveTo(x0, bottom);
      canvas.lineTo(x0 - diagH, top);
      canvas.strokePath();
    }
  }
}
