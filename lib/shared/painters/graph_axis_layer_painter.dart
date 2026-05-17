import 'dart:math' show sqrt;
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class GraphAxisLayerPainter extends LayerPainterBase<GraphAxisLayerConfig> {
  const GraphAxisLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = (scale * 0.35).clamp(0.8, 2.5)
      ..style = PaintingStyle.stroke;
    final tickPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.7)
      ..strokeWidth = (scale * 0.2).clamp(0.5, 1.5)
      ..style = PaintingStyle.stroke;

    final tickLen = mmToPx(config.tickLengthMm, scale);
    final tickInterval = mmToPx(config.tickIntervalMm, scale);
    final arrowSize = mmToPx(3.0, scale);

    // 原点位置
    final ox = config.showNegative ? (clip.left + clip.right) / 2 : clip.left;
    final oy = config.showNegative ? (clip.top + clip.bottom) / 2 : clip.bottom;

    // X 軸
    if (config.showXAxis) {
      final xStart = config.showNegative ? clip.left : ox;
      final xEnd = clip.right;
      canvas.drawLine(Offset(xStart, oy), Offset(xEnd, oy), paint);
      if (config.arrowTip) _arrowHead(canvas, Offset(xEnd - arrowSize, oy), Offset(xEnd, oy), arrowSize, paint);

      if (config.showTickMarks && tickInterval > 0) {
        final (xT0, xT1) = _xTickRange(oy, tickLen, config.xTickSide);
        double x = ox + tickInterval;
        while (x <= clip.right) {
          canvas.drawLine(Offset(x, xT0), Offset(x, xT1), tickPaint);
          x += tickInterval;
        }
        if (config.showNegative) {
          double xn = ox - tickInterval;
          while (xn >= clip.left) {
            canvas.drawLine(Offset(xn, xT0), Offset(xn, xT1), tickPaint);
            xn -= tickInterval;
          }
        }
      }

      if (config.xLabel.isNotEmpty) {
        _drawLabel(canvas, config.xLabel, Offset(xEnd - arrowSize * 1.5, oy + arrowSize * 1.2), scale);
      }
    }

    // Y 軸
    if (config.showYAxis) {
      final yStart = config.showNegative ? clip.bottom : oy;
      final yEnd = clip.top;
      canvas.drawLine(Offset(ox, yStart), Offset(ox, yEnd), paint);
      if (config.arrowTip) _arrowHead(canvas, Offset(ox, yEnd + arrowSize), Offset(ox, yEnd), arrowSize, paint);

      if (config.showTickMarks && tickInterval > 0) {
        final (yT0, yT1) = _yTickRange(ox, tickLen, config.yTickSide);
        double y = oy - tickInterval;
        while (y >= clip.top) {
          canvas.drawLine(Offset(yT0, y), Offset(yT1, y), tickPaint);
          y -= tickInterval;
        }
        if (config.showNegative) {
          double yn = oy + tickInterval;
          while (yn <= clip.bottom) {
            canvas.drawLine(Offset(yT0, yn), Offset(yT1, yn), tickPaint);
            yn += tickInterval;
          }
        }
      }

      if (config.yLabel.isNotEmpty) {
        _drawLabel(canvas, config.yLabel, Offset(ox + arrowSize * 0.4, yEnd + arrowSize * 1.2), scale);
      }
    }
  }

  // X軸目盛り: positive=上(oy-len)のみ, negative=下(oy+len)のみ, both=両側
  (double, double) _xTickRange(double oy, double len, TickSide side) => switch (side) {
    TickSide.positive => (oy - len, oy),
    TickSide.negative => (oy, oy + len),
    TickSide.both     => (oy - len, oy + len),
  };

  // Y軸目盛り: positive=右(ox+len)のみ, negative=左(ox-len)のみ, both=両側
  (double, double) _yTickRange(double ox, double len, TickSide side) => switch (side) {
    TickSide.positive => (ox, ox + len),
    TickSide.negative => (ox - len, ox),
    TickSide.both     => (ox - len, ox + len),
  };

  void _arrowHead(Canvas canvas, Offset from, Offset to, double size, Paint paint) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    final wing = size * 0.4;
    canvas.drawLine(to, Offset(to.dx - ux * size - uy * wing, to.dy - uy * size + ux * wing), paint);
    canvas.drawLine(to, Offset(to.dx - ux * size + uy * wing, to.dy - uy * size - ux * wing), paint);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double scale) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: opacity),
          fontSize: mmToPx(3.0, scale).clamp(8.0, 18.0),
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }
}
