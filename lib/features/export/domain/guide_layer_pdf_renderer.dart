import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class GuideLayerPdfRenderer extends LayerPdfRendererBase<GuideLayerConfig> {
  const GuideLayerPdfRenderer({
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
    switch (config.guideType) {
      case GuideType.axis:
        _paintAxis(canvas, left: left, right: right, bottom: bottom, top: top);
      case GuideType.bondAngle60:
        _paintAngles(canvas, const [0, 60, 120], left: left, right: right, bottom: bottom, top: top);
      case GuideType.bondAngle109:
        _paintAngles(canvas, const [0, 109.47, 229.47, 349.47], left: left, right: right, bottom: bottom, top: top);
      case GuideType.bondAngle120:
        _paintAngles(canvas, const [90, 210, 330], left: left, right: right, bottom: bottom, top: top);
      case GuideType.scale:
        _paintScale(canvas, left: left, right: right, bottom: bottom, top: top);
    }
  }

  void _setup(PdfGraphics canvas) {
    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);
  }

  void _paintAxis(PdfGraphics canvas, {required double left, required double right, required double bottom, required double top}) {
    _setup(canvas);
    final cx = (left + right) / 2;
    final cy = (bottom + top) / 2;
    canvas.moveTo(cx, bottom); canvas.lineTo(cx, top); canvas.strokePath();
    canvas.moveTo(left, cy); canvas.lineTo(right, cy); canvas.strokePath();
  }

  void _paintAngles(PdfGraphics canvas, List<double> degList, {required double left, required double right, required double bottom, required double top}) {
    _setup(canvas);
    final cx = (left + right) / 2;
    final cy = (bottom + top) / 2;
    final w = right - left;
    final h = top - bottom;
    final r = math.sqrt(w * w + h * h);
    for (final deg in degList) {
      final rad = deg * math.pi / 180;
      final dx = math.cos(rad) * r;
      final dy = math.sin(rad) * r;
      canvas.moveTo(cx - dx, cy - dy);
      canvas.lineTo(cx + dx, cy + dy);
      canvas.strokePath();
    }
  }

  void _paintScale(PdfGraphics canvas, {required double left, required double right, required double bottom, required double top}) {
    _setup(canvas);
    final intervalPts = toPoints(10.0);
    final y = bottom + toPoints(3.0);
    final tickH = toPoints(2.5);
    final halfH = tickH / 2;

    canvas.moveTo(left, y); canvas.lineTo(right, y); canvas.strokePath();
    int tick = 0;
    for (double x = left; x <= right + 0.5; x += intervalPts) {
      final h = tick % 5 == 0 ? tickH : halfH;
      canvas.moveTo(x, y); canvas.lineTo(x, y + h); canvas.strokePath();
      tick++;
    }
  }
}
