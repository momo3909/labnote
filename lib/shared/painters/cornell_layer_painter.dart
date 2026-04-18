import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class CornellLayerPainter extends CustomPainter {
  const CornellLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final CornellLayerConfig config;
  final PageConfig pageConfig;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paperWidthMm = pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final scale = scaleFactor(size.width, paperWidthMm);
    final clip = contentRect(size, pageConfig, scale);
    if (clip.width <= 0 || clip.height <= 0) return;

    canvas.save();
    canvas.clipRect(clip);

    final leftColW = mmToPx(config.leftColMm, scale);
    final bottomRowH = mmToPx(config.bottomRowMm, scale);
    final lineSpacing = mmToPx(config.lineSpacingMm, scale);

    final dividerX = clip.left + leftColW;   // vertical divider
    final dividerY = clip.bottom - bottomRowH; // horizontal divider

    final paintLine = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;

    final paintDivider = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal ruled lines in main area (top-right region)
    if (lineSpacing > 0) {
      final mainTop = clip.top;
      final mainBottom = dividerY;
      final offsetY = (mainBottom - mainTop) % lineSpacing / 2;
      for (double y = mainTop + offsetY + lineSpacing;
          y <= mainBottom - 1;
          y += lineSpacing) {
        canvas.drawLine(Offset(dividerX, y), Offset(clip.right, y), paintLine);
      }
    }

    // Vertical divider line
    canvas.drawLine(Offset(dividerX, clip.top), Offset(dividerX, dividerY), paintDivider);

    // Horizontal divider line (above summary)
    canvas.drawLine(Offset(clip.left, dividerY), Offset(clip.right, dividerY), paintDivider);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CornellLayerPainter old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity;
}
