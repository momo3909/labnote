import 'dart:math';
import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class LogGridLayerPdfRenderer extends LayerPdfRendererBase<LogGridLayerConfig> {
  const LogGridLayerPdfRenderer({
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
    if (config.xScale == LogScale.log) {
      _drawLogAxis(canvas, left, right, bottom, top,
          decades: config.xDecades, horizontal: false);
    } else {
      _drawLinearAxis(canvas, left, right, bottom, top, horizontal: false);
    }

    if (config.yScale == LogScale.log) {
      _drawLogAxis(canvas, left, right, bottom, top,
          decades: config.yDecades, horizontal: true);
    } else {
      _drawLinearAxis(canvas, left, right, bottom, top, horizontal: true);
    }
  }

  void _drawLogAxis(
    PdfGraphics canvas,
    double left,
    double right,
    double bottom,
    double top, {
    required int decades,
    required bool horizontal,
  }) {
    final length = horizontal ? top - bottom : right - left;
    final decadeSize = length / decades;

    for (int d = 0; d <= decades; d++) {
      final pos = (horizontal ? bottom : left) + d * decadeSize;
      _drawLine(canvas, left, right, bottom, top, pos, horizontal, bold: true);

      if (d < decades) {
        for (int i = 2; i <= 9; i++) {
          final offset = log(i) / log(10) * decadeSize;
          _drawLine(canvas, left, right, bottom, top, pos + offset, horizontal, bold: false);
        }
      }
    }
  }

  void _drawLinearAxis(
    PdfGraphics canvas,
    double left,
    double right,
    double bottom,
    double top, {
    required bool horizontal,
  }) {
    final step = toPoints(5.0);
    final length = horizontal ? top - bottom : right - left;
    final origin = horizontal ? bottom : left;
    final offset = (length % step) / 2;

    for (double p = origin + offset; p <= origin + length + 0.5; p += step) {
      _drawLine(canvas, left, right, bottom, top, p, horizontal, bold: false);
    }
  }

  void _drawLine(
    PdfGraphics canvas,
    double left,
    double right,
    double bottom,
    double top,
    double pos,
    bool horizontal, {
    required bool bold,
  }) {
    canvas.setStrokeColor(color);
    canvas.setLineWidth(bold ? 0.5 : 0.25);
    if (horizontal) {
      canvas.moveTo(left, pos);
      canvas.lineTo(right, pos);
    } else {
      canvas.moveTo(pos, bottom);
      canvas.lineTo(pos, top);
    }
    canvas.strokePath();
  }
}
