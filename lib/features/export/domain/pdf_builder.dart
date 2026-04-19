import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/layer_region.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';
import 'cornell_layer_pdf_renderer.dart';
import 'dot_layer_pdf_renderer.dart';
import 'grid_layer_pdf_renderer.dart';
import 'hex_layer_pdf_renderer.dart';
import 'hole_marks_pdf_renderer.dart';
import 'isometric_layer_pdf_renderer.dart';
import 'page_elements_pdf_renderer.dart';
import 'log_grid_layer_pdf_renderer.dart';

PdfColor pdfColorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
  final r = ((value >> 16) & 0xFF) / 255.0;
  final g = ((value >> 8) & 0xFF) / 255.0;
  final b = (value & 0xFF) / 255.0;
  return PdfColor(r, g, b);
}

class PdfBuilder {
  static Future<List<int>> build(NotebookTemplate template, {int? pageCountOverride}) async {
    final doc = pw.Document();
    final pageCount = pageCountOverride ?? template.pageConfig.pageCount;
    final format = _pdfPageFormat(template.pageConfig);

    for (int i = 0; i < pageCount; i++) {
      final pageNumber = i + 1;
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.zero,
          build: (ctx) => pw.Stack(
            children: [
              ..._buildLayerWidgets(template.layers, template.pageConfig),
              HoleMarksPdfRenderer(pageConfig: template.pageConfig).build(),
              PageElementsPdfRenderer(
                pageConfig: template.pageConfig,
                layers: template.layers,
                pageNumber: pageNumber,
                totalPages: pageCount,
              ).build(),
            ],
          ),
        ),
      );
    }

    return doc.save();
  }

  static LayerRegion _region(LayerEntity layer) => LayerRegion(
        x: layer.xRatio,
        y: layer.yRatio,
        width: layer.widthRatio,
        height: layer.heightRatio,
      );

  static List<pw.Widget> _buildLayerWidgets(List<LayerEntity> layers, PageConfig pageConfig) {
    return layers.where((l) => l.isVisible).map((layer) {
      final config = layer.config;
      final color = pdfColorFromHex(layer.colorHex);
      final region = _region(layer);
      return switch (config) {
        GridLayerConfig() => GridLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        HexLayerConfig() => HexLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        IsometricLayerConfig() => IsometricLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        DotLayerConfig() => DotLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        LogGridLayerConfig() => LogGridLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        CornellLayerConfig() => CornellLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        RegionLayerConfig() => pw.SizedBox.shrink(),
        GuideLayerConfig() => pw.SizedBox.shrink(),
      };
    }).toList();
  }

  static PdfPageFormat _pdfPageFormat(PageConfig config) {
    final w = toPoints(config.paperSize.widthMm);
    final h = toPoints(config.paperSize.heightMm);
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
