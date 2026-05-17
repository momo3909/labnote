// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StampItemImpl _$$StampItemImplFromJson(Map<String, dynamic> json) =>
    _$StampItemImpl(
      shapeType: json['shapeType'] as String,
      xRatio: (json['xRatio'] as num).toDouble(),
      yRatio: (json['yRatio'] as num).toDouble(),
      sizeMm: (json['sizeMm'] as num?)?.toDouble() ?? 8.0,
      groupId: json['groupId'] as String? ?? null,
      colorHex: json['colorHex'] as String? ?? '#1A1A2E',
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      strokeScale: (json['strokeScale'] as num?)?.toDouble() ?? 1.0,
      widthMm: (json['widthMm'] as num?)?.toDouble() ?? 0.0,
      heightMm: (json['heightMm'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$StampItemImplToJson(_$StampItemImpl instance) =>
    <String, dynamic>{
      'shapeType': instance.shapeType,
      'xRatio': instance.xRatio,
      'yRatio': instance.yRatio,
      'sizeMm': instance.sizeMm,
      'groupId': instance.groupId,
      'colorHex': instance.colorHex,
      'rotation': instance.rotation,
      'strokeScale': instance.strokeScale,
      'widthMm': instance.widthMm,
      'heightMm': instance.heightMm,
    };

_$LineSetImpl _$$LineSetImplFromJson(Map<String, dynamic> json) =>
    _$LineSetImpl(
      isHorizontal: json['isHorizontal'] as bool? ?? true,
      count: (json['count'] as num?)?.toInt() ?? 3,
      spacingMm: (json['spacingMm'] as num?)?.toDouble() ?? 7.0,
      startMm: (json['startMm'] as num?)?.toDouble() ?? 0.0,
      strokeWidthMm: (json['strokeWidthMm'] as num?)?.toDouble() ?? 0.3,
      lineStyle:
          $enumDecodeNullable(_$LineStyleEnumMap, json['lineStyle']) ??
          LineStyle.solid,
      subLines:
          (json['subLines'] as List<dynamic>?)
              ?.map((e) => SubLineConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LineSetImplToJson(_$LineSetImpl instance) =>
    <String, dynamic>{
      'isHorizontal': instance.isHorizontal,
      'count': instance.count,
      'spacingMm': instance.spacingMm,
      'startMm': instance.startMm,
      'strokeWidthMm': instance.strokeWidthMm,
      'lineStyle': _$LineStyleEnumMap[instance.lineStyle]!,
      'subLines': instance.subLines,
    };

const _$LineStyleEnumMap = {
  LineStyle.solid: 'solid',
  LineStyle.dashed: 'dashed',
  LineStyle.dotted: 'dotted',
};

_$SubLineConfigImpl _$$SubLineConfigImplFromJson(Map<String, dynamic> json) =>
    _$SubLineConfigImpl(
      positionRatio: (json['positionRatio'] as num?)?.toDouble() ?? 0.5,
      strokeWidthMm: (json['strokeWidthMm'] as num?)?.toDouble() ?? 0.15,
      lineStyle:
          $enumDecodeNullable(_$LineStyleEnumMap, json['lineStyle']) ??
          LineStyle.dashed,
    );

Map<String, dynamic> _$$SubLineConfigImplToJson(_$SubLineConfigImpl instance) =>
    <String, dynamic>{
      'positionRatio': instance.positionRatio,
      'strokeWidthMm': instance.strokeWidthMm,
      'lineStyle': _$LineStyleEnumMap[instance.lineStyle]!,
    };

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
  lineStyle:
      $enumDecodeNullable(_$LineStyleEnumMap, json['lineStyle']) ??
      LineStyle.solid,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$IsometricLayerConfigImplToJson(
  _$IsometricLayerConfigImpl instance,
) => <String, dynamic>{
  'spacingMm': instance.spacingMm,
  'lineStyle': _$LineStyleEnumMap[instance.lineStyle]!,
  'runtimeType': instance.$type,
};

_$DotLayerConfigImpl _$$DotLayerConfigImplFromJson(Map<String, dynamic> json) =>
    _$DotLayerConfigImpl(
      spacingMm: (json['spacingMm'] as num?)?.toDouble() ?? 5.0,
      dotRadiusMm: (json['dotRadiusMm'] as num?)?.toDouble() ?? 0.5,
      alignToOrigin: json['alignToOrigin'] as bool? ?? false,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DotLayerConfigImplToJson(
  _$DotLayerConfigImpl instance,
) => <String, dynamic>{
  'spacingMm': instance.spacingMm,
  'dotRadiusMm': instance.dotRadiusMm,
  'alignToOrigin': instance.alignToOrigin,
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
  xLabel: json['xLabel'] as String? ?? '',
  yLabel: json['yLabel'] as String? ?? '',
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$LogGridLayerConfigImplToJson(
  _$LogGridLayerConfigImpl instance,
) => <String, dynamic>{
  'xScale': _$LogScaleEnumMap[instance.xScale]!,
  'yScale': _$LogScaleEnumMap[instance.yScale]!,
  'xDecades': instance.xDecades,
  'yDecades': instance.yDecades,
  'xLabel': instance.xLabel,
  'yLabel': instance.yLabel,
  'runtimeType': instance.$type,
};

const _$LogScaleEnumMap = {LogScale.linear: 'linear', LogScale.log: 'log'};

_$CornellLayerConfigImpl _$$CornellLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$CornellLayerConfigImpl(
  leftColMm: (json['leftColMm'] as num?)?.toDouble() ?? 40.0,
  bottomRowMm: (json['bottomRowMm'] as num?)?.toDouble() ?? 25.0,
  lineSpacingMm: (json['lineSpacingMm'] as num?)?.toDouble() ?? 6.0,
  keywordLabel: json['keywordLabel'] as String? ?? 'キーワード',
  summaryLabel: json['summaryLabel'] as String? ?? 'サマリー',
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$CornellLayerConfigImplToJson(
  _$CornellLayerConfigImpl instance,
) => <String, dynamic>{
  'leftColMm': instance.leftColMm,
  'bottomRowMm': instance.bottomRowMm,
  'lineSpacingMm': instance.lineSpacingMm,
  'keywordLabel': instance.keywordLabel,
  'summaryLabel': instance.summaryLabel,
  'runtimeType': instance.$type,
};

_$PolarLayerConfigImpl _$$PolarLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$PolarLayerConfigImpl(
  rings: (json['rings'] as num?)?.toInt() ?? 6,
  sectors: (json['sectors'] as num?)?.toInt() ?? 12,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$PolarLayerConfigImplToJson(
  _$PolarLayerConfigImpl instance,
) => <String, dynamic>{
  'rings': instance.rings,
  'sectors': instance.sectors,
  'runtimeType': instance.$type,
};

_$ManuscriptLayerConfigImpl _$$ManuscriptLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$ManuscriptLayerConfigImpl(
  columns: (json['columns'] as num?)?.toInt() ?? 20,
  rows: (json['rows'] as num?)?.toInt() ?? 20,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ManuscriptLayerConfigImplToJson(
  _$ManuscriptLayerConfigImpl instance,
) => <String, dynamic>{
  'columns': instance.columns,
  'rows': instance.rows,
  'runtimeType': instance.$type,
};

_$TimetableLayerConfigImpl _$$TimetableLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$TimetableLayerConfigImpl(
  startHour: (json['startHour'] as num?)?.toInt() ?? 8,
  endHour: (json['endHour'] as num?)?.toInt() ?? 21,
  daysCount: (json['daysCount'] as num?)?.toInt() ?? 5,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$TimetableLayerConfigImplToJson(
  _$TimetableLayerConfigImpl instance,
) => <String, dynamic>{
  'startHour': instance.startHour,
  'endHour': instance.endHour,
  'daysCount': instance.daysCount,
  'runtimeType': instance.$type,
};

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

_$StaffLayerConfigImpl _$$StaffLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$StaffLayerConfigImpl(
  lineSpacingMm: (json['lineSpacingMm'] as num?)?.toDouble() ?? 2.0,
  staffGapMm: (json['staffGapMm'] as num?)?.toDouble() ?? 12.0,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$StaffLayerConfigImplToJson(
  _$StaffLayerConfigImpl instance,
) => <String, dynamic>{
  'lineSpacingMm': instance.lineSpacingMm,
  'staffGapMm': instance.staffGapMm,
  'runtimeType': instance.$type,
};

_$RuledGridLayerConfigImpl _$$RuledGridLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$RuledGridLayerConfigImpl(
  cellMm: (json['cellMm'] as num?)?.toDouble() ?? 5.0,
  ruledSpacingMm: (json['ruledSpacingMm'] as num?)?.toDouble() ?? 7.0,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$RuledGridLayerConfigImplToJson(
  _$RuledGridLayerConfigImpl instance,
) => <String, dynamic>{
  'cellMm': instance.cellMm,
  'ruledSpacingMm': instance.ruledSpacingMm,
  'runtimeType': instance.$type,
};

_$StampLayerConfigImpl _$$StampLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$StampLayerConfigImpl(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => StampItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$StampLayerConfigImplToJson(
  _$StampLayerConfigImpl instance,
) => <String, dynamic>{'items': instance.items, 'runtimeType': instance.$type};

_$CustomLineLayerConfigImpl _$$CustomLineLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$CustomLineLayerConfigImpl(
  lineSets:
      (json['lineSets'] as List<dynamic>?)
          ?.map((e) => LineSet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$CustomLineLayerConfigImplToJson(
  _$CustomLineLayerConfigImpl instance,
) => <String, dynamic>{
  'lineSets': instance.lineSets,
  'runtimeType': instance.$type,
};

_$GraphAxisLayerConfigImpl _$$GraphAxisLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$GraphAxisLayerConfigImpl(
  showXAxis: json['showXAxis'] as bool? ?? true,
  showYAxis: json['showYAxis'] as bool? ?? true,
  arrowTip: json['arrowTip'] as bool? ?? true,
  showTickMarks: json['showTickMarks'] as bool? ?? true,
  tickIntervalMm: (json['tickIntervalMm'] as num?)?.toDouble() ?? 10.0,
  tickLengthMm: (json['tickLengthMm'] as num?)?.toDouble() ?? 1.5,
  xTickSide:
      $enumDecodeNullable(_$TickSideEnumMap, json['xTickSide']) ??
      TickSide.both,
  yTickSide:
      $enumDecodeNullable(_$TickSideEnumMap, json['yTickSide']) ??
      TickSide.both,
  xLabel: json['xLabel'] as String? ?? 'x',
  yLabel: json['yLabel'] as String? ?? 'y',
  showNegative: json['showNegative'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$GraphAxisLayerConfigImplToJson(
  _$GraphAxisLayerConfigImpl instance,
) => <String, dynamic>{
  'showXAxis': instance.showXAxis,
  'showYAxis': instance.showYAxis,
  'arrowTip': instance.arrowTip,
  'showTickMarks': instance.showTickMarks,
  'tickIntervalMm': instance.tickIntervalMm,
  'tickLengthMm': instance.tickLengthMm,
  'xTickSide': _$TickSideEnumMap[instance.xTickSide]!,
  'yTickSide': _$TickSideEnumMap[instance.yTickSide]!,
  'xLabel': instance.xLabel,
  'yLabel': instance.yLabel,
  'showNegative': instance.showNegative,
  'runtimeType': instance.$type,
};

const _$TickSideEnumMap = {
  TickSide.both: 'both',
  TickSide.positive: 'positive',
  TickSide.negative: 'negative',
};

_$TableLayerConfigImpl _$$TableLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$TableLayerConfigImpl(
  rows: (json['rows'] as num?)?.toInt() ?? 4,
  cols: (json['cols'] as num?)?.toInt() ?? 3,
  showHeaderRow: json['showHeaderRow'] as bool? ?? true,
  showHeaderCol: json['showHeaderCol'] as bool? ?? false,
  cellHeightMm: (json['cellHeightMm'] as num?)?.toDouble() ?? 8.0,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$TableLayerConfigImplToJson(
  _$TableLayerConfigImpl instance,
) => <String, dynamic>{
  'rows': instance.rows,
  'cols': instance.cols,
  'showHeaderRow': instance.showHeaderRow,
  'showHeaderCol': instance.showHeaderCol,
  'cellHeightMm': instance.cellHeightMm,
  'runtimeType': instance.$type,
};

_$HeaderLayerConfigImpl _$$HeaderLayerConfigImplFromJson(
  Map<String, dynamic> json,
) => _$HeaderLayerConfigImpl(
  showTitle: json['showTitle'] as bool? ?? true,
  titleLabel: json['titleLabel'] as String? ?? 'タイトル',
  showDate: json['showDate'] as bool? ?? true,
  dateLabel: json['dateLabel'] as String? ?? '日付',
  showName: json['showName'] as bool? ?? true,
  nameLabel: json['nameLabel'] as String? ?? '名前',
  showSubject: json['showSubject'] as bool? ?? false,
  subjectLabel: json['subjectLabel'] as String? ?? '科目',
  fontSizeMm: (json['fontSizeMm'] as num?)?.toDouble() ?? 3.5,
  rowHeightMm: (json['rowHeightMm'] as num?)?.toDouble() ?? 8.0,
  showBorder: json['showBorder'] as bool? ?? true,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$HeaderLayerConfigImplToJson(
  _$HeaderLayerConfigImpl instance,
) => <String, dynamic>{
  'showTitle': instance.showTitle,
  'titleLabel': instance.titleLabel,
  'showDate': instance.showDate,
  'dateLabel': instance.dateLabel,
  'showName': instance.showName,
  'nameLabel': instance.nameLabel,
  'showSubject': instance.showSubject,
  'subjectLabel': instance.subjectLabel,
  'fontSizeMm': instance.fontSizeMm,
  'rowHeightMm': instance.rowHeightMm,
  'showBorder': instance.showBorder,
  'runtimeType': instance.$type,
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
