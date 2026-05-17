import 'package:flutter/material.dart';
import '../../core/constants/print_constants.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';
import 'stamp_shapes.dart';

class StampLayerPainter extends LayerPainterBase<StampLayerConfig> {
  const StampLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final paperW = mmToPx(pageConfig.effectiveWidthMm, scale);
    final paperH = mmToPx(pageConfig.effectiveHeightMm, scale);

    for (final item in config.items) {
      final cx = item.xRatio * paperW;
      final cy = item.yRatio * paperH;
      final wPx = mmToPx(item.widthMm > 0 ? item.widthMm : item.sizeMm, scale);
      final hPx = mmToPx(item.heightMm > 0 ? item.heightMm : item.sizeMm, scale);
      final itemColor = colorFromHex(item.colorHex);
      StampShapes.draw(canvas, item.shapeType, Offset(cx, cy), wPx, hPx, itemColor, opacity,
          rotation: item.rotation, strokeScale: item.strokeScale);
    }
  }
}
