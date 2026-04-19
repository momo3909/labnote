import 'dart:math';
import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class HexLayerPdfRenderer extends LayerPdfRendererBase<HexLayerConfig> {
  const HexLayerPdfRenderer({
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
    final hexR = toPoints(config.hexSizeMm);
    if (hexR <= 0) return;

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);

    if (config.orientation == HexOrientation.flat) {
      _drawFlatGrid(canvas, left, right, bottom, top, hexR);
    } else {
      _drawPointyGrid(canvas, left, right, bottom, top, hexR);
    }
  }

  void _drawFlatGrid(PdfGraphics canvas, double left, double right, double bottom, double top, double hexR) {
    final w = right - left;
    final h = top - bottom;
    final colStep = hexR * 3.0 / 2.0;
    final rowStep = hexR * sqrt(3.0);

    final qStart = ((left - hexR * 2) / colStep).floor() - 1;
    final qEnd = ((left + w + hexR * 2) / colStep).ceil() + 1;
    final rStart = ((bottom - hexR * 2) / rowStep).floor() - 1;
    final rEnd = ((bottom + h + hexR * 2) / rowStep).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      for (int r = rStart; r <= rEnd; r++) {
        final cx = left + hexR * 3.0 / 2.0 * q;
        final cy = bottom + hexR * (sqrt(3.0) / 2.0 * q + sqrt(3.0) * r);
        _drawHex(canvas, cx, cy, hexR, 0.0);
      }
    }
  }

  void _drawPointyGrid(PdfGraphics canvas, double left, double right, double bottom, double top, double hexR) {
    final w = right - left;
    final h = top - bottom;
    final colStep = hexR * sqrt(3.0);
    final rowStep = hexR * 3.0 / 2.0;

    final qStart = ((left - hexR * 2) / colStep).floor() - 1;
    final qEnd = ((left + w + hexR * 2) / colStep).ceil() + 1;
    final rStart = ((bottom - hexR * 2) / rowStep).floor() - 1;
    final rEnd = ((bottom + h + hexR * 2) / rowStep).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      for (int r = rStart; r <= rEnd; r++) {
        final cx = left + hexR * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r);
        final cy = bottom + hexR * 3.0 / 2.0 * r;
        _drawHex(canvas, cx, cy, hexR, 30.0);
      }
    }
  }

  void _drawHex(PdfGraphics canvas, double cx, double cy, double r, double offsetDeg) {
    bool first = true;
    for (int i = 0; i < 6; i++) {
      final angle = (60.0 * i + offsetDeg) * pi / 180.0;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
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
