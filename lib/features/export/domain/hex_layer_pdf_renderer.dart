import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';

class HexLayerPdfRenderer {
  const HexLayerPdfRenderer({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final HexLayerConfig config;
  final PageConfig pageConfig;
  final PdfColor color;
  final double opacity;

  pw.Widget build() {
    final w = toPoints(pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm);
    final h = toPoints(pageConfig.paperSize == PaperSize.a4 ? a4HeightMm : b5HeightMm);
    return pw.CustomPaint(
      painter: (canvas, size) => _paint(canvas, size),
      size: PdfPoint(w, h),
    );
  }

  void _paint(PdfGraphics canvas, PdfPoint size) {
    final hexR = toPoints(config.hexSizeMm);
    if (hexR <= 0) return;

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);

    if (config.orientation == HexOrientation.flat) {
      _drawFlatGrid(canvas, size, hexR);
    } else {
      _drawPointyGrid(canvas, size, hexR);
    }
  }

  void _drawFlatGrid(PdfGraphics canvas, PdfPoint size, double hexR) {
    final qStart = -1;
    final qEnd = (size.x / (hexR * 3.0 / 2.0)).ceil() + 2;
    final rStart = (-size.y / (hexR * sqrt(3.0))).floor() - 1;
    final rEnd = (size.y / (hexR * sqrt(3.0))).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      for (int r = rStart; r <= rEnd; r++) {
        final cx = hexR * 3.0 / 2.0 * q;
        final cy = hexR * (sqrt(3.0) / 2.0 * q + sqrt(3.0) * r);
        _drawHex(canvas, size, cx, cy, hexR, 0.0);
      }
    }
  }

  void _drawPointyGrid(PdfGraphics canvas, PdfPoint size, double hexR) {
    final qStart = -1;
    final qEnd = (size.x / (hexR * sqrt(3.0))).ceil() + 2;
    final rStart = -1;
    final rEnd = (size.y / (hexR * 3.0 / 2.0)).ceil() + 2;

    for (int q = qStart; q <= qEnd; q++) {
      for (int r = rStart; r <= rEnd; r++) {
        final cx = hexR * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r);
        final cy = hexR * 3.0 / 2.0 * r;
        _drawHex(canvas, size, cx, cy, hexR, 30.0);
      }
    }
  }

  void _drawHex(PdfGraphics canvas, PdfPoint size, double cx, double cy, double r, double offsetDeg) {
    // PDF座標系は左下原点なので y を反転
    bool first = true;
    for (int i = 0; i < 6; i++) {
      final angle = (60.0 * i + offsetDeg) * pi / 180.0;
      final x = cx + r * cos(angle);
      final y = size.y - (cy + r * sin(angle));
      if (first) {
        canvas.moveTo(x, y);
        first = false;
      } else {
        canvas.lineTo(x, y);
      }
    }
    canvas.closePath();
    canvas.strokePath();
  }
}
