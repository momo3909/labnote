import 'package:flutter/material.dart';
import '../models/layer_config.dart';
import '../models/notebook_template.dart';
import '../models/page_config.dart';
import 'painter_utils.dart';
import '../../core/constants/print_constants.dart';

class PageElementsPainter extends CustomPainter {
  const PageElementsPainter({
    required this.pageConfig,
    required this.layers,
    this.pageNumber = 1,
    this.totalPages = 1,
  });

  final PageConfig pageConfig;
  final List<LayerEntity> layers;
  final int pageNumber;
  final int totalPages;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = scaleFactor(size.width, pageConfig.effectiveWidthMm);

    if (pageConfig.showPageNumber) _paintPageNumber(canvas, size, scale);
    if (pageConfig.showLineNumbers) _paintLineNumbers(canvas, size, scale);
  }

  void _paintPageNumber(Canvas canvas, Size size, double scale) {
    final marginB = mmToPx(pageConfig.marginBottomMm, scale);
    final marginR = mmToPx(pageConfig.marginRightMm, scale);

    final tp = TextPainter(
      text: TextSpan(
        text: '$pageNumber / $totalPages',
        style: TextStyle(
          fontSize: 8 * scale,
          color: Colors.grey.shade600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // コンテンツ領域の下（余白内）に配置
    final y = (size.height - marginB + (marginB - tp.height) / 2)
        .clamp(size.height - marginB, size.height - tp.height);
    tp.paint(canvas, Offset(size.width - marginR - tp.width, y));
  }

  void _paintLineNumbers(Canvas canvas, Size size, double scale) {
    double cellHeightMm = 5.0;
    for (final layer in layers) {
      if (!layer.isVisible) continue;
      final cfg = layer.config;
      if (cfg is GridLayerConfig) {
        cellHeightMm = cfg.cellHeightMm;
        break;
      }
      if (cfg is CornellLayerConfig) {
        cellHeightMm = cfg.lineSpacingMm;
        break;
      }
    }

    final cellH = mmToPx(cellHeightMm, scale);
    if (cellH <= 0) return;

    final marginT = mmToPx(pageConfig.marginTopMm, scale);
    final marginB = mmToPx(pageConfig.marginBottomMm, scale);
    final marginL = mmToPx(pageConfig.marginLeftMm, scale);
    final contentH = size.height - marginT - marginB;

    final offsetY = contentH % cellH / 2;
    final firstLineY = marginT + offsetY + cellH;

    final style = TextStyle(fontSize: 6 * scale, color: Colors.grey.shade500);

    int lineNum = 1;
    double y = firstLineY;
    while (y <= size.height - marginB - 1) {
      final tp = TextPainter(
        text: TextSpan(text: '$lineNum', style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = (marginL - tp.width - mmToPx(1.0, scale)).clamp(0.0, marginL);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
      lineNum++;
      y += cellH;
    }
  }

  @override
  bool shouldRepaint(PageElementsPainter old) =>
      old.pageConfig != pageConfig ||
      old.layers != layers ||
      old.pageNumber != pageNumber ||
      old.totalPages != totalPages;
}
