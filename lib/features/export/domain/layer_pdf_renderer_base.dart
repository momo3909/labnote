import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/layer_region.dart';
import '../../../shared/models/page_config.dart';

abstract class LayerPdfRendererBase<C extends LayerConfig> {
  const LayerPdfRendererBase({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
    this.region = const LayerRegion(),
  });

  final C config;
  final PageConfig pageConfig;
  final PdfColor color;
  final double opacity;
  final LayerRegion region;

  pw.Widget build() => pw.CustomPaint(
        painter: (canvas, size) => _paint(canvas, size),
        size: PdfPoint(
          toPoints(pageConfig.effectiveWidthMm),
          toPoints(pageConfig.effectiveHeightMm),
        ),
      );

  void _paint(PdfGraphics canvas, PdfPoint size) {
    final cLeft = toPoints(effectiveMarginLeftMm(pageConfig));
    final cRight = size.x - toPoints(pageConfig.marginRightMm);
    final cBottom = toPoints(pageConfig.marginBottomMm);
    final cTop = size.y - toPoints(pageConfig.marginTopMm);
    final cW = cRight - cLeft;
    final cH = cTop - cBottom;
    final left = cLeft + cW * region.x;
    final right = left + cW * region.width;
    final bottom = cTop - cH * (region.y + region.height);
    final top = bottom + cH * region.height;
    if (right <= left || top <= bottom) return;

    canvas.saveContext();
    canvas.drawRect(left, bottom, right - left, top - bottom);
    canvas.clipPath();
    paintContent(canvas, left: left, right: right, bottom: bottom, top: top);
    canvas.restoreContext();
  }

  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  });
}
