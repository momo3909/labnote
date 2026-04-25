import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/layer_region.dart';
import '../models/page_config.dart';
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

class RegionLayerPainter extends CustomPainter {
  const RegionLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final RegionLayerConfig config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in config.regions) {
      final sub = LayerRegion(x: r.xRatio, y: r.yRatio, width: r.widthRatio, height: r.heightRatio);
      _painter(r.layerConfig, sub)?.paint(canvas, size);
    }
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
  };

  @override
  bool shouldRepaint(RegionLayerPainter old) =>
      old.config != config || old.pageConfig != pageConfig ||
      old.color != color || old.opacity != opacity;
}
