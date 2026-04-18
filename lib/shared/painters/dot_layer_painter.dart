import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class DotLayerPainter extends CustomPainter {
  const DotLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final DotLayerConfig config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paperWidthMm = pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final scale = scaleFactor(size.width, paperWidthMm);
    final spacing = mmToPx(config.spacingMm, scale);
    final radius = mmToPx(config.dotRadiusMm, scale);
    if (spacing <= 0 || radius <= 0) return;

    final clip = contentRect(size, pageConfig, scale);
    canvas.save();
    canvas.clipRect(clip);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Center dots in content area
    final offsetX = (clip.width % spacing) / 2;
    final offsetY = (clip.height % spacing) / 2;

    for (double x = clip.left + offsetX; x <= clip.right + 0.5; x += spacing) {
      for (double y = clip.top + offsetY; y <= clip.bottom + 0.5; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(DotLayerPainter old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity;
}
