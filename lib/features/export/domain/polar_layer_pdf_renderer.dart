import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';

class PolarLayerPdfRenderer extends LayerPdfRendererBase<PolarLayerConfig> {
  const PolarLayerPdfRenderer({
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
    final cx = (left + right) / 2;
    final cy = (bottom + top) / 2;
    final maxR = math.min(right - left, top - bottom) / 2;
    final ringStep = maxR / config.rings;

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.3);

    // 同心円
    for (int i = 1; i <= config.rings; i++) {
      final r = ringStep * i;
      canvas.drawEllipse(cx, cy, r, r);
      canvas.strokePath();
    }

    // 放射線
    final outerR = ringStep * config.rings;
    for (int i = 0; i < config.sectors; i++) {
      final angle = 2 * math.pi * i / config.sectors;
      final dx = math.cos(angle) * outerR;
      final dy = math.sin(angle) * outerR;
      canvas.moveTo(cx, cy);
      canvas.lineTo(cx + dx, cy + dy);
      canvas.strokePath();
    }
  }
}
