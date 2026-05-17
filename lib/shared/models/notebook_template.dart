import 'dart:convert';
import 'dart:typed_data';
import 'layer_config.dart';
import 'page_config.dart';

class NotebookTemplate {
  late String uuid;

  late String name;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isPinned = false;
  List<String> tags = [];

  String? authorId;
  bool isPublic = false;
  String? remoteId;
  int downloadCount = 0;
  Uint8List? thumbnailPng;

  late String pageConfigJson;
  late List<String> layersJson;

  PageConfig get pageConfig =>
      PageConfig.fromJson(jsonDecode(pageConfigJson) as Map<String, dynamic>);

  set pageConfig(PageConfig config) =>
      pageConfigJson = jsonEncode(config.toJson());

  List<LayerEntity> get layers =>
      layersJson.map((j) => LayerEntity.fromJson(jsonDecode(j) as Map<String, dynamic>)).toList();

  set layers(List<LayerEntity> value) =>
      layersJson = value.map((l) => jsonEncode(l.toJson())).toList();
}

class LayerEntity {
  final String uuid;
  final int sortOrder;
  final bool isVisible;
  final double opacity;
  final String colorHex;
  final String bgColorHex;
  final String layerType;
  final String configJson;
  // コンテンツ領域に対する配置比率 (0.0〜1.0)
  final double xRatio;
  final double yRatio;
  final double widthRatio;
  final double heightRatio;

  const LayerEntity({
    required this.uuid,
    required this.sortOrder,
    this.isVisible = true,
    this.opacity = 1.0,
    this.colorHex = '#CCCCCC',
    this.bgColorHex = '',
    required this.layerType,
    required this.configJson,
    this.xRatio = 0.0,
    this.yRatio = 0.0,
    this.widthRatio = 1.0,
    this.heightRatio = 1.0,
  });

  LayerConfig get config =>
      LayerConfig.fromJson(jsonDecode(configJson) as Map<String, dynamic>);

  LayerEntity copyWith({
    String? uuid,
    int? sortOrder,
    bool? isVisible,
    double? opacity,
    String? colorHex,
    String? bgColorHex,
    String? layerType,
    String? configJson,
    double? xRatio,
    double? yRatio,
    double? widthRatio,
    double? heightRatio,
  }) =>
      LayerEntity(
        uuid: uuid ?? this.uuid,
        sortOrder: sortOrder ?? this.sortOrder,
        isVisible: isVisible ?? this.isVisible,
        opacity: opacity ?? this.opacity,
        colorHex: colorHex ?? this.colorHex,
        bgColorHex: bgColorHex ?? this.bgColorHex,
        layerType: layerType ?? this.layerType,
        configJson: configJson ?? this.configJson,
        xRatio: xRatio ?? this.xRatio,
        yRatio: yRatio ?? this.yRatio,
        widthRatio: widthRatio ?? this.widthRatio,
        heightRatio: heightRatio ?? this.heightRatio,
      );

  factory LayerEntity.fromJson(Map<String, dynamic> json) => LayerEntity(
        uuid: json['uuid'] as String,
        sortOrder: json['sortOrder'] as int,
        isVisible: json['isVisible'] as bool? ?? true,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        colorHex: json['colorHex'] as String? ?? '#CCCCCC',
        bgColorHex: json['bgColorHex'] as String? ?? '',
        layerType: json['layerType'] as String,
        configJson: json['configJson'] as String,
        xRatio: (json['xRatio'] as num?)?.toDouble() ?? 0.0,
        yRatio: (json['yRatio'] as num?)?.toDouble() ?? 0.0,
        widthRatio: (json['widthRatio'] as num?)?.toDouble() ?? 1.0,
        heightRatio: (json['heightRatio'] as num?)?.toDouble() ?? 1.0,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'sortOrder': sortOrder,
        'isVisible': isVisible,
        'opacity': opacity,
        'colorHex': colorHex,
        'bgColorHex': bgColorHex,
        'layerType': layerType,
        'configJson': configJson,
        'xRatio': xRatio,
        'yRatio': yRatio,
        'widthRatio': widthRatio,
        'heightRatio': heightRatio,
      };
}
