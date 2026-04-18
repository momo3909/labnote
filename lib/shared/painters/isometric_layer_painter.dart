import 'dart:math';
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class IsometricLayerPainter extends CustomPainter {
  const IsometricLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final IsometricLayerConfig config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paperWidthMm = pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final scale = scaleFactor(size.width, paperWidthMm);
    final cellW = mmToPx(config.spacingMm, scale);
    if (cellW <= 0) return;

    final clip = contentRect(size, pageConfig, scale);
    canvas.save();
    canvas.clipRect(clip);

    final cellH = cellW * sqrt(3.0) / 2.0;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (double y = clip.top; y <= clip.bottom + cellH; y += cellH) {
      canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), paint);
    }

    // Diagonal shift: how far x moves from top to bottom for a 60° line
    final diagH = clip.height / sqrt(3.0);

    // Lines going lower-right (slope +√3)
    final nStart = (((clip.left - diagH) - clip.left) / cellW).floor() - 1;
    final nEnd = ((clip.right - clip.left) / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = clip.left + n * cellW;
      canvas.drawLine(Offset(x0, clip.top), Offset(x0 + diagH, clip.bottom), paint);
    }

    // Lines going lower-left (slope -√3)
    final n2Start = ((-(clip.width + diagH)) / cellW).floor() - 1;
    final n2End = ((clip.width + diagH) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = clip.left + n * cellW;
      canvas.drawLine(Offset(x0, clip.top), Offset(x0 - diagH, clip.bottom), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(IsometricLayerPainter old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity;
}
