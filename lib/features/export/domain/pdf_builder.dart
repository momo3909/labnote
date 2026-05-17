import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/print_constants.dart';
import 'pdf_font_store.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/layer_region.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';
import 'cornell_layer_pdf_renderer.dart';
import 'dot_layer_pdf_renderer.dart';
import 'grid_layer_pdf_renderer.dart';
import 'guide_layer_pdf_renderer.dart';
import 'hex_layer_pdf_renderer.dart';
import 'manuscript_layer_pdf_renderer.dart';
import 'polar_layer_pdf_renderer.dart';
import 'timetable_layer_pdf_renderer.dart';
import 'hole_marks_pdf_renderer.dart';
import 'isometric_layer_pdf_renderer.dart';
import 'log_grid_layer_pdf_renderer.dart';
import 'page_elements_pdf_renderer.dart';
import 'region_layer_pdf_renderer.dart';
import 'ruled_grid_layer_pdf_renderer.dart';
import 'staff_layer_pdf_renderer.dart';
import 'graph_axis_layer_pdf_renderer.dart';
import 'table_layer_pdf_renderer.dart';
import 'custom_line_layer_pdf_renderer.dart';

import 'header_layer_pdf_renderer.dart';
import 'stamp_layer_pdf_renderer.dart';

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
    await PdfFontStore.preload();
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
    final result = <pw.Widget>[];
    for (final layer in layers.where((l) => l.isVisible)) {
      if (layer.bgColorHex.isNotEmpty) {
        result.add(_buildBgWidget(layer, pageConfig));
      }
      result.add(_buildLayerWidget(layer, pageConfig));
    }
    return result;
  }

  static pw.Widget _buildBgWidget(LayerEntity layer, PageConfig pageConfig) {
    final bg = pdfColorFromHex(layer.bgColorHex);
    final r = _region(layer);
    return pw.CustomPaint(
      painter: (canvas, size) {
        final cLeft = toPoints(effectiveMarginLeftMm(pageConfig));
        final cRight = size.x - toPoints(pageConfig.marginRightMm);
        final cBottom = toPoints(pageConfig.marginBottomMm);
        final cTop = size.y - toPoints(pageConfig.marginTopMm);
        final cW = cRight - cLeft;
        final cH = cTop - cBottom;
        final left = cLeft + cW * r.x;
        final right = left + cW * r.width;
        final bottom = cTop - cH * (r.y + r.height);
        final top = bottom + cH * r.height;
        canvas.setFillColor(bg);
        canvas.drawRect(left, bottom, right - left, top - bottom);
        canvas.fillPath();
      },
      size: PdfPoint(
        toPoints(pageConfig.effectiveWidthMm),
        toPoints(pageConfig.effectiveHeightMm),
      ),
    );
  }

  static pw.Widget _buildLayerWidget(LayerEntity layer, PageConfig pageConfig) {
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
        PolarLayerConfig() => PolarLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        ManuscriptLayerConfig() => ManuscriptLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        TimetableLayerConfig() => TimetableLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        RegionLayerConfig() => RegionLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        GuideLayerConfig() => GuideLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        StaffLayerConfig() => StaffLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        RuledGridLayerConfig() => RuledGridLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        StampLayerConfig() => StampLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        CustomLineLayerConfig() => CustomLineLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        GraphAxisLayerConfig() => GraphAxisLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
        TableLayerConfig() => TableLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),

        HeaderLayerConfig() => HeaderLayerPdfRenderer(
            config: config, pageConfig: pageConfig, color: color,
            opacity: layer.opacity, region: region).build(),
      };
  }

  static PdfPageFormat _pdfPageFormat(PageConfig config) {
    final w = toPoints(config.effectiveWidthMm);
    final h = toPoints(config.effectiveHeightMm);
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
