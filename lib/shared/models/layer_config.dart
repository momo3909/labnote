import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_config.freezed.dart';
part 'layer_config.g.dart';

enum LineStyle { solid, dashed, dotted }
enum HexOrientation { flat, pointy }
enum GuideType { axis, bondAngle60, bondAngle109, bondAngle120, scale }

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
