import 'dart:math';
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class LogGridLayerPainter extends CustomPainter {
  const LogGridLayerPainter({
    required this.config,
    required this.pageConfig,
    required this.color,
    this.opacity = 1.0,
  });

  final LogGridLayerConfig config;
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

    final paintThin = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;

    final paintBold = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    // X axis
    if (config.xScale == LogScale.log) {
      _drawLogAxis(canvas, clip, config.xDecades, horizontal: false,
          paintThin: paintThin, paintBold: paintBold);
    } else {
      _drawLinearAxis(canvas, clip, horizontal: false, paint: paintThin);
    }

    // Y axis
    if (config.yScale == LogScale.log) {
      _drawLogAxis(canvas, clip, config.yDecades, horizontal: true,
          paintThin: paintThin, paintBold: paintBold);
    } else {
      _drawLinearAxis(canvas, clip, horizontal: true, paint: paintThin);
    }

    canvas.restore();
  }

  // Draws vertical (horizontal:false) or horizontal (horizontal:true) log-scale lines.
  // Each decade is divided by log10(1..9) fractions.
  void _drawLogAxis(
    Canvas canvas,
    Rect clip,
    int decades,
    {required bool horizontal,
    required Paint paintThin,
    required Paint paintBold}
  ) {
    final length = horizontal ? clip.height : clip.width;
    final decadeSize = length / decades;

    for (int d = 0; d <= decades; d++) {
      // Major line at decade boundary
      final pos = horizontal
          ? clip.top + d * decadeSize
          : clip.left + d * decadeSize;
      _drawLine(canvas, clip, pos, horizontal, paintBold);

      if (d < decades) {
        // 8 minor lines within the decade at log10(2)..log10(9)
        for (int i = 2; i <= 9; i++) {
          final offset = log(i) / log(10) * decadeSize;
          final mpos = horizontal
              ? clip.top + d * decadeSize + offset
              : clip.left + d * decadeSize + offset;
          _drawLine(canvas, clip, mpos, horizontal, paintThin);
        }
      }
    }
  }

  // Equally-spaced lines for linear scale (5mm spacing)
  void _drawLinearAxis(Canvas canvas, Rect clip,
      {required bool horizontal, required Paint paint}) {
    const stepMm = 5.0;
    // Reuse clip dimensions to derive step in px
    final paperWidthMm = pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final scale = scaleFactor(
      horizontal ? clip.height / (clip.height / clip.width) : clip.width,
      paperWidthMm,
    );
    final step = mmToPx(stepMm, scale);
    final length = horizontal ? clip.height : clip.width;
    final origin = horizontal ? clip.top : clip.left;
    final offset = (length % step) / 2;

    for (double p = origin + offset; p <= origin + length + 0.5; p += step) {
      _drawLine(canvas, clip, p, horizontal, paint);
    }
  }

  void _drawLine(Canvas canvas, Rect clip, double pos, bool horizontal, Paint paint) {
    if (horizontal) {
      canvas.drawLine(Offset(clip.left, pos), Offset(clip.right, pos), paint);
    } else {
      canvas.drawLine(Offset(pos, clip.top), Offset(pos, clip.bottom), paint);
    }
  }

  @override
  bool shouldRepaint(LogGridLayerPainter old) =>
      old.config != config ||
      old.pageConfig != pageConfig ||
      old.color != color ||
      old.opacity != opacity;
}
