import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';

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
          font: pw.Font.helvetica(),
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

    final cellH = toPoints(cellHeightMm);
    if (cellH <= 0) return [];

    final marginT = toPoints(pageConfig.marginTopMm);
    final marginB = toPoints(pageConfig.marginBottomMm);
    final marginL = toPoints(pageConfig.marginLeftMm);
    final paperH = toPoints(pageConfig.paperSize.heightMm);
    final contentH = paperH - marginT - marginB;

    // グリッドペインターと同じセンタリングオフセット（Flutter y-down 換算）
    final offsetY = contentH % cellH / 2;
    // 最初の罫線: marginTop + offsetY + cellH（ペインターに合わせる）
    final firstLineFromTop = marginT + offsetY + cellH;

    final style = pw.TextStyle(
      font: pw.Font.helvetica(),
      fontSize: 6,
      color: PdfColors.grey500,
    );

    final result = <pw.Widget>[];
    int lineNum = 1;
    double fromTop = firstLineFromTop;
    while (fromTop <= paperH - marginB - 1) {
      final num = lineNum;
      final top = fromTop;
      result.add(
        pw.Positioned(
          top: top - 4, // テキスト高さの半分を補正
          left: marginL - toPoints(7.0),
          child: pw.Text('$num', style: style),
        ),
      );
      lineNum++;
      fromTop += cellH;
    }
    return result;
  }
}
