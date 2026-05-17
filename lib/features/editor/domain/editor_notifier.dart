import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/models/page_config.dart';
import '../../../core/constants/print_constants.dart';
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
    this.isDirty = false,
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
  final bool isDirty;

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
    bool? isDirty,
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
        isDirty: isDirty ?? this.isDirty,
      );

  LayerEntity? get activeLayer =>
      layers.isEmpty ? null : layers[activeLayerIndex.clamp(0, layers.length - 1)];
}

/// プリセット1レイヤー分の定義。yRatio/heightRatio でページ内の初期位置、colorHex で色を指定する。
typedef LayerPreset = ({LayerConfig config, double yRatio, double heightRatio, String? colorHex});

typedef EditorParam = ({String? uuid, List<LayerPreset>? presets});

@riverpod
class EditorNotifier extends _$EditorNotifier {
  static const _uuid = Uuid();
  final List<EditorState> _history = [];
  final List<EditorState> _future = [];
  static const _maxHistory = 50;
  // ドラッグ/スライダー操作開始前の状態（undo の起点として使う）
  EditorState? _preDragState;
  // ドラッグ目的のレイヤー切替フラグ（ref.listen でのリセットを抑制する）
  bool _pendingDragMode = false;

  @override
  EditorState build(EditorParam param) {
    final presets = param.presets;
    final initialLayers = (presets != null && presets.isNotEmpty)
        ? presets.map((p) => _layerFromConfig(p.config, yRatio: p.yRatio, heightRatio: p.heightRatio, colorHex: p.colorHex)).toList()
        : <LayerEntity>[];
    if (param.uuid != null) _loadTemplate(param.uuid!);
    return EditorState(
      name: '新しいテンプレート',
      pageConfig: const PageConfig(),
      layers: initialLayers,
    );
  }

  void _commit(EditorState next) {
    _history.add(state);
    if (_history.length > _maxHistory) _history.removeAt(0);
    _future.clear();
    state = next.copyWith(canUndo: true, canRedo: false, isDirty: true);
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

  /// 表レイヤー専用: config を更新し、全行が収まる高さを自動計算して同時コミット。
  void updateTableConfig(TableLayerConfig config) {
    if (state.layers.isEmpty) return;
    final idx = state.activeLayerIndex.clamp(0, state.layers.length - 1);
    final layer = state.layers[idx];
    final pageH = state.pageConfig.effectiveHeightMm;
    final totalHeightMm = config.rows * config.cellHeightMm;
    final newH = (totalHeightMm / pageH).clamp(0.05, 1.0 - layer.yRatio);
    final updated = state.layers.toList();
    updated[idx] = updated[idx].copyWith(
      layerType: _layerType(config),
      configJson: jsonEncode(config.toJson()),
      heightRatio: newH,
    );
    _commit(state.copyWith(layers: updated));
  }

  void addStampItem(double xRatio, double yRatio, String shapeType, double widthMm, double heightMm) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final item = StampItem(
      shapeType: shapeType,
      xRatio: xRatio,
      yRatio: yRatio,
      sizeMm: widthMm,
      widthMm: widthMm,
      heightMm: heightMm,
    );
    updateActiveLayerConfig(config.copyWith(items: [...config.items, item]));
  }

