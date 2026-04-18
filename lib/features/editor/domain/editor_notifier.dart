import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';
import '../../templates/data/template_repository.dart';
import '../data/app_database.dart';

part 'editor_notifier.g.dart';

class EditorState {
  const EditorState({
    required this.name,
    required this.pageConfig,
    required this.layers,
    this.isSaving = false,
    this.savedUuid,
    this.isGridLinked = true,
  });

  final String name;
  final PageConfig pageConfig;
  final List<LayerEntity> layers;
  final bool isSaving;
  final String? savedUuid;
  final bool isGridLinked;

  EditorState copyWith({
    String? name,
    PageConfig? pageConfig,
    List<LayerEntity>? layers,
    bool? isSaving,
    String? savedUuid,
    bool? isGridLinked,
  }) =>
      EditorState(
        name: name ?? this.name,
        pageConfig: pageConfig ?? this.pageConfig,
        layers: layers ?? this.layers,
        isSaving: isSaving ?? this.isSaving,
        savedUuid: savedUuid ?? this.savedUuid,
        isGridLinked: isGridLinked ?? this.isGridLinked,
      );

  LayerEntity? get activeLayer => layers.isEmpty ? null : layers.first;
}

typedef EditorParam = ({String? uuid, LayerConfig? preset});

@riverpod
class EditorNotifier extends _$EditorNotifier {
  static const _uuid = Uuid();

  @override
  EditorState build(EditorParam param) {
    final initialLayer = param.preset != null
        ? _layerFromConfig(param.preset!)
        : _defaultGridLayer();
    if (param.uuid != null) _loadTemplate(param.uuid!);
    return EditorState(
      name: '新しいテンプレート',
      pageConfig: const PageConfig(),
      layers: [initialLayer],
    );
  }

  Future<void> _loadTemplate(String uuid) async {
    final repo = ref.read(templateRepositoryProvider);
    final template = await repo.getByUuid(uuid);
    if (template == null) return;
    state = EditorState(
      name: template.name,
      pageConfig: template.pageConfig,
      layers: template.layers,
      savedUuid: uuid,
    );
  }

  void updatePageConfig(PageConfig config) {
    state = state.copyWith(pageConfig: config);
  }

  void updateActiveLayerConfig(LayerConfig config) {
    if (state.layers.isEmpty) return;
    final updated = state.layers.toList();
    final old = updated.first;
    updated[0] = LayerEntity(
      uuid: old.uuid,
      sortOrder: old.sortOrder,
      isVisible: old.isVisible,
      opacity: old.opacity,
      colorHex: old.colorHex,
      layerType: _layerType(config),
      configJson: jsonEncode(config.toJson()),
    );
    state = state.copyWith(layers: updated);
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void toggleGridLink() {
    state = state.copyWith(isGridLinked: !state.isGridLinked);
  }

  void updateGridWidth(double widthMm) {
    final config = state.activeLayer?.config;
    if (config is! GridLayerConfig) return;
    updateActiveLayerConfig(
      state.isGridLinked
          ? config.copyWith(cellWidthMm: widthMm, cellHeightMm: widthMm)
          : config.copyWith(cellWidthMm: widthMm),
    );
  }

  void updateGridHeight(double heightMm) {
    final config = state.activeLayer?.config;
    if (config is! GridLayerConfig) return;
    updateActiveLayerConfig(
      state.isGridLinked
          ? config.copyWith(cellWidthMm: heightMm, cellHeightMm: heightMm)
          : config.copyWith(cellHeightMm: heightMm),
    );
  }

  Future<String> saveTemplate(String? authorId) async {
    state = state.copyWith(isSaving: true);
    final repo = ref.read(templateRepositoryProvider);
    final template = await repo.create(
      name: state.name,
      pageConfig: state.pageConfig,
      layers: state.layers,
      authorId: authorId,
    );
    state = state.copyWith(isSaving: false, savedUuid: template.uuid);
    return template.uuid;
  }

  LayerEntity _defaultGridLayer() => _layerFromConfig(const LayerConfig.grid());

  LayerEntity _layerFromConfig(LayerConfig config) => LayerEntity(
        uuid: _uuid.v4(),
        sortOrder: 0,
        layerType: _layerType(config),
        configJson: jsonEncode(config.toJson()),
      );

  String _layerType(LayerConfig config) => switch (config) {
        GridLayerConfig() => 'grid',
        DotLayerConfig() => 'dot',
        HexLayerConfig() => 'hex',
        IsometricLayerConfig() => 'isometric',
        RegionLayerConfig() => 'region',
        GuideLayerConfig() => 'guide',
      };
}

@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

@riverpod
TemplateRepository templateRepository(Ref ref) =>
    TemplateRepository(ref.watch(appDatabaseProvider));

@riverpod
Future<List<NotebookTemplate>> templates(Ref ref) =>
    ref.watch(templateRepositoryProvider).getAll();
