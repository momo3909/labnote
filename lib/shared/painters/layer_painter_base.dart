import 'package:flutter/material.dart';
import '../../core/constants/print_constants.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';

abstract class LayerPainterBase<C extends LayerConfig> extends CustomPainter {
  const LayerPainterBase({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
    this.region = LayerRegion.full,
  });

  final C config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;
  final LayerRegion region;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = scaleFactor(size.width, pageConfig.paperSize.widthMm);
    final content = contentRect(size, pageConfig, scale);
    final clip = layerRegionRect(content, region);
    if (clip.width <= 0 || clip.height <= 0) return;
    canvas.save();
    canvas.clipRect(clip);
    paintContent(canvas, clip, scale);
    canvas.restore();
  }

  void paintContent(Canvas canvas, Rect clip, double scale);

  @override
  bool shouldRepaint(covariant LayerPainterBase<C> old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity ||
      old.region != region;
}
