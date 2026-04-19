import 'dart:math' show max;
import 'package:flutter/material.dart';
import '../../core/constants/print_constants.dart';
import '../models/layer_config.dart';
import '../models/layer_region.dart';
import '../models/page_config.dart';

export '../models/layer_region.dart';

double scaleFactor(double canvasWidthPx, double paperWidthMm) {
  return canvasWidthPx / (paperWidthMm * mmToPt);
}

double mmToPx(double mm, double scale) => mm * mmToPt * scale;

/// 穴マーク分だけ左余白を広げた実効左余白 (mm)
double effectiveMarginLeftMm(PageConfig pageConfig) {
  if (pageConfig.holeConfig == HoleConfig.none) return pageConfig.marginLeftMm;
  const minLeft = holeCenterXMm + holeRadiusMm + 2.0; // 17mm
  return max(pageConfig.marginLeftMm, minLeft);
}

/// 余白・穴マークを考慮したコンテンツ領域
Rect contentRect(Size size, PageConfig pageConfig, double scale) {
  return Rect.fromLTRB(
    mmToPx(effectiveMarginLeftMm(pageConfig), scale),
    mmToPx(pageConfig.marginTopMm, scale),
    size.width - mmToPx(pageConfig.marginRightMm, scale),
    size.height - mmToPx(pageConfig.marginBottomMm, scale),
  );
}

/// content 内の layerRegion に対応する実際の Rect
Rect layerRegionRect(Rect content, LayerRegion region) {
  return Rect.fromLTWH(
    content.left + content.width * region.x,
    content.top + content.height * region.y,
    content.width * region.width,
    content.height * region.height,
  );
}

/// '#RRGGBB' または '#AARRGGBB' 形式の hex 文字列を Color に変換する
Color colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return Color(value);
}

Paint buildLinePaint(LineStyle style, Color color, double strokeWidth) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  if (style == LineStyle.dashed || style == LineStyle.dotted) {
    // CustomPainter側でPath.dashPath相当の処理を行う
    // DashPatternはPainterに委譲
  }
  return paint;
}
