import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import 'layer_pdf_renderer_base.dart';
import 'pdf_font_store.dart';

class CornellLayerPdfRenderer extends LayerPdfRendererBase<CornellLayerConfig> {
  const CornellLayerPdfRenderer({
    required super.config,
    required super.pageConfig,
    required super.color,
    super.opacity,
    super.region,
  });

  @override
  pw.Widget build() {
    final base = super.build();
    final labels = <pw.Widget>[];
    final labelStyle = pw.TextStyle(
      font: PdfFontStore.ja,
      fontSize: 7,
      color: PdfColor(color.red, color.green, color.blue, opacity * 0.55),
    );
    final cLeft = toPoints(effectiveMarginLeftMm(pageConfig));
    final marginTop = toPoints(pageConfig.marginTopMm);
    final marginBottom = toPoints(pageConfig.marginBottomMm);
    final paperH = toPoints(pageConfig.effectiveHeightMm);
    final bottomRowH = toPoints(config.bottomRowMm);

    if (config.keywordLabel.isNotEmpty) {
      labels.add(pw.Positioned(
        top: marginTop + 3,
        left: cLeft + 3,
        child: pw.Text(config.keywordLabel, style: labelStyle),
      ));
    }
    if (config.summaryLabel.isNotEmpty) {
      labels.add(pw.Positioned(
        top: paperH - marginBottom - bottomRowH + 3,
        left: cLeft + 3,
        child: pw.Text(config.summaryLabel, style: labelStyle),
      ));
    }
    if (labels.isEmpty) return base;
    return pw.Stack(children: [base, ...labels]);
  }

  @override
  void paintContent(
    PdfGraphics canvas, {
    required double left,
    required double right,
    required double bottom,
    required double top,
  }) {
    final leftColW = toPoints(config.leftColMm);
    final bottomRowH = toPoints(config.bottomRowMm);
    final lineSpacing = toPoints(config.lineSpacingMm);

    final dividerX = left + leftColW;
    final dividerY = bottom + bottomRowH;

    if (lineSpacing > 0) {
      final offsetY = (top - dividerY) % lineSpacing / 2;
      for (double y = dividerY + lineSpacing + offsetY; y <= top - 1; y += lineSpacing) {
        canvas.setStrokeColor(color);
        canvas.setLineWidth(0.25);
        canvas.moveTo(dividerX, y);
        canvas.lineTo(right, y);
        canvas.strokePath();
      }
    }

    canvas.setStrokeColor(color);
    canvas.setLineWidth(0.6);

    canvas.moveTo(dividerX, dividerY);
    canvas.lineTo(dividerX, top);
    canvas.strokePath();

    canvas.moveTo(left, dividerY);
    canvas.lineTo(right, dividerY);
    canvas.strokePath();
  }
}
