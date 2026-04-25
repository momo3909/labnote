import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/layer_region.dart';
import 'cornell_layer_pdf_renderer.dart';
import 'dot_layer_pdf_renderer.dart';
import 'grid_layer_pdf_renderer.dart';
import 'guide_layer_pdf_renderer.dart';
import 'hex_layer_pdf_renderer.dart';
import 'manuscript_layer_pdf_renderer.dart';
import 'polar_layer_pdf_renderer.dart';
import 'timetable_layer_pdf_renderer.dart';
import 'isometric_layer_pdf_renderer.dart';
import 'layer_pdf_renderer_base.dart';
import 'log_grid_layer_pdf_renderer.dart';

class RegionLayerPdfRenderer extends LayerPdfRendererBase<RegionLayerConfig> {
  const RegionLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  pw.Widget build() {
    if (config.regions.isEmpty) return pw.SizedBox.shrink();
    return pw.Stack(
      children: config.regions.map((r) {
        final sub = LayerRegion(x: r.xRatio, y: r.yRatio, width: r.widthRatio, height: r.heightRatio);
        return _buildSub(r.layerConfig, sub);
      }).toList(),
    );
  }

  pw.Widget _buildSub(LayerConfig lc, LayerRegion sub) => switch (lc) {
    GridLayerConfig c => GridLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    HexLayerConfig c => HexLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    IsometricLayerConfig c => IsometricLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    DotLayerConfig c => DotLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    LogGridLayerConfig c => LogGridLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    CornellLayerConfig c => CornellLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    GuideLayerConfig c => GuideLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    PolarLayerConfig c => PolarLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    ManuscriptLayerConfig c => ManuscriptLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    TimetableLayerConfig c => TimetableLayerPdfRenderer(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
    RegionLayerConfig() => pw.SizedBox.shrink(),
  };

  @override
  void paintContent(PdfGraphics canvas, {required double left, required double right, required double bottom, required double top}) {}
}
