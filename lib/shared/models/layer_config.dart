import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_config.freezed.dart';
part 'layer_config.g.dart';

enum LineStyle { solid, dashed, dotted }
enum HexOrientation { flat, pointy }
enum GuideType { axis, bondAngle60, bondAngle109, bondAngle120, scale }
enum LogScale { linear, log }

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
  }) = IsometricLayerConfig;

  const factory LayerConfig.dot({
    @Default(5.0) double spacingMm,
    @Default(0.5) double dotRadiusMm,
  }) = DotLayerConfig;

  const factory LayerConfig.logGrid({
    @Default(LogScale.linear) LogScale xScale,
    @Default(LogScale.log) LogScale yScale,
    @Default(1) int xDecades,
    @Default(3) int yDecades,
  }) = LogGridLayerConfig;

  const factory LayerConfig.cornell({
    @Default(40.0) double leftColMm,
    @Default(25.0) double bottomRowMm,
    @Default(6.0) double lineSpacingMm,
  }) = CornellLayerConfig;

  const factory LayerConfig.region({
    @Default([]) List<PageRegion> regions,
  }) = RegionLayerConfig;

  const factory LayerConfig.guide({
    required GuideType guideType,
    @Default({}) Map<String, dynamic> params,
  }) = GuideLayerConfig;

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
