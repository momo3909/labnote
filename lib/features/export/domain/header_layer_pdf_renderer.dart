import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';
import 'pdf_font_store.dart';

class HeaderLayerPdfRenderer extends LayerPdfRendererBase<HeaderLayerConfig> {
  const HeaderLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    final fields = _activeFields(config);
    if (fields.isEmpty) return;

    final rowH = toPoints(config.rowHeightMm);
    final colW = (right - left) / 2;
    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.5);

    for (var i = 0; i < fields.length; i++) {
      final col = i % 2;
      final row = i ~/ 2;
      final cellLeft = left + col * colW;
      // PDF y軸上向き: 上端から row 行目 → y = top - (row+1)*rowH
      final cellBottom = top - (row + 1) * rowH;
      if (cellBottom < bottom) break;

      if (config.showBorder) {
        canvas.drawRect(cellLeft, cellBottom, colW, rowH);
        canvas.strokePath();
      }

      // 記入欄下線
      canvas.moveTo(cellLeft + 2, cellBottom + 4);
      canvas.lineTo(cellLeft + colW - 2, cellBottom + 4);
      canvas.strokePath();
    }
  }

  @override
  pw.Widget build() {
    final fields = _activeFields(config);
    if (fields.isEmpty) return super.build();

    final rowH = toPoints(config.rowHeightMm);
    final fontSize = toPoints(config.fontSizeMm).clamp(4.0, rowH * 0.65);
    final totalW = toPoints(pageConfig.effectiveWidthMm);
    final totalH = toPoints(pageConfig.effectiveHeightMm);
    final cLeft  = toPoints(effectiveMarginLeftMm(pageConfig));
    final cRight = totalW - toPoints(pageConfig.marginRightMm);
    final cTop   = toPoints(pageConfig.marginTopMm);
    final cBottom = totalH - toPoints(pageConfig.marginBottomMm);
    final cW = cRight - cLeft;
    final cH = cBottom - cTop;
    final rLeft = cLeft + cW * region.x;
    final rTop  = cTop  + cH * region.y;
    final colW  = cW * region.width / 2;

    return pw.Stack(
      children: [
        super.build(),
        for (var i = 0; i < fields.length; i++)
          if (rTop + (i ~/ 2) * rowH + rowH <= cBottom)
            pw.Positioned(
              left: rLeft + (i % 2) * colW + 2,
              top: rTop + (i ~/ 2) * rowH + 2,
              child: pw.Text(
                fields[i],
                style: pw.TextStyle(fontSize: fontSize, font: PdfFontStore.ja),
              ),
            ),
      ],
    );
  }
}

List<String> _activeFields(HeaderLayerConfig c) => [
      if (c.showTitle) c.titleLabel,
      if (c.showDate) c.dateLabel,
      if (c.showName) c.nameLabel,
      if (c.showSubject) c.subjectLabel,
    ];
