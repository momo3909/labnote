import 'dart:math' show max;
import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import 'layer_painter_base.dart';
import 'painter_utils.dart';

class HeaderLayerPainter extends LayerPainterBase<HeaderLayerConfig> {
  const HeaderLayerPainter({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(Canvas canvas, Rect clip, double scale) {
    final fields = _activeFields(config);
    if (fields.isEmpty) return;

    final rowH = mmToPx(config.rowHeightMm, scale);
    if (rowH < 2) return; // 描画に必要な最小高さに満たない場合はスキップ
    final colW = clip.width / 2;
    if (colW < 4) return;
    final fontSize = mmToPx(config.fontSizeMm, scale).clamp(2.0, max(2.0, rowH * 0.65)).toDouble();
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final textStyle = TextStyle(
      fontSize: fontSize,
      color: color.withValues(alpha: opacity),
    );

    // 2列レイアウト: 奇数インデックスが左列、偶数インデックスが右列
    for (var i = 0; i < fields.length; i++) {
      final col = i % 2;
      final row = i ~/ 2;
      final cellLeft = clip.left + col * colW;
      final cellTop = clip.top + row * rowH;
      final cellRect = Rect.fromLTWH(cellLeft, cellTop, colW, rowH);

      if (config.showBorder) {
        canvas.drawRect(cellRect, paint);
      }

      // ラベルテキスト
      final tp = TextPainter(
        text: TextSpan(text: fields[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: colW - 8);
      tp.paint(canvas, Offset(cellLeft + 4, cellTop + 4));

      // 記入欄下線
      final lineY = cellTop + rowH - 4;
      canvas.drawLine(
        Offset(cellLeft + 4, lineY),
        Offset(cellLeft + colW - 4, lineY),
        paint,
      );
    }
  }
}

List<String> _activeFields(HeaderLayerConfig c) => [
      if (c.showTitle) c.titleLabel,
      if (c.showDate) c.dateLabel,
      if (c.showName) c.nameLabel,
      if (c.showSubject) c.subjectLabel,
    ];
