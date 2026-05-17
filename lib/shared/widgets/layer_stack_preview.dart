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
import '../painters/ruled_grid_layer_painter.dart';
import '../painters/staff_layer_painter.dart';
import '../painters/graph_axis_layer_painter.dart';
import '../painters/table_layer_painter.dart';
import '../painters/custom_line_layer_painter.dart';

import '../painters/header_layer_painter.dart';
import '../painters/stamp_layer_painter.dart';
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
    this.paperKey,
    this.overlayChild,
    this.padding = const EdgeInsets.all(16),
  });

  final PageConfig pageConfig;
  final List<LayerEntity> layers;
  final GlobalKey? previewKey;
  final GlobalKey? paperKey;
  final Widget? overlayChild;
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
              key: paperKey,
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
                      .expand((l) {
                        final region = LayerRegion(
                          x: l.xRatio,
                          y: l.yRatio,
                          width: l.widthRatio,
                          height: l.heightRatio,
                        );
                        return [
                          if (l.bgColorHex.isNotEmpty)
                            SizedBox.expand(
                              child: CustomPaint(
                                painter: _BgRegionPainter(
                                  pageConfig: pc,
                                  region: region,
                                  color: colorFromHex(l.bgColorHex),
                                ),
                              ),
                            ),
                          SizedBox.expand(
                            child: _layerPaint(
                              l.config,
                              pc,
                              opacity: l.opacity,
                              color: colorFromHex(l.colorHex),
                              region: region,
                            ),
                          ),
                        ];
                      }),
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
                  if (overlayChild != null)
                    Positioned.fill(child: overlayChild!),
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
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        GuideLayerConfig() => CustomPaint(
            painter: GuideLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        StaffLayerConfig() => CustomPaint(
            painter: StaffLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        RuledGridLayerConfig() => CustomPaint(
            painter: RuledGridLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        StampLayerConfig() => CustomPaint(
            painter: StampLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        CustomLineLayerConfig() => CustomPaint(
            painter: CustomLineLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        GraphAxisLayerConfig() => CustomPaint(
            painter: GraphAxisLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        TableLayerConfig() => CustomPaint(
            painter: TableLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),

        HeaderLayerConfig() => CustomPaint(
            painter: HeaderLayerPainter(
                config: config, pageConfig: pc, color: color, opacity: opacity, region: region)),
        _ => const SizedBox.expand(),
      };
}

class _BgRegionPainter extends CustomPainter {
  const _BgRegionPainter({
    required this.pageConfig,
    required this.region,
    required this.color,
  });
  final PageConfig pageConfig;
  final LayerRegion region;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = scaleFactor(size.width, pageConfig.effectiveWidthMm);
    final content = contentRect(size, pageConfig, scale);
    final clip = layerRegionRect(content, region);
    canvas.drawRect(clip, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BgRegionPainter old) =>
      old.color != color || old.region != region || old.pageConfig != pageConfig;
}
