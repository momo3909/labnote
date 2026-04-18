import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';

class LogGridLayerPdfRenderer {
  const LogGridLayerPdfRenderer({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final LogGridLayerConfig config;
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

    canvas.saveContext();
    canvas.drawRect(left, bottom, right - left, top - bottom);
    canvas.clipPath();

    // X axis (vertical lines)
    if (config.xScale == LogScale.log) {
      _drawLogAxis(canvas, left, right, bottom, top,
          decades: config.xDecades, horizontal: false);
    } else {
      _drawLinearAxis(canvas, left, right, bottom, top, horizontal: false);
    }

    // Y axis (horizontal lines) — PDF y-up: origin at bottom
    if (config.yScale == LogScale.log) {
      _drawLogAxis(canvas, left, right, bottom, top,
          decades: config.yDecades, horizontal: true);
    } else {
      _drawLinearAxis(canvas, left, right, bottom, top, horizontal: true);
    }

    canvas.restoreContext();
  }

  void _drawLogAxis(
    PdfGraphics canvas,
    double left, double right, double bottom, double top, {
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
          _drawLine(canvas, left, right, bottom, top,
              pos + offset, horizontal, bold: false);
        }
      }
    }
  }

  void _drawLinearAxis(
    PdfGraphics canvas,
    double left, double right, double bottom, double top, {
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
    double left, double right, double bottom, double top,
    double pos, bool horizontal, {required bool bold}
  ) {
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
