import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/notebook_template.dart';
import '../models/page_config.dart';
import '../painters/cornell_layer_painter.dart';
import '../painters/dot_layer_painter.dart';
import '../painters/grid_layer_painter.dart';
import '../painters/guide_layer_painter.dart';
import '../painters/hex_layer_painter.dart';
import '../painters/hole_marks_painter.dart';
import '../painters/isometric_layer_painter.dart';
import '../painters/log_grid_layer_painter.dart';
import '../painters/manuscript_layer_painter.dart';
import '../painters/page_elements_painter.dart';
import '../painters/painter_utils.dart';
import '../painters/polar_layer_painter.dart';
import '../painters/region_layer_painter.dart';
import '../painters/timetable_layer_painter.dart';
import '../../core/constants/print_constants.dart';

/// PageConfig + layers から紙面プレビューを描画する共通ウィジェット。
/// EditorState に依存しないため Gallery などからも使える。
class LayerStackPreview extends StatelessWidget {
  const LayerStackPreview({
    super.key,
    required this.pageConfig,
    required this.layers,
    this.previewKey,
    this.padding = const EdgeInsets.all(16),
  });

  final PageConfig pageConfig;
  final List<LayerEntity> layers;
  final GlobalKey? previewKey;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final pc = pageConfig;
    return Center(
      child: Padding(
        padding: padding,
        child: AspectRatio(
          aspectRatio: pc.effectiveWidthMm / pc.effectiveHeightMm,
          child: RepaintBoundary(
            key: previewKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ...layers
                      .where((l) => l.isVisible)
                      .map((l) => SizedBox.expand(
                            child: _layerPaint(
                              l.config,
                              pc,
                              opacity: l.opacity,
                              color: colorFromHex(l.colorHex),
                              region: LayerRegion(
                                x: l.xRatio,
                                y: l.yRatio,
                                width: l.widthRatio,
                                height: l.heightRatio,
                              ),
                            ),
                          )),
                  if (pc.showPageNumber || pc.showLineNumbers)
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: PageElementsPainter(
                          pageConfig: pc,
                          layers: layers,
                          totalPages: pc.pageCount,
                        ),
                      ),
                    ),
                  if (pc.holeConfig != HoleConfig.none)
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: HoleMarksPainter(pageConfig: pc),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _layerPaint(
    LayerConfig? config,
    PageConfig pc, {
    double opacity = 1.0,
    Color color = const Color(0xFFCCCCCC),
    LayerRegion region = LayerRegion.full,
  }) =>
      switch (config) {
        GridLayerConfig() => CustomPaint(
            painter: GridLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        HexLayerConfig() => CustomPaint(
            painter: HexLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        IsometricLayerConfig() => CustomPaint(
            painter: IsometricLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        DotLayerConfig() => CustomPaint(
            painter: DotLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        LogGridLayerConfig() => CustomPaint(
            painter: LogGridLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        CornellLayerConfig() => CustomPaint(
            painter: CornellLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        PolarLayerConfig() => CustomPaint(
            painter: PolarLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        ManuscriptLayerConfig() => CustomPaint(
            painter: ManuscriptLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        TimetableLayerConfig() => CustomPaint(
            painter: TimetableLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        RegionLayerConfig() => CustomPaint(
            painter: RegionLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity)),
        GuideLayerConfig() => CustomPaint(
            painter: GuideLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        _ => const SizedBox.expand(),
      };
}
