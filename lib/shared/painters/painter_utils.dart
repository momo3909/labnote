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
  return Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;
}

/// 水平・垂直線専用の破線描画（axis-aligned のみ）。
/// [isHorizontal] が true なら start→end は水平方向、false なら垂直方向。
void drawDashHVLine(
  Canvas canvas,
  Offset start,
  Offset end,
  Paint paint,
  LineStyle style,
) {
  if (style == LineStyle.solid) {
    canvas.drawLine(start, end, paint);
    return;
  }
  final dashLen = style == LineStyle.dotted ? 1.5 : 4.0;
  final gapLen  = style == LineStyle.dotted ? 2.0 : 3.0;
  final isH = (end.dx - start.dx).abs() > (end.dy - start.dy).abs();
  final total = isH ? (end.dx - start.dx).abs() : (end.dy - start.dy).abs();
  final sign  = isH
      ? (end.dx >= start.dx ? 1.0 : -1.0)
      : (end.dy >= start.dy ? 1.0 : -1.0);
  double pos = 0;
  bool on = true;
  while (pos < total) {
    final next = (pos + (on ? dashLen : gapLen)).clamp(0.0, total);
    if (on) {
      final s = isH ? Offset(start.dx + pos * sign, start.dy)
                    : Offset(start.dx, start.dy + pos * sign);
      final e = isH ? Offset(start.dx + next * sign, start.dy)
                    : Offset(start.dx, start.dy + next * sign);
      canvas.drawLine(s, e, paint);
    }
    pos = next;
    on = !on;
  }
}
