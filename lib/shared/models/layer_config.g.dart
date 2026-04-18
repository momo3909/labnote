// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GridLayerConfigImpl _$$GridLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$GridLayerConfigImpl(
  cellWidthMm: (json['cellWidthMm'] as num?)?.toDouble() ?? 5.0,
  cellHeightMm: (json['cellHeightMm'] as num?)?.toDouble() ?? 5.0,
  lineStyle:
      $enumDecodeNullable(_$LineStyleEnumMap, json['lineStyle']) ??
      LineStyle.solid,
  boldEvery: (json['boldEvery'] as num?)?.toInt(),
  showHorizontal: json['showHorizontal'] as bool? ?? true,
  showVertical: json['showVertical'] as bool? ?? true,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$GridLayerConfigImplToJson(
  _$GridLayerConfigImpl instance,
) => <String, dynamic>{
  'cellWidthMm': instance.cellWidthMm,
  'cellHeightMm': instance.cellHeightMm,
  'lineStyle': _$LineStyleEnumMap[instance.lineStyle]!,
  'boldEvery': instance.boldEvery,
  'showHorizontal': instance.showHorizontal,
  'showVertical': instance.showVertical,
  'runtimeType': instance.$type,
};

const _$LineStyleEnumMap = {
  LineStyle.solid: 'solid',
  LineStyle.dashed: 'dashed',
  LineStyle.dotted: 'dotted',
};

_$HexLayerConfigImpl _$$HexLayerConfigImplFromJson(Map<String, dynamic> json) =>
    _$HexLayerConfigImpl(
      hexSizeMm: (json['hexSizeMm'] as num?)?.toDouble() ?? 5.0,
      orientation:
          $enumDecodeNullable(_$HexOrientationEnumMap, json['orientation']) ??
          HexOrientation.flat,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$HexLayerConfigImplToJson(
  _$HexLayerConfigImpl instance,
) => <String, dynamic>{
  'hexSizeMm': instance.hexSizeMm,
  'orientation': _$HexOrientationEnumMap[instance.orientation]!,
  'runtimeType': instance.$type,
};

const _$HexOrientationEnumMap = {
  HexOrientation.flat: 'flat',
  HexOrientation.pointy: 'pointy',
};

_$IsometricLayerConfigImpl _$$IsometricLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$IsometricLayerConfigImpl(
  spacingMm: (json['spacingMm'] as num?)?.toDouble() ?? 5.0,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$IsometricLayerConfigImplToJson(
  _$IsometricLayerConfigImpl instance,
) => <String, dynamic>{
  'spacingMm': instance.spacingMm,
  'runtimeType': instance.$type,
};

_$DotLayerConfigImpl _$$DotLayerConfigImplFromJson(Map<String, dynamic> json) =>
    _$DotLayerConfigImpl(
      spacingMm: (json['spacingMm'] as num?)?.toDouble() ?? 5.0,
      dotRadiusMm: (json['dotRadiusMm'] as num?)?.toDouble() ?? 0.5,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DotLayerConfigImplToJson(
  _$DotLayerConfigImpl instance,
) => <String, dynamic>{
  'spacingMm': instance.spacingMm,
  'dotRadiusMm': instance.dotRadiusMm,
  'runtimeType': instance.$type,
};

_$LogGridLayerConfigImpl _$$LogGridLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$LogGridLayerConfigImpl(
  xScale:
      $enumDecodeNullable(_$LogScaleEnumMap, json['xScale']) ?? LogScale.linear,
  yScale:
      $enumDecodeNullable(_$LogScaleEnumMap, json['yScale']) ?? LogScale.log,
  xDecades: (json['xDecades'] as num?)?.toInt() ?? 1,
  yDecades: (json['yDecades'] as num?)?.toInt() ?? 3,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$LogGridLayerConfigImplToJson(
  _$LogGridLayerConfigImpl instance,
) => <String, dynamic>{
  'xScale': _$LogScaleEnumMap[instance.xScale]!,
  'yScale': _$LogScaleEnumMap[instance.yScale]!,
  'xDecades': instance.xDecades,
  'yDecades': instance.yDecades,
  'runtimeType': instance.$type,
};

const _$LogScaleEnumMap = {LogScale.linear: 'linear', LogScale.log: 'log'};

_$RegionLayerConfigImpl _$$RegionLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$RegionLayerConfigImpl(
  regions:
      (json['regions'] as List<dynamic>?)
          ?.map((e) => PageRegion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$RegionLayerConfigImplToJson(
  _$RegionLayerConfigImpl instance,
) => <String, dynamic>{
  'regions': instance.regions,
  'runtimeType': instance.$type,
};

_$GuideLayerConfigImpl _$$GuideLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$GuideLayerConfigImpl(
  guideType: $enumDecode(_$GuideTypeEnumMap, json['guideType']),
  params: json['params'] as Map<String, dynamic>? ?? const {},
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$GuideLayerConfigImplToJson(
  _$GuideLayerConfigImpl instance,
) => <String, dynamic>{
  'guideType': _$GuideTypeEnumMap[instance.guideType]!,
  'params': instance.params,
  'runtimeType': instance.$type,
};

const _$GuideTypeEnumMap = {
  GuideType.axis: 'axis',
  GuideType.bondAngle60: 'bondAngle60',
  GuideType.bondAngle109: 'bondAngle109',
  GuideType.bondAngle120: 'bondAngle120',
  GuideType.scale: 'scale',
};

_$PageRegionImpl _$$PageRegionImplFromJson(Map<String, dynamic> json) =>
    _$PageRegionImpl(
      xRatio: (json['xRatio'] as num).toDouble(),
      yRatio: (json['yRatio'] as num).toDouble(),
      widthRatio: (json['widthRatio'] as num).toDouble(),
      heightRatio: (json['heightRatio'] as num).toDouble(),
      layerConfig: LayerConfig.fromJson(
        json['layerConfig'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$PageRegionImplToJson(_$PageRegionImpl instance) =>
    <String, dynamic>{
      'xRatio': instance.xRatio,
      'yRatio': instance.yRatio,
      'widthRatio': instance.widthRatio,
      'heightRatio': instance.heightRatio,
      'layerConfig': instance.layerConfig,
    };
