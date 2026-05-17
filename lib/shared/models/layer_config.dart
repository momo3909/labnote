import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_config.freezed.dart';
part 'layer_config.g.dart';

@freezed
class StampItem with _$StampItem {
  const factory StampItem({
    required String shapeType,
    required double xRatio,
    required double yRatio,
    @Default(8.0) double sizeMm,
    @Default(null) String? groupId,
    @Default('#1A1A2E') String colorHex,
    @Default(0.0) double rotation,
    @Default(1.0) double strokeScale,
    @Default(0.0) double widthMm,   // 0 = sizeMm にフォールバック
    @Default(0.0) double heightMm,  // 0 = sizeMm にフォールバック
  }) = _StampItem;
  factory StampItem.fromJson(Map<String, dynamic> json) => _$StampItemFromJson(json);
}

enum LineStyle { solid, dashed, dotted }
enum HexOrientation { flat, pointy }
enum GuideType { axis, bondAngle60, bondAngle109, bondAngle120, scale }
enum LogScale { linear, log }
// 目盛り線の描画方向（X軸: positive=上, negative=下 / Y軸: positive=右, negative=左）
enum TickSide { both, positive, negative }

@freezed
class LineSet with _$LineSet {
  const factory LineSet({
    @Default(true) bool isHorizontal,
    @Default(3) int count,
    @Default(7.0) double spacingMm,
    @Default(0.0) double startMm,
    @Default(0.3) double strokeWidthMm,
    @Default(LineStyle.solid) LineStyle lineStyle,
    @Default([]) List<SubLineConfig> subLines,
  }) = _LineSet;
  factory LineSet.fromJson(Map<String, dynamic> json) => _$LineSetFromJson(json);
}

@freezed
class SubLineConfig with _$SubLineConfig {
  const factory SubLineConfig({
    @Default(0.5)              double    positionRatio,
    @Default(0.15)             double    strokeWidthMm,
    @Default(LineStyle.dashed) LineStyle lineStyle,
  }) = _SubLineConfig;
  factory SubLineConfig.fromJson(Map<String, dynamic> json) => _$SubLineConfigFromJson(json);
}

@freezed
sealed class LayerConfig with _$LayerConfig {
  const factory LayerConfig.grid({
    @Default(5.0) double cellWidthMm,
    @Default(5.0) double cellHeightMm,
    @Default(LineStyle.solid) LineStyle lineStyle,
    int? boldEvery,
    @Default(true) bool showHorizontal,
    @Default(true) bool showVertical,
  }) = GridLayerConfig;

  const factory LayerConfig.hex({
    @Default(5.0) double hexSizeMm,
    @Default(HexOrientation.flat) HexOrientation orientation,
  }) = HexLayerConfig;

  const factory LayerConfig.isometric({
    @Default(5.0) double spacingMm,
    @Default(LineStyle.solid) LineStyle lineStyle,
  }) = IsometricLayerConfig;

  const factory LayerConfig.dot({
    @Default(5.0)  double spacingMm,
    @Default(0.5)  double dotRadiusMm,
    @Default(false) bool  alignToOrigin,
  }) = DotLayerConfig;

  const factory LayerConfig.logGrid({
    @Default(LogScale.linear) LogScale xScale,
    @Default(LogScale.log) LogScale yScale,
    @Default(1) int xDecades,
    @Default(3) int yDecades,
    @Default('') String xLabel,
    @Default('') String yLabel,
  }) = LogGridLayerConfig;

  const factory LayerConfig.cornell({
    @Default(40.0) double leftColMm,
    @Default(25.0) double bottomRowMm,
    @Default(6.0) double lineSpacingMm,
    @Default('キーワード') String keywordLabel,
    @Default('サマリー') String summaryLabel,
  }) = CornellLayerConfig;

  const factory LayerConfig.polar({
    @Default(6) int rings,
    @Default(12) int sectors,
  }) = PolarLayerConfig;

  const factory LayerConfig.manuscript({
    @Default(20) int columns,
    @Default(20) int rows,
  }) = ManuscriptLayerConfig;

  const factory LayerConfig.timetable({
    @Default(8) int startHour,
    @Default(21) int endHour,
    @Default(5) int daysCount,
  }) = TimetableLayerConfig;

  const factory LayerConfig.region({
    @Default([]) List<PageRegion> regions,
  }) = RegionLayerConfig;

  const factory LayerConfig.guide({
    required GuideType guideType,
    @Default({}) Map<String, dynamic> params,
  }) = GuideLayerConfig;

  const factory LayerConfig.staff({
    @Default(2.0) double lineSpacingMm,
    @Default(12.0) double staffGapMm,
  }) = StaffLayerConfig;

  const factory LayerConfig.ruledGrid({
    @Default(5.0) double cellMm,
    @Default(7.0) double ruledSpacingMm,
  }) = RuledGridLayerConfig;

  const factory LayerConfig.stamp({
    @Default([]) List<StampItem> items,
  }) = StampLayerConfig;

  const factory LayerConfig.customLine({
    @Default([]) List<LineSet> lineSets,
  }) = CustomLineLayerConfig;

  const factory LayerConfig.graphAxis({
    @Default(true)  bool     showXAxis,
    @Default(true)  bool     showYAxis,
    @Default(true)  bool     arrowTip,
    @Default(true)  bool     showTickMarks,
    @Default(10.0)  double   tickIntervalMm,
    @Default(1.5)   double   tickLengthMm,
    @Default(TickSide.both) TickSide xTickSide,
    @Default(TickSide.both) TickSide yTickSide,
    @Default('x')   String   xLabel,
    @Default('y')   String   yLabel,
    @Default(false) bool     showNegative,
  }) = GraphAxisLayerConfig;

  const factory LayerConfig.table({
    @Default(4)    int    rows,
    @Default(3)    int    cols,
    @Default(true) bool   showHeaderRow,
    @Default(false) bool  showHeaderCol,
    @Default(8.0)  double cellHeightMm,
  }) = TableLayerConfig;

  const factory LayerConfig.header({
    @Default(true) bool showTitle,
    @Default('タイトル') String titleLabel,
    @Default(true) bool showDate,
    @Default('日付') String dateLabel,
    @Default(true) bool showName,
    @Default('名前') String nameLabel,
    @Default(false) bool showSubject,
    @Default('科目') String subjectLabel,
    @Default(3.5) double fontSizeMm,
    @Default(8.0) double rowHeightMm,
    @Default(true) bool showBorder,
  }) = HeaderLayerConfig;

  factory LayerConfig.fromJson(Map<String, dynamic> json) =>
      _$LayerConfigFromJson(json);
}

@freezed
class PageRegion with _$PageRegion {
  const factory PageRegion({
    required double xRatio,
    required double yRatio,
    required double widthRatio,
    required double heightRatio,
    required LayerConfig layerConfig,
  }) = _PageRegion;

  factory PageRegion.fromJson(Map<String, dynamic> json) =>
      _$PageRegionFromJson(json);
}
