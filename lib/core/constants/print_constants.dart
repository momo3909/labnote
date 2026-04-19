import 'dart:math' show max;
import '../../shared/models/page_config.dart';

const double mmToPt = 2.8346;

const double a4WidthMm = 210.0;
const double a4HeightMm = 297.0;
const double b5WidthMm = 182.0;
const double b5HeightMm = 257.0;
const double a3WidthMm = 297.0;
const double a3HeightMm = 420.0;
const double b4WidthMm = 257.0;
const double b4HeightMm = 364.0;
const double letterWidthMm = 215.9;
const double letterHeightMm = 279.4;

const double hole26MarginMm = 25.0;
const double hole30MarginMm = 25.0;
const double defaultMarginMm = 10.0;

// 穴マーク描画パラメータ
const double holeCenterXMm = 12.5;
const double holeRadiusMm = 2.5;
const double holeEdgeTopMm = 12.0;
const double holeEdgeBottomMm = 12.0;

double toPoints(double mm) => mm * mmToPt;

/// 穴マーク分だけ左余白を広げた実効左余白 (mm)
double effectiveMarginLeftMm(PageConfig pageConfig) {
  if (pageConfig.holeConfig == HoleConfig.none) return pageConfig.marginLeftMm;
  const minLeft = holeCenterXMm + holeRadiusMm + 2.0;
  return max(pageConfig.marginLeftMm, minLeft);
}

extension PaperSizeExt on PaperSize {
  double get widthMm => switch (this) {
    PaperSize.a4 => a4WidthMm,
    PaperSize.b5 => b5WidthMm,
    PaperSize.a3 => a3WidthMm,
    PaperSize.b4 => b4WidthMm,
    PaperSize.letter => letterWidthMm,
  };
  double get heightMm => switch (this) {
    PaperSize.a4 => a4HeightMm,
    PaperSize.b5 => b5HeightMm,
    PaperSize.a3 => a3HeightMm,
    PaperSize.b4 => b4HeightMm,
    PaperSize.letter => letterHeightMm,
  };
}
