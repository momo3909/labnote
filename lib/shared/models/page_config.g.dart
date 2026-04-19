// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageConfigImpl _$$PageConfigImplFromJson(Map<String, dynamic> json) =>
    _$PageConfigImpl(
      paperSize:
          $enumDecodeNullable(_$PaperSizeEnumMap, json['paperSize']) ??
          PaperSize.a4,
      orientation:
          $enumDecodeNullable(_$PaperOrientationEnumMap, json['orientation']) ??
          PaperOrientation.portrait,
      marginTopMm: (json['marginTopMm'] as num?)?.toDouble() ?? 10.0,
      marginBottomMm: (json['marginBottomMm'] as num?)?.toDouble() ?? 10.0,
      marginLeftMm: (json['marginLeftMm'] as num?)?.toDouble() ?? 10.0,
      marginRightMm: (json['marginRightMm'] as num?)?.toDouble() ?? 10.0,
      holeConfig:
          $enumDecodeNullable(_$HoleConfigEnumMap, json['holeConfig']) ??
          HoleConfig.h26,
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 1,
      showPageNumber: json['showPageNumber'] as bool? ?? false,
      showLineNumbers: json['showLineNumbers'] as bool? ?? false,
    );

Map<String, dynamic> _$$PageConfigImplToJson(_$PageConfigImpl instance) =>
    <String, dynamic>{
      'paperSize': _$PaperSizeEnumMap[instance.paperSize]!,
      'orientation': _$PaperOrientationEnumMap[instance.orientation]!,
      'marginTopMm': instance.marginTopMm,
      'marginBottomMm': instance.marginBottomMm,
      'marginLeftMm': instance.marginLeftMm,
      'marginRightMm': instance.marginRightMm,
      'holeConfig': _$HoleConfigEnumMap[instance.holeConfig]!,
      'pageCount': instance.pageCount,
      'showPageNumber': instance.showPageNumber,
      'showLineNumbers': instance.showLineNumbers,
    };

const _$PaperSizeEnumMap = {
  PaperSize.a4: 'a4',
  PaperSize.b5: 'b5',
  PaperSize.a3: 'a3',
  PaperSize.b4: 'b4',
  PaperSize.letter: 'letter',
};

const _$PaperOrientationEnumMap = {
  PaperOrientation.portrait: 'portrait',
  PaperOrientation.landscape: 'landscape',
};

const _$HoleConfigEnumMap = {
  HoleConfig.none: 'none',
  HoleConfig.h26: 'h26',
  HoleConfig.h30: 'h30',
};
