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

    final cellH = cellW * sqrt(3.0) / 2.0;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (double y = 0; y <= size.height + cellH; y += cellH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Diagonal shift: how far x moves from top to bottom for a 60° line
    final diag = size.height / sqrt(3.0);

    // Lines going lower-right (slope +√3): from (x0, 0) to (x0+diag, size.height)
    final nStart = ((-diag) / cellW).floor() - 1;
    final nEnd = (size.width / cellW).ceil() + 1;
    for (int n = nStart; n <= nEnd; n++) {
      final x0 = n * cellW;
      canvas.drawLine(Offset(x0, 0), Offset(x0 + diag, size.height), paint);
    }

    // Lines going lower-left (slope -√3): from (x0, 0) to (x0-diag, size.height)
    final n2Start = ((-size.width - diag) / cellW).floor() - 1;
    final n2End = ((size.width + diag) / cellW).ceil() + 1;
    for (int n = n2Start; n <= n2End; n++) {
      final x0 = n * cellW;
      canvas.drawLine(Offset(x0, 0), Offset(x0 - diag, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(IsometricLayerPainter old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity;
}
