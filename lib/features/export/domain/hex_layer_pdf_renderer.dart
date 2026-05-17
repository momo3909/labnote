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
    final sqrt3 = sqrt(3.0);

    final qStart = ((-hexR * 2) / colStep).floor() - 1;
    final qEnd   = ((w + hexR * 2) / colStep).ceil() + 1;

    for (int q = qStart; q <= qEnd; q++) {
      final cx   = left + colStep * q;
      final qOff = sqrt3 / 2.0 * q;
      final rStart = ((-1.0 - qOff) / sqrt3).floor() - 1;
      final rEnd   = ((h / hexR + 1.0 - qOff) / sqrt3).ceil() + 1;
      for (int r = rStart; r <= rEnd; r++) {
        final cy = bottom + hexR * (qOff + sqrt3 * r);
        _drawHex(canvas, cx, cy, hexR, 0.0);
      }
    }
  }

  void _drawPointyGrid(PdfGraphics canvas, double left, double right, double bottom, double top, double hexR) {
    final w = right - left;
    final h = top - bottom;
    final rowStep = hexR * 3.0 / 2.0;
    final sqrt3 = sqrt(3.0);

    final rStart = ((-hexR * 2) / rowStep).floor() - 1;
    final rEnd   = ((h + hexR * 2) / rowStep).ceil() + 1;

    for (int r = rStart; r <= rEnd; r++) {
      final cy   = bottom + rowStep * r;
      final rOff = sqrt3 / 2.0 * r;
      final qStart = ((-1.0 - rOff) / sqrt3).floor() - 1;
      final qEnd   = ((w / hexR + 1.0 - rOff) / sqrt3).ceil() + 1;
      for (int q = qStart; q <= qEnd; q++) {
        final cx = left + hexR * (sqrt3 * q + rOff);
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
