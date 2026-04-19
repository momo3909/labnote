import 'package:flutter/material.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class HoleMarksPainter extends CustomPainter {
  const HoleMarksPainter({
    required this.pageConfig,
  });

  final PageConfig pageConfig;

  @override
  void paint(Canvas canvas, Size size) {
    if (pageConfig.holeConfig == HoleConfig.none) return;

    final paperWidthMm = pageConfig.paperSize.widthMm;
    final scale = scaleFactor(size.width, paperWidthMm);

    final holeCount = pageConfig.holeConfig == HoleConfig.h26 ? 26 : 30;
    final cx = mmToPx(holeCenterXMm, scale);
    final radius = mmToPx(holeRadiusMm, scale);
    final topY = mmToPx(holeEdgeTopMm, scale);
    final bottomY = size.height - mmToPx(holeEdgeBottomMm, scale);
    final span = bottomY - topY;
    final spacing = span / (holeCount - 1);

    // 穴の外枠（白塗り + 薄いストローク）
    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 余白エリアを示す縦の薄いライン（オプション：なくても可）
    final paintGuide = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final leftMarginX = mmToPx(pageConfig.marginLeftMm, scale);
    canvas.drawLine(Offset(leftMarginX, 0), Offset(leftMarginX, size.height), paintGuide);

    for (int i = 0; i < holeCount; i++) {
      final y = topY + spacing * i;
      final center = Offset(cx, y);
      canvas.drawCircle(center, radius, paintFill);
      canvas.drawCircle(center, radius, paintStroke);
    }
  }

  @override
  bool shouldRepaint(HoleMarksPainter old) => old.pageConfig != pageConfig;
}
