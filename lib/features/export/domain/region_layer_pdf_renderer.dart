import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
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
import 'ruled_grid_layer_pdf_renderer.dart';
import 'staff_layer_pdf_renderer.dart';
import 'stamp_layer_pdf_renderer.dart';

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

    // Full-paper default: delegate to each sub-renderer's build()
    // to preserve text labels (Cornell, LogGrid, etc.)
    if (region == LayerRegion.full) {
      return pw.Stack(
        children: config.regions.map((r) {
          final sub = LayerRegion(
              x: r.xRatio, y: r.yRatio, width: r.widthRatio, height: r.heightRatio);
          return _buildSub(r.layerConfig, sub);
        }).toList(),
      );
    }

    // Non-full outer region: super.build() applies outer clip → paintContent()
    return super.build();
  }

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    if (config.regions.isEmpty) return;

    // Full content dimensions for computing sub-region spacing
    final cLeft = toPoints(effectiveMarginLeftMm(pageConfig));
    final cRight =
        toPoints(pageConfig.effectiveWidthMm) - toPoints(pageConfig.marginRightMm);
    final cBottom = toPoints(pageConfig.marginBottomMm);
    final cTop =
        toPoints(pageConfig.effectiveHeightMm) - toPoints(pageConfig.marginTopMm);
    final cW = cRight - cLeft;
    final cH = cTop - cBottom;

    for (final r in config.regions) {
      // Sub-bounds anchored to outer region's top-left (left, top)
      // so that sub-content moves with the outer LayerEntity when dragged.
      final subLeft = left + r.xRatio * cW;
      final subRight = subLeft + r.widthRatio * cW;
      final subTop = top - r.yRatio * cH;
      final subBottom = subTop - r.heightRatio * cH;

      if (subRight <= subLeft || subTop <= subBottom) continue;

      final renderer = _subRenderer(r.layerConfig);
      if (renderer == null) continue;

      canvas.saveContext();
      canvas.drawRect(subLeft, subBottom, subRight - subLeft, subTop - subBottom);
      canvas.clipPath();
      renderer.paintContent(
          canvas, left: subLeft, right: subRight, bottom: subBottom, top: subTop);
      canvas.restoreContext();
    }
  }

  pw.Widget _buildSub(LayerConfig lc, LayerRegion sub) => switch (lc) {
        GridLayerConfig c => GridLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        HexLayerConfig c => HexLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        IsometricLayerConfig c => IsometricLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        DotLayerConfig c => DotLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        LogGridLayerConfig c => LogGridLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        CornellLayerConfig c => CornellLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        GuideLayerConfig c => GuideLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        PolarLayerConfig c => PolarLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        ManuscriptLayerConfig c => ManuscriptLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        TimetableLayerConfig c => TimetableLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        RegionLayerConfig() => pw.SizedBox.shrink(),
        StaffLayerConfig c => StaffLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        RuledGridLayerConfig c => RuledGridLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        StampLayerConfig c => StampLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub).build(),
        GraphAxisLayerConfig() => pw.SizedBox.shrink(),
        TableLayerConfig() => pw.SizedBox.shrink(),
        CustomLineLayerConfig() => pw.SizedBox.shrink(),

        HeaderLayerConfig() => pw.SizedBox.shrink(),
      };

  // Used by paintContent() for non-full outer region. Note: text overlays from
  // renderers that override build() (Cornell, LogGrid) are not rendered in this path.
  LayerPdfRendererBase? _subRenderer(LayerConfig lc) => switch (lc) {
        GridLayerConfig c => GridLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        HexLayerConfig c => HexLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        IsometricLayerConfig c => IsometricLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        DotLayerConfig c => DotLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        LogGridLayerConfig c => LogGridLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        CornellLayerConfig c => CornellLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        GuideLayerConfig c => GuideLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        PolarLayerConfig c => PolarLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        ManuscriptLayerConfig c => ManuscriptLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        TimetableLayerConfig c => TimetableLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        RegionLayerConfig() => null,
        StaffLayerConfig c => StaffLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        RuledGridLayerConfig c => RuledGridLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        StampLayerConfig c => StampLayerPdfRenderer(
            config: c, pageConfig: pageConfig, color: color, opacity: opacity),
        GraphAxisLayerConfig() => null,
        TableLayerConfig() => null,
        CustomLineLayerConfig() => null,

        HeaderLayerConfig() => null,
      };
}
