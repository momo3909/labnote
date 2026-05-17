import 'dart:math' show sqrt;
import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class CustomLineLayerPdfRenderer extends LayerPdfRendererBase<CustomLineLayerConfig> {
  const CustomLineLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  void _drawSubLines(PdfGraphics canvas, LineSet set, double spacing,
      double mainPos, double left, double right, double bottom, double top,
      {required bool horizontal}) {
    if (set.subLines.isEmpty || spacing <= 0) return;
    for (final sub in set.subLines) {
      final ratio = sub.positionRatio.clamp(0.01, 0.99);
      final subStroke = toPoints(sub.strokeWidthMm.clamp(0.05, 2.0));
      final isSolid = sub.lineStyle == LineStyle.solid;
      final dashLen = sub.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
      final gapLen  = sub.lineStyle == LineStyle.dotted ? 2.0 : 3.0;

      void drawSub(double x1, double y1, double x2, double y2) {
        canvas.setLineWidth(subStroke);
        if (isSolid) {
          canvas.moveTo(x1, y1); canvas.lineTo(x2, y2); canvas.strokePath();
          return;
        }
        final dx = x2 - x1; final dy = y2 - y1;
        final len = dx.abs() + dy.abs(); // horizontal/vertical only
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

      if (horizontal) {
        // PDF y-up: メイン線から spacing*ratio だけ下（y 減少）
        final subY = mainPos - spacing * ratio;
        if (subY < bottom) continue;
        drawSub(left, subY, right, subY);
      } else {
        final subX = mainPos + spacing * ratio;
        if (subX > right) continue;
        drawSub(subX, bottom, subX, top);
      }
    }
  }

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    for (final set in config.lineSets) {
      if (set.count <= 0) continue;
      final stroke = toPoints(set.strokeWidthMm.clamp(0.1, 5.0));
      final spacing = toPoints(set.spacingMm);
      final startOff = toPoints(set.startMm);
      final isSolid = set.lineStyle == LineStyle.solid;
      final dashLen = set.lineStyle == LineStyle.dotted ? 1.5 : 4.0;
      final gapLen  = set.lineStyle == LineStyle.dotted ? 2.0 : 3.0;
      canvas.setStrokeColor(color);
      canvas.setLineWidth(stroke);

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

      for (var i = 0; i < set.count; i++) {
        final offset = startOff + spacing * i;
        if (set.isHorizontal) {
          final y = top - offset;
          if (y < bottom) break;
          drawLine(left, y, right, y);
          _drawSubLines(canvas, set, spacing, y, left, right, bottom, top, horizontal: true);
        } else {
          final x = left + offset;
          if (x > right) break;
          drawLine(x, bottom, x, top);
          _drawSubLines(canvas, set, spacing, x, left, right, bottom, top, horizontal: false);
        }
      }
    }
  }
}
