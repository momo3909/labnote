import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';
import 'cornell_layer_pdf_renderer.dart';
import 'dot_layer_pdf_renderer.dart';
import 'grid_layer_pdf_renderer.dart';
import 'hex_layer_pdf_renderer.dart';
import 'isometric_layer_pdf_renderer.dart';
import 'log_grid_layer_pdf_renderer.dart';

class PdfBuilder {
  static const _lineColor = PdfColor.fromInt(0xFFAAAAAA);

  static Future<List<int>> build(NotebookTemplate template, {int? pageCountOverride}) async {
    final doc = pw.Document();
    final pageCount = pageCountOverride ?? template.pageConfig.pageCount;
    final format = _pdfPageFormat(template.pageConfig);

    for (int i = 0; i < pageCount; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.Stack(
            children: _buildLayerWidgets(template.layers, template.pageConfig),
          ),
        ),
      );
    }

    return doc.save();
  }

  static List<pw.Widget> _buildLayerWidgets(List<LayerEntity> layers, PageConfig pageConfig) {
    return layers.where((l) => l.isVisible).map((layer) {
      final config = layer.config;
      return switch (config) {
        GridLayerConfig() => GridLayerPdfRenderer(
            config: config,
            pageConfig: pageConfig,
            color: _lineColor,
            opacity: layer.opacity,
          ).build(),
        HexLayerConfig() => HexLayerPdfRenderer(
            config: config,
            pageConfig: pageConfig,
            color: _lineColor,
            opacity: layer.opacity,
          ).build(),
        IsometricLayerConfig() => IsometricLayerPdfRenderer(
            config: config,
            pageConfig: pageConfig,
            color: _lineColor,
            opacity: layer.opacity,
          ).build(),
        DotLayerConfig() => DotLayerPdfRenderer(
            config: config,
            pageConfig: pageConfig,
            color: _lineColor,
            opacity: layer.opacity,
          ).build(),
        LogGridLayerConfig() => LogGridLayerPdfRenderer(
            config: config,
            pageConfig: pageConfig,
            color: _lineColor,
            opacity: layer.opacity,
          ).build(),
        CornellLayerConfig() => CornellLayerPdfRenderer(
            config: config,
            pageConfig: pageConfig,
            color: _lineColor,
            opacity: layer.opacity,
          ).build(),
        RegionLayerConfig() => pw.SizedBox.shrink(),
        GuideLayerConfig() => pw.SizedBox.shrink(),
      };
    }).toList();
  }

  static PdfPageFormat _pdfPageFormat(PageConfig config) {
    final w = toPoints(config.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm);
    final h = toPoints(config.paperSize == PaperSize.a4 ? a4HeightMm : b5HeightMm);
    final margin = _marginPoints(config);
    return PdfPageFormat(w, h,
      marginTop: margin.top,
      marginBottom: margin.bottom,
      marginLeft: margin.left,
      marginRight: margin.right,
    );
  }

  static ({double top, double bottom, double left, double right}) _marginPoints(PageConfig c) {
    return (
      top: toPoints(c.marginTopMm),
      bottom: toPoints(c.marginBottomMm),
      left: toPoints(c.marginLeftMm),
      right: toPoints(c.marginRightMm),
    );
  }
}
