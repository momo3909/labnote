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
    final isSolid = config.lineStyle == LineStyle.solid;
    final dashLen = config.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
    final gapLen  = config.lineStyle == LineStyle.dotted ? 2.0 : 3.0;
    canvas.setStrokeColor(color);
    canvas.setLineWidth(isSolid ? 0.3 : 0.25);

    void drawLine(double x1, double y1, double x2, double y2) {
      if (isSolid) {
        canvas.moveTo(x1, y1); canvas.lineTo(x2, y2); canvas.strokePath();
        return;
      }
      final dx = x2 - x1; final dy = y2 - y1;
      final len = sqrt(dx * dx + dy * dy);
      if (len == 0) return;
      final ux = dx / len; final uy = dy / len;
      double pos = 0; bool on = true;
      while (pos < len) {
        final next = (pos + (on ? dashLen : gapLen)).clamp(0.0, len);
        if (on) {
          canvas.moveTo(x1 + ux * pos, y1 + uy * pos);
          canvas.lineTo(x1 + ux * next, y1 + uy * next);
          canvas.strokePath();
        }
        pos = next; on = !on;
      }
    }

    for (double y = bottom; y <= top + cellH; y += cellH) {
      drawLine(left, y, right, y);
    }

    final diagH = contentH / sqrt(3.0);

    final nStart = ((-diagH) / cellW).floor() - 1;
    final nEnd = ((right - left + diagH) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = left + n * cellW;
      drawLine(x0, bottom, x0 + diagH, top);
    }

    final n2Start = ((-(right - left) - diagH) / cellW).floor() - 1;
    final n2End = ((right - left + diagH) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = left + n * cellW;
      drawLine(x0, bottom, x0 - diagH, top);
    }
  }
}
