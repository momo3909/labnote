import 'dart:convert';
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
  final String layerType;
  final String configJson;

  const LayerEntity({
    required this.uuid,
    required this.sortOrder,
    this.isVisible = true,
    this.opacity = 1.0,
    this.colorHex = '#CCCCCC',
    required this.layerType,
    required this.configJson,
  });

  LayerConfig get config =>
      LayerConfig.fromJson(jsonDecode(configJson) as Map<String, dynamic>);

  factory LayerEntity.fromJson(Map<String, dynamic> json) => LayerEntity(
        uuid: json['uuid'] as String,
        sortOrder: json['sortOrder'] as int,
        isVisible: json['isVisible'] as bool? ?? true,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        colorHex: json['colorHex'] as String? ?? '#CCCCCC',
        layerType: json['layerType'] as String,
        configJson: json['configJson'] as String,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'sortOrder': sortOrder,
        'isVisible': isVisible,
        'opacity': opacity,
        'colorHex': colorHex,
        'layerType': layerType,
        'configJson': configJson,
      };
}
