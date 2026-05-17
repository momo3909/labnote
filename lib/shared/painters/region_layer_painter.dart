import 'package:flutter/material.dart';
import '../../core/constants/print_constants.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import 'cornell_layer_painter.dart';
import 'dot_layer_painter.dart';
import 'grid_layer_painter.dart';
import 'guide_layer_painter.dart';
import 'hex_layer_painter.dart';
import 'manuscript_layer_painter.dart';
import 'polar_layer_painter.dart';
import 'timetable_layer_painter.dart';
import 'isometric_layer_painter.dart';
import 'log_grid_layer_painter.dart';
import 'ruled_grid_layer_painter.dart';
import 'staff_layer_painter.dart';
import 'stamp_layer_painter.dart';

class RegionLayerPainter extends CustomPainter {
  const RegionLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
    this.region = LayerRegion.full,
  });

  final RegionLayerConfig config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;
  final LayerRegion region;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = scaleFactor(size.width, pageConfig.effectiveWidthMm);
    final content = contentRect(size, pageConfig, scale);
    final outerClip = layerRegionRect(content, region);
    if (outerClip.width <= 0 || outerClip.height <= 0) return;

    // 外側レイヤーの領域でクリップ（ドラッグ/ピンチでの移動・リサイズを反映）
    canvas.save();
    canvas.clipRect(outerClip);
    // サブレイヤーが外側リージョンと一緒に動くよう、content 原点からの差分だけ移動する。
    // region が full(0,0,1,1) の場合は translate(0,0) となり既存挙動と同一。
    canvas.translate(outerClip.left - content.left, outerClip.top - content.top);
    for (final r in config.regions) {
      final sub = LayerRegion(x: r.xRatio, y: r.yRatio, width: r.widthRatio, height: r.heightRatio);
      _painter(r.layerConfig, sub)?.paint(canvas, size);
    }
    canvas.restore();
  }

  CustomPainter? _painter(LayerConfig lc, LayerRegion sub) => switch (lc) {
    GridLayerConfig c => GridLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    HexLayerConfig c => HexLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    IsometricLayerConfig c => IsometricLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    DotLayerConfig c => DotLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    LogGridLayerConfig c => LogGridLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    CornellLayerConfig c => CornellLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    GuideLayerConfig c => GuideLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    PolarLayerConfig c => PolarLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    ManuscriptLayerConfig c => ManuscriptLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    TimetableLayerConfig c => TimetableLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    RegionLayerConfig() => null,
    StaffLayerConfig c => StaffLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    RuledGridLayerConfig c => RuledGridLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    StampLayerConfig c => StampLayerPainter(config: c, pageConfig: pageConfig, color: color, opacity: opacity, region: sub),
    GraphAxisLayerConfig() => null,
    TableLayerConfig() => null,
    CustomLineLayerConfig() => null,

    HeaderLayerConfig() => null,
  };

  @override
  bool shouldRepaint(RegionLayerPainter old) =>
      old.config != config || old.pageConfig != pageConfig ||
      old.color != color || old.opacity != opacity || old.region != region;
}
