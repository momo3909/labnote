import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/page_config.dart';

class HoleMarksPdfRenderer {
  const HoleMarksPdfRenderer({required this.pageConfig});

  final PageConfig pageConfig;

  pw.Widget build() {
    if (pageConfig.holeConfig == HoleConfig.none) return pw.SizedBox.shrink();

    return pw.CustomPaint(
      painter: (canvas, size) => _paint(canvas, size),
      size: PdfPoint(toPoints(pageConfig.effectiveWidthMm), toPoints(pageConfig.effectiveHeightMm)),
    );
  }

  void _paint(PdfGraphics canvas, PdfPoint size) {
    final holeCount = pageConfig.holeConfig == HoleConfig.h26 ? 26 : 30;

    final cx = toPoints(holeCenterXMm);
    final radius = toPoints(holeRadiusMm);
    // PDF y-up: topY in PDF coords = size.y - holeEdgeTopMm(pts)
    final topY = size.y - toPoints(holeEdgeTopMm);
    final bottomY = toPoints(holeEdgeBottomMm);
    final span = topY - bottomY;
    final spacing = span / (holeCount - 1);

    for (int i = 0; i < holeCount; i++) {
      final y = topY - spacing * i; // PDF y-up: 上から下へ
      // 白塗り円
      canvas.setFillColor(PdfColors.white);
      canvas.drawEllipse(cx - radius, y - radius, radius * 2, radius * 2);
      canvas.fillPath();
      // ストローク
      canvas.setStrokeColor(const PdfColor.fromInt(0xFFCCCCCC));
      canvas.setLineWidth(0.3);
      canvas.drawEllipse(cx - radius, y - radius, radius * 2, radius * 2);
      canvas.strokePath();
    }

    // 余白ガイドライン
    final leftMarginX = toPoints(pageConfig.marginLeftMm);
    canvas.setStrokeColor(const PdfColor.fromInt(0xFFEEEEEE));
    canvas.setLineWidth(0.3);
    canvas.moveTo(leftMarginX, 0);
    canvas.lineTo(leftMarginX, size.y);
    canvas.strokePath();
  }
}
