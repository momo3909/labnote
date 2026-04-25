import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

const _dayLabels = ['月', '火', '水', '木', '金', '土', '日'];

class TimetableLayerPainter extends LayerPainterBase<TimetableLayerConfig> {
  const TimetableLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final slots = config.endHour - config.startHour;
    if (slots <= 0 || config.daysCount <= 0) return;

    final headerH = mmToPx(7.0, scale);
    final timeColW = mmToPx(11.0, scale);
    final gridLeft = clip.left + timeColW;
    final gridTop = clip.top + headerH;
    final colW = (clip.right - gridLeft) / config.daysCount;
    final rowH = (clip.bottom - gridTop) / slots;

    final lineC = color.withValues(alpha: opacity);
    final thin = Paint()..color = lineC..strokeWidth = 0.4..style = PaintingStyle.stroke;
    final thick = Paint()..color = lineC..strokeWidth = 0.7..style = PaintingStyle.stroke;

    // 外枠
    canvas.drawRect(Rect.fromLTRB(clip.left, clip.top, clip.right, clip.bottom), thick);

    // ヘッダー横線
    canvas.drawLine(Offset(clip.left, gridTop), Offset(clip.right, gridTop), thick);
    // 時刻列縦線
    canvas.drawLine(Offset(gridLeft, clip.top), Offset(gridLeft, clip.bottom), thick);

    // 縦線 (各日)
    for (int d = 1; d < config.daysCount; d++) {
      final x = gridLeft + colW * d;
      canvas.drawLine(Offset(x, clip.top), Offset(x, clip.bottom), thin);
    }

    // 横線 (各コマ)
    for (int s = 1; s < slots; s++) {
      final y = gridTop + rowH * s;
      canvas.drawLine(Offset(clip.left, y), Offset(clip.right, y), thin);
    }

    final labelColor = color.withValues(alpha: opacity * 0.85);

    // 曜日ラベル
    final dayFontSize = (colW * 0.35).clamp(6.0, 14.0);
    for (int d = 0; d < config.daysCount; d++) {
      _drawCenteredText(
        canvas,
        _dayLabels[d],
        Rect.fromLTWH(gridLeft + colW * d, clip.top, colW, headerH),
        dayFontSize,
        labelColor,
      );
    }

    // 時刻ラベル
    final timeFontSize = (rowH * 0.30).clamp(5.0, 10.0);
    for (int s = 0; s < slots; s++) {
      _drawCenteredText(
        canvas,
        '${config.startHour + s}',
        Rect.fromLTWH(clip.left, gridTop + rowH * s, timeColW, rowH),
        timeFontSize,
        labelColor,
      );
    }
  }

  void _drawCenteredText(Canvas canvas, String text, Rect box, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color, height: 1.0)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: box.width);
    tp.paint(canvas, Offset(
      box.left + (box.width - tp.width) / 2,
      box.top + (box.height - tp.height) / 2,
    ));
  }
}
