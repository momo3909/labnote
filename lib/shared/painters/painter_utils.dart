import 'package:flutter/material.dart';
import '../../core/constants/print_constants.dart';
import '../models/layer_config.dart';

double scaleFactor(double canvasWidthPx, double paperWidthMm) {
  return canvasWidthPx / (paperWidthMm * mmToPt);
}

double mmToPx(double mm, double scale) => mm * mmToPt * scale;

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