  void updateStampSize(int itemIndex, double widthMm, double heightMm) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final items = config.items.toList();
    items[itemIndex] = items[itemIndex].copyWith(widthMm: widthMm, heightMm: heightMm);
    updateActiveLayerConfig(config.copyWith(items: items));
  }

  void removeStampItem(int itemIndex) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final items = [...config.items]..removeAt(itemIndex);
    updateActiveLayerConfig(config.copyWith(items: items));
  }

  void ungroupStamps(int stampIndex) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final groupId = config.items[stampIndex].groupId;
    if (groupId == null) return;
    final updated = config.items
        .map((item) => item.groupId == groupId ? item.copyWith(groupId: null) : item)
        .toList();
    updateActiveLayerConfig(config.copyWith(items: updated));
  }

  void clearStampItems() {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    updateActiveLayerConfig(config.copyWith(items: const []));
  }

  void addStampGrid({
    required String shapeType,
    required double widthMm,
    required double heightMm,
    required int columns,
    required int rows,
    required double hSpacingMm,
    required double vSpacingMm,
  }) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final pageW = state.pageConfig.effectiveWidthMm;
    final pageH = state.pageConfig.effectiveHeightMm;
    final totalW = columns * widthMm + (columns - 1) * hSpacingMm;
    final totalH = rows * heightMm + (rows - 1) * vSpacingMm;
    final startX = (pageW - totalW) / 2 + widthMm / 2;
    final startY = (pageH - totalH) / 2 + heightMm / 2;
    final groupId = _uuid.v4();
    final newItems = <StampItem>[
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < columns; c++)
          StampItem(
            shapeType: shapeType,
            xRatio: ((startX + c * (widthMm + hSpacingMm)) / pageW).clamp(0.0, 1.0),
            yRatio: ((startY + r * (heightMm + vSpacingMm)) / pageH).clamp(0.0, 1.0),
            sizeMm: widthMm,
            widthMm: widthMm,
            heightMm: heightMm,
            groupId: groupId,
          ),
    ];
    updateActiveLayerConfig(config.copyWith(items: [...config.items, ...newItems]));
  }

  void updateStampColor(int itemIndex, String colorHex) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final items = config.items.toList();
    items[itemIndex] = items[itemIndex].copyWith(colorHex: colorHex);
    updateActiveLayerConfig(config.copyWith(items: items));
  }

  void updateStampRotation(int itemIndex, double rotation) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final items = config.items.toList();
    items[itemIndex] = items[itemIndex].copyWith(rotation: rotation % 360);
    updateActiveLayerConfig(config.copyWith(items: items));
  }

  void updateStampStrokeScale(int itemIndex, double strokeScale) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig) return;
    final items = config.items.toList();
    items[itemIndex] = items[itemIndex].copyWith(strokeScale: strokeScale);
    updateActiveLayerConfig(config.copyWith(items: items));
  }

  void previewStampItems(List<StampItem> items) {
    final config = state.activeLayer?.config;
    if (config is! StampLayerConfig || state.layers.isEmpty) return;
    // 連続操作の初回でドラッグ前状態を保存
    _preDragState ??= state;
    final idx = state.activeLayerIndex.clamp(0, state.layers.length - 1);
    final updated = state.layers.toList();
    updated[idx] = updated[idx].copyWith(
      configJson: jsonEncode(config.copyWith(items: items).toJson()),
    );
    state = state.copyWith(layers: updated);
  }

  void commitStampItems() {
    final pre = _preDragState;
    if (pre != null) {
      _history.add(pre);
      if (_history.length > _maxHistory) _history.removeAt(0);
      _future.clear();
      state = state.copyWith(canUndo: true, canRedo: false, isDirty: true);
      _preDragState = null;
    } else {
      _commit(state);
    }
  }

  void setActiveLayerIndex(int index) {
    if (index < 0 || index >= state.layers.length) return;
    // レイヤー選択はデザイン変更ではないためundoスタックに積まない
    state = state.copyWith(activeLayerIndex: index);
  }

  /// ドラッグモード移行を伴うレイヤー切替（ref.listen のリセットを抑制）
  void setActiveLayerIndexForDrag(int index) {
    if (index < 0 || index >= state.layers.length) return;
    _pendingDragMode = true;
    state = state.copyWith(activeLayerIndex: index);
  }

  /// ref.listen からドラッグ目的フラグを確認・消費する
  bool consumePendingDragMode() {
    final v = _pendingDragMode;
    _pendingDragMode = false;
    return v;
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

  void moveLayerToFront(int index) => _moveLayer(index, state.layers.length - 1);
  void moveLayerToBack(int index) => _moveLayer(index, 0);
  void moveLayerUp(int index) => _moveLayer(index, index + 1);
  void moveLayerDown(int index) => _moveLayer(index, index - 1);

  void _moveLayer(int from, int to) {
    final last = state.layers.length - 1;
    if (from < 0 || from > last || to < 0 || to > last || from == to) return;
    final updated = state.layers.toList();
    final layer = updated.removeAt(from);
    updated.insert(to, layer);
    _commit(state.copyWith(layers: updated, activeLayerIndex: to));
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
    // 連続操作の初回呼び出しでドラッグ前状態を保存（undo 起点）
    _preDragState ??= state;
    final updated = state.layers.toList();
    final old = updated[index];
    final newW = (widthRatio ?? old.widthRatio).clamp(0.01, 1.0);
    final newH = (heightRatio ?? old.heightRatio).clamp(0.01, 1.0);
    final newX = (xRatio ?? old.xRatio).clamp(0.0, 1.0 - newW);
    final newY = (yRatio ?? old.yRatio).clamp(0.0, 1.0 - newH);
    updated[index] = old.copyWith(
      xRatio: newX, yRatio: newY, widthRatio: newW, heightRatio: newH,
    );
    state = state.copyWith(layers: updated);
  }

  void commitLayerRegion(int index) {
    final pre = _preDragState;
    if (pre == null) return;
    // ドラッグ前状態を history に積み、現在の最終位置を確定
    _history.add(pre);
    if (_history.length > _maxHistory) _history.removeAt(0);
    _future.clear();
    state = state.copyWith(canUndo: true, canRedo: false, isDirty: true);
    _preDragState = null;
  }

  void updateLayerColor(int index, String colorHex) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    updated[index] = updated[index].copyWith(colorHex: colorHex);
    _commit(state.copyWith(layers: updated));
  }

  void updateLayerBgColor(int index, String bgColorHex) {
    if (index < 0 || index >= state.layers.length) return;
    final updated = state.layers.toList();
    updated[index] = updated[index].copyWith(bgColorHex: bgColorHex);
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

    state = state.copyWith(isSaving: false, savedUuid: template.uuid, isDirty: false);
    return template.uuid;
  }

  LayerEntity _layerFromConfig(LayerConfig config,
          {double yRatio = 0, double heightRatio = 1, String? colorHex}) =>
      LayerEntity(
        uuid: _uuid.v4(),
        sortOrder: 0,
        layerType: _layerType(config),
        configJson: jsonEncode(config.toJson()),
        yRatio: yRatio,
        heightRatio: heightRatio,
        colorHex: colorHex ?? '#CCCCCC',
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
        StaffLayerConfig() => 'staff',
        RuledGridLayerConfig() => 'ruledGrid',
        StampLayerConfig() => 'stamp',
        GraphAxisLayerConfig() => 'graphAxis',
        TableLayerConfig() => 'table',
        CustomLineLayerConfig() => 'customLine',

        HeaderLayerConfig() => 'header',
      };
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

@Riverpod(keepAlive: true)
TemplateRepository templateRepository(Ref ref) =>
    TemplateRepository(ref.watch(appDatabaseProvider));

@riverpod
Future<List<NotebookTemplate>> templates(Ref ref) =>
    ref.watch(templateRepositoryProvider).getAll();
