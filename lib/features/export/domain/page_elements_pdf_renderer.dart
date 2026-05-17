import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';
import 'pdf_font_store.dart';

class PageElementsPdfRenderer {
  const PageElementsPdfRenderer({
    required this.pageConfig,
    required this.layers,
    required this.pageNumber,
    required this.totalPages,
  });

  final PageConfig pageConfig;
  final List<LayerEntity> layers;
  final int pageNumber;
  final int totalPages;

  pw.Widget build() {
    final items = <pw.Widget>[];

    if (pageConfig.showPageNumber) items.add(_buildPageNumber());
    if (pageConfig.showLineNumbers) items.addAll(_buildLineNumbers());

    if (items.isEmpty) return pw.SizedBox.shrink();
    return pw.Positioned.fill(child: pw.Stack(children: items));
  }

  pw.Widget _buildPageNumber() {
    final marginB = toPoints(pageConfig.marginBottomMm);
    final marginR = toPoints(pageConfig.marginRightMm);
    return pw.Positioned(
      bottom: (marginB - toPoints(5.5)).clamp(2.0, double.infinity),
      right: marginR,
      child: pw.Text(
        '$pageNumber / $totalPages',
        style: pw.TextStyle(
          font: PdfFontStore.ja,
          fontSize: 8,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  List<pw.Widget> _buildLineNumbers() {
    // グリッドレイヤーの行間隔を取得（なければデフォルト 5mm）
    double cellHeightMm = 5.0;
    for (final layer in layers) {
      if (!layer.isVisible) continue;
      final cfg = layer.config;
      if (cfg is GridLayerConfig) { cellHeightMm = cfg.cellHeightMm; break; }
      if (cfg is CornellLayerConfig) { cellHeightMm = cfg.lineSpacingMm; break; }
    }

    final nominalCellH = toPoints(cellHeightMm);
    if (nominalCellH <= 0) return [];

    final marginT = toPoints(pageConfig.marginTopMm);
    final marginB = toPoints(pageConfig.marginBottomMm);
    final marginL = toPoints(pageConfig.marginLeftMm);
    final paperW = toPoints(pageConfig.effectiveWidthMm);
    final paperH = toPoints(pageConfig.effectiveHeightMm);
    final contentH = paperH - marginT - marginB;

    // GridLayerPdfRenderer と同じスケーリング方式
    final rowCount = (contentH / nominalCellH).round().clamp(1, 10000);
    final cellH = contentH / rowCount;

    final style = pw.TextStyle(
      font: PdfFontStore.ja,
      fontSize: 6,
      color: PdfColors.grey500,
    );

    final result = <pw.Widget>[];
    for (int n = 1; n <= rowCount; n++) {
      final fromTop = marginT + n * cellH;
      if (fromTop > paperH - marginB + 1) break;
      result.add(
        pw.Positioned(
          top: fromTop - 4,
          right: paperW - marginL + toPoints(1.0),
          child: pw.Text('$n', style: style),
        ),
      );
    }
    return result;
  }
}
