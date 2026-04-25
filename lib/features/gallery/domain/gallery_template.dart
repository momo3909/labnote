import 'dart:convert';
import 'dart:typed_data';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';

class GalleryTemplate {
  const GalleryTemplate({
    required this.id,
    required this.name,
    required this.authorId,
    required this.layerTypes,
    required this.downloadCount,
    required this.likeCount,
    required this.createdAt,
    required this.pageConfigJson,
    required this.layersJson,
    this.description = '',
    this.authorName = '',
    this.authorAvatarUrl,
    this.thumbnailBytes,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final List<String> layerTypes;
  final int downloadCount;
  final int likeCount;
  final DateTime createdAt;
  final String pageConfigJson;
  final List<String> layersJson;
  final String description;
  final Uint8List? thumbnailBytes;
  final List<String> tags;

  PageConfig get pageConfig =>
      PageConfig.fromJson(jsonDecode(pageConfigJson) as Map<String, dynamic>);

  List<LayerEntity> get layers => layersJson
      .map((j) => LayerEntity.fromJson(jsonDecode(j) as Map<String, dynamic>))
      .toList();

  GalleryTemplate copyWith({int? likeCount}) => GalleryTemplate(
        id: id,
        name: name,
        authorId: authorId,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        layerTypes: layerTypes,
        downloadCount: downloadCount,
        likeCount: likeCount ?? this.likeCount,
        createdAt: createdAt,
        pageConfigJson: pageConfigJson,
        layersJson: layersJson,
        description: description,
        thumbnailBytes: thumbnailBytes,
        tags: tags,
      );
}
