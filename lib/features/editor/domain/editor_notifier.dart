import 'dart:convert';
import 'dart:typed_data';
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
    this.activeLayerIndex = 0,
    this.isSaving = false,
    this.savedUuid,
    this.isGridLinked = true,
    this.canUndo = false,
    this.canRedo = false,
  });

  final String name;
  final PageConfig pageConfig;
  final List<LayerEntity> layers;
  final int activeLayerIndex;
  final bool isSaving;
  final String? savedUuid;
  final bool isGridLinked;
  final bool canUndo;
  final bool canRedo;

  EditorState copyWith({
    String? name,
    PageConfig? pageConfig,
    List<LayerEntity>? layers,
    int? activeLayerIndex,
    bool? isSaving,
    String? savedUuid,
    bool? isGridLinked,
    bool? canUndo,
    bool? canRedo,
  }) =>
      EditorState(
        name: name ?? this.name,
        pageConfig: pageConfig ?? this.pageConfig,
        layers: layers ?? this.layers,
        activeLayerIndex: activeLayerIndex ?? this.activeLayerIndex,
        isSaving: isSaving ?? this.isSaving,
        savedUuid: savedUuid ?? this.savedUuid,
        isGridLinked: isGridLinked ?? this.isGridLinked,
        canUndo: canUndo ?? this.canUndo,
        canRedo: canRedo ?? this.canRedo,
      );

  LayerEntity? get activeLayer =>
      layers.isEmpty ? null : layers[activeLayerIndex.clamp(0, layers.length - 1)];
}

typedef EditorParam = ({String? uuid, LayerConfig? preset});

@riverpod
class EditorNotifier extends _$EditorNotifier {
  static const _uuid = Uuid();
  final List<EditorState> _history = [];
  final List<EditorState> _future = [];
  static const _maxHistory = 50;

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

  void _commit(EditorState next) {
    _history.add(state);
    if (_history.length > _maxHistory) _history.removeAt(0);
    _future.clear();
    state = next.copyWith(canUndo: true, canRedo: false);
  }

  void undo() {
    if (_history.isEmpty) return;
    _future.add(state);
    final prev = _history.removeLast();
    state = prev.copyWith(canUndo: _history.isNotEmpty, canRedo: true);
  }

  void redo() {
    if (_future.isEmpty) return;
    _history.add(state);
    final next = _future.removeLast();
    state = next.copyWith(canUndo: true, canRedo: _future.isNotEmpty);
  }

  Future<void> _loadTemplate(String uuid) async {
    final repo = ref.read(templateRepositoryProvider);
    final template = await repo.getByUuid(uuid);
    if (template == null) return;
    _history.clear();
    _future.clear();
    state = EditorState(
      name: template.name,
      pageConfig: template.pageConfig,
      layers: template.layers,
      savedUuid: uuid,
    );
  }

  void updatePageConfig(PageConfig config) {
    _commit(state.copyWith(pageConfig: config));
  }

  void updateActiveLayerConfig(LayerConfig config) {
    if (state.layers.isEmpty) return;
    final idx = state.activeLayerIndex.clamp(0, state.layers.length - 1);
    final updated = state.layers.toList();
    updated[idx] = updated[idx].copyWith(
      layerType: _layerType(config),
      configJson: jsonEncode(config.toJson()),
    );
    _commit(state.copyWith(layers: updated));
  }

  void setActiveLayerIndex(int index) {
    if (index < 0 || index >= state.layers.length) return;
    _commit(state.copyWith(activeLayerIndex: index));
  }

  void addLayer(LayerConfig config) {
    final newLayer = LayerEntity(
      uuid: _uuid.v4(),
      sortOrder: state.layers.length,
      layerType: _layerType(config),
      configJson: jsonEncode(config.toJson()),
    );
    final updated = [...state.layers, newLayer];
    _commit(state.copyWith(layers: updated, activeLayerIndex: updated.length - 1));
  }

  void removeLayer(int index) {
    if (state.layers.length <= 1) return;
    final updated = state.layers.toList()..removeAt(index);
    final newIndex = (state.activeLayerIndex >= updated.length)
        ? updated.length - 1
        : state.activeLayerIndex;
    _commit(state.copyWith(layers: updated, activeLayerIndex: newIndex));
  }

  void toggleLayerVisibility(int index) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    updated[index] = updated[index].copyWith(isVisible: !updated[index].isVisible);
    _commit(state.copyWith(layers: updated));
  }

  void updateLayerOpacity(int index, double opacity) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    updated[index] = updated[index].copyWith(opacity: opacity);
    // opacity はスライダー連続操作のため直接更新し、onChangeEnd でコミット
    state = state.copyWith(layers: updated);
  }

  void commitLayerOpacity(int index, double opacity) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    updated[index] = updated[index].copyWith(opacity: opacity);
    _commit(state.copyWith(layers: updated));
  }

  void updateLayerRegion(int index, {
    double? xRatio,
    double? yRatio,
    double? widthRatio,
    double? heightRatio,
  }) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    final old = updated[index];
    final newW = (widthRatio ?? old.widthRatio).clamp(0.01, 1.0);
    final newH = (heightRatio ?? old.heightRatio).clamp(0.01, 1.0);
    final newX = (xRatio ?? old.xRatio).clamp(0.0, 1.0 - newW);
    final newY = (yRatio ?? old.yRatio).clamp(0.0, 1.0 - newH);
    updated[index] = old.copyWith(
      xRatio: newX, yRatio: newY, widthRatio: newW, heightRatio: newH,
    );
    // スライダー連続操作のため直接更新
    state = state.copyWith(layers: updated);
  }

  void commitLayerRegion(int index) {
    _commit(state);
  }

  void updateLayerColor(int index, String colorHex) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    updated[index] = updated[index].copyWith(colorHex: colorHex);
    _commit(state.copyWith(layers: updated));
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void toggleGridLink() {
    _commit(state.copyWith(isGridLinked: !state.isGridLinked));
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

  Future<String> saveTemplate(String? authorId, {Uint8List? thumbnail}) async {
    state = state.copyWith(isSaving: true);
    final repo = ref.read(templateRepositoryProvider);
    final existingUuid = state.savedUuid;
    NotebookTemplate template;

    if (existingUuid != null) {
      final existing = await repo.getByUuid(existingUuid);
      if (existing != null) {
        existing
          ..name = state.name
          ..pageConfig = state.pageConfig
          ..layers = state.layers
          ..thumbnailPng = thumbnail ?? existing.thumbnailPng;
        template = await repo.save(existing);
      } else {
        template = await repo.create(
          name: state.name,
          pageConfig: state.pageConfig,
          layers: state.layers,
          authorId: authorId,
          thumbnail: thumbnail,
        );
      }
    } else {
      template = await repo.create(
        name: state.name,
        pageConfig: state.pageConfig,
        layers: state.layers,
        authorId: authorId,
        thumbnail: thumbnail,
      );
    }

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
        LogGridLayerConfig() => 'log_grid',
        CornellLayerConfig() => 'cornell',
        HexLayerConfig() => 'hex',
        IsometricLayerConfig() => 'isometric',
        PolarLayerConfig() => 'polar',
        ManuscriptLayerConfig() => 'manuscript',
        TimetableLayerConfig() => 'timetable',
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
