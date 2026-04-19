import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';
import '../../../shared/painters/cornell_layer_painter.dart';
import '../../../shared/painters/dot_layer_painter.dart';
import '../../../shared/painters/grid_layer_painter.dart';
import '../../../shared/painters/hex_layer_painter.dart';
import '../../../shared/painters/hole_marks_painter.dart';
import '../../../shared/painters/isometric_layer_painter.dart';
import '../../../shared/painters/log_grid_layer_painter.dart';
import '../../../shared/painters/page_elements_painter.dart';
import '../../../shared/painters/painter_utils.dart';
import '../../../core/constants/print_constants.dart';
import '../../../shared/models/notebook_template.dart';
import '../domain/editor_notifier.dart';
import '../../export/presentation/export_service.dart';
import '../../paywall/domain/entitlement_notifier.dart';
import '../../paywall/domain/free_limits.dart';
import '../../paywall/presentation/paywall_modal.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.templateUuid, this.presetConfig});
  final String? templateUuid;
  final LayerConfig? presetConfig;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _isExporting = false;
  bool _settingsExpanded = false;
  bool _marginExpanded = false;
  bool _marginsLinked = false;
  bool _positionExpanded = false;
  late final _transformController = TransformationController();
  Size? _previewSize;
  final _previewKey = GlobalKey();

  EditorParam get _param => (uuid: widget.templateUuid, preset: widget.presetConfig);

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // ── Zoom ──────────────────────────────────────────────────────────────────

  void _zoomBy(double factor) {
    final size = _previewSize;
    if (size == null) return;

    final matrix = _transformController.value;
    final currentScale = matrix.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.3, 6.0);
    if ((newScale - currentScale).abs() < 0.001) return;

    final tx = matrix[12];
    final ty = matrix[13];
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Keep the viewport center fixed in scene space
    final sceneCx = (cx - tx) / currentScale;
    final sceneCy = (cy - ty) / currentScale;
    final newTx = cx - sceneCx * newScale;
    final newTy = cy - sceneCy * newScale;

    _transformController.value = Matrix4.translationValues(newTx, newTy, 0)
      ..multiply(Matrix4.diagonal3Values(newScale, newScale, 1));
  }

  void _resetZoom() => _transformController.value = Matrix4.identity();

  Future<Uint8List?> _capturePreview() async {
    try {
      // Paint フェーズが完了してから layer を参照する
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || boundary.debugNeedsPaint || boundary.size.isEmpty) return null;
      final image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  // ── Margin helpers ────────────────────────────────────────────────────────

  void _updateMargin(
    EditorNotifier notifier,
    PageConfig pc, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (_marginsLinked) {
      final v = top ?? bottom ?? left ?? right ?? 0;
      notifier.updatePageConfig(pc.copyWith(
        marginTopMm: v,
        marginBottomMm: v,
        marginLeftMm: v,
        marginRightMm: v,
      ));
    } else {
      notifier.updatePageConfig(pc.copyWith(
        marginTopMm: top ?? pc.marginTopMm,
        marginBottomMm: bottom ?? pc.marginBottomMm,
        marginLeftMm: left ?? pc.marginLeftMm,
        marginRightMm: right ?? pc.marginRightMm,
      ));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorNotifierProvider(_param));
    final notifier = ref.read(editorNotifierProvider(_param).notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateUuid == null ? '新規作成' : 'テンプレート編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, size: 22),
            onPressed: state.canUndo ? notifier.undo : null,
            tooltip: '元に戻す',
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 22),
            onPressed: state.canRedo ? notifier.redo : null,
            tooltip: 'やり直し',
          ),
          state.isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: () => _showSaveDialog(context, ref, state, notifier),
                  child: const Text('保存'),
                ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, bodyConstraints) {
          // キーボード表示時など実際のボディ高さに応じて bottom sheet を制限する
          final maxSheetContentH =
              (bodyConstraints.maxHeight * 0.42).clamp(120.0, 320.0);
          return Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _previewSize = constraints.biggest;
                    return Stack(
                      children: [
                        InteractiveViewer(
                          transformationController: _transformController,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.3,
                          maxScale: 6.0,
                          child: _buildPreview(state),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildZoomButtons(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _buildBottomSheet(context, ref, state, notifier,
                  maxSheetContentH: maxSheetContentH),
            ],
          );
        },
      ),
    );
  }

  Widget _buildZoomButtons() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _zoomBtn(Icons.add, () => _zoomBy(1.5)),
          const SizedBox(width: 32, child: Divider(height: 1, indent: 4, endIndent: 4)),
          _zoomBtn(Icons.remove, () => _zoomBy(1 / 1.5)),
          const SizedBox(width: 32, child: Divider(height: 1, indent: 4, endIndent: 4)),
          _zoomBtn(Icons.fit_screen_outlined, _resetZoom),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        color: Colors.black87,
      ),
    );
  }

  // ── Export / Save dialogs ─────────────────────────────────────────────────

  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier,
  ) async {
    if (_isExporting) return;

    String? uuid = state.savedUuid;
    if (uuid == null) {
      final controller = TextEditingController(text: state.name);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('PDF出力前に保存'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'テンプレート名を入力'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('保存して出力'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      final name = controller.text.trim();
      if (name.isNotEmpty) notifier.updateName(name);
      uuid = await notifier.saveTemplate(null, thumbnail: await _capturePreview());
      ref.invalidate(templatesProvider);
    }

    if (!context.mounted) return;

    final isPro = ref.read(entitlementNotifierProvider).valueOrNull ?? false;
    int pageCount = state.pageConfig.pageCount;
    if (isPro) {
      final picked = await showDialog<int>(
        context: context,
        builder: (ctx) => _PageCountDialog(initial: pageCount),
      );
      if (picked == null || !context.mounted) return;
      pageCount = picked;
    } else {
      pageCount = freeMaxPdfPages;
    }

    setState(() => _isExporting = true);
    try {
      final template = await ref.read(templateRepositoryProvider).getByUuid(uuid);
      if (template == null || !context.mounted) return;
      await ExportService.sharePdf(template, pageCount: pageCount);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }

    if (!context.mounted) return;
    final isProNow = ref.read(entitlementNotifierProvider).valueOrNull ?? false;
    if (!isProNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('複数ページの一括出力は Pro プランでご利用いただけます'),
          action: SnackBarAction(
            label: 'Proを見る',
            onPressed: () => showPaywallModal(context),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _showSaveDialog(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier,
  ) async {
    // ダイアログを開く前にプレビューをキャプチャ（開いた後はサイズが変わる場合がある）
    final thumbnail = await _capturePreview();

    if (state.savedUuid == null) {
      final isPro = ref.read(entitlementNotifierProvider).valueOrNull ?? false;
      if (!isPro) {
        final all = await ref.read(templateRepositoryProvider).getAll();
        if (all.length >= freeMaxSavedTemplates && context.mounted) {
          final upgraded = await showPaywallModal(context);
          if (!upgraded || !context.mounted) return;
        }
      }
    }
    if (!context.mounted) return;

    final controller = TextEditingController(text: state.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('テンプレート名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'テンプレート名を入力'),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final name = controller.text.trim();
    if (name.isNotEmpty) notifier.updateName(name);
    await notifier.saveTemplate(null, thumbnail: thumbnail);
    ref.invalidate(templatesProvider);
    if (context.mounted) context.go('/');
  }

  Future<void> _onGridSizeChange(
    BuildContext context,
    WidgetRef ref,
    double value,
    void Function(double) update,
  ) async {
    final isPro = ref.read(entitlementNotifierProvider).valueOrNull ?? false;
    if (!isPro && value < freeMinGridSizeMm) {
      final upgraded = await showPaywallModal(context);
      if (!upgraded) return;
    }
    update(value);
  }

  // ── Preview ───────────────────────────────────────────────────────────────

  Widget _buildLayerPaint(
    LayerConfig? config,
    PageConfig pageConfig, {
    double opacity = 1.0,
    Color color = const Color(0xFFCCCCCC),
    LayerRegion region = LayerRegion.full,
  }) {
    return switch (config) {
      GridLayerConfig() => CustomPaint(
          painter: GridLayerPainter(
              config: config, pageConfig: pageConfig, color: color, opacity: opacity, region: region),
        ),
      HexLayerConfig() => CustomPaint(
          painter: HexLayerPainter(
              config: config, pageConfig: pageConfig, color: color, opacity: opacity, region: region),
        ),
      IsometricLayerConfig() => CustomPaint(
          painter: IsometricLayerPainter(
              config: config, pageConfig: pageConfig, color: color, opacity: opacity, region: region),
        ),
      DotLayerConfig() => CustomPaint(
          painter: DotLayerPainter(
              config: config, pageConfig: pageConfig, color: color, opacity: opacity, region: region),
        ),
      LogGridLayerConfig() => CustomPaint(
          painter: LogGridLayerPainter(
              config: config, pageConfig: pageConfig, color: color, opacity: opacity, region: region),
        ),
      CornellLayerConfig() => CustomPaint(
          painter: CornellLayerPainter(
              config: config, pageConfig: pageConfig, color: color, opacity: opacity, region: region),
        ),
      _ => const SizedBox.expand(),
    };
  }

  Widget _buildPreview(EditorState state) {
    final paperWidthMm = state.pageConfig.paperSize.widthMm;
    final paperHeightMm = state.pageConfig.paperSize.heightMm;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: paperWidthMm / paperHeightMm,
          child: RepaintBoundary(
            key: _previewKey,
            child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
              ],
            ),
            child: Stack(
              children: [
                ...state.layers
                    .where((l) => l.isVisible)
                    .map((l) => SizedBox.expand(
                          child: _buildLayerPaint(
                            l.config,
                            state.pageConfig,
                            opacity: l.opacity,
                            color: colorFromHex(l.colorHex),
                            region: LayerRegion(
                              x: l.xRatio,
                              y: l.yRatio,
                              width: l.widthRatio,
                              height: l.heightRatio,
                            ),
                          ),
                        )),
                if (state.pageConfig.showPageNumber || state.pageConfig.showLineNumbers)
                  SizedBox.expand(
                    child: CustomPaint(
                      painter: PageElementsPainter(
                        pageConfig: state.pageConfig,
                        layers: state.layers,
                        totalPages: state.pageConfig.pageCount,
                      ),
                    ),
                  ),
                if (state.pageConfig.holeConfig != HoleConfig.none)
                  SizedBox.expand(
                    child: CustomPaint(
                      painter: HoleMarksPainter(pageConfig: state.pageConfig),
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────

  Widget _buildBottomSheet(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier, {
    required double maxSheetContentH,
  }) {
    final config = state.activeLayer?.config;
    final pc = state.pageConfig;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Settings toggle header
          InkWell(
            onTap: () => setState(() => _settingsExpanded = !_settingsExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    '設定',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Icon(
                    _settingsExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible settings body
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _settingsExpanded
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxSheetContentH),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            // Layer list
                            _buildLayerListPanel(context, state, notifier),
                            const SizedBox(height: 8),

                            // Active layer controls
                            _buildLayerControls(context, ref, state, notifier, config),
                            const SizedBox(height: 8),

                            // Paper size
                            Row(
                              children: [
                                const Text('用紙', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 16),
                                ...{
                                  'A4': PaperSize.a4,
                                  'B5': PaperSize.b5,
                                  'A3': PaperSize.a3,
                                  'B4': PaperSize.b4,
                                  'Letter': PaperSize.letter,
                                }.entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _styleChip(
                                    label: e.key,
                                    selected: pc.paperSize == e.value,
                                    onTap: () => notifier.updatePageConfig(
                                      pc.copyWith(paperSize: e.value),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Hole punch
                            Row(
                              children: [
                                const Text('穴', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 16),
                                _styleChip(
                                  label: 'なし',
                                  selected: pc.holeConfig == HoleConfig.none,
                                  onTap: () => notifier.updatePageConfig(
                                    pc.copyWith(holeConfig: HoleConfig.none),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _styleChip(
                                  label: '26穴',
                                  selected: pc.holeConfig == HoleConfig.h26,
                                  onTap: () => notifier.updatePageConfig(
                                    pc.copyWith(holeConfig: HoleConfig.h26),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _styleChip(
                                  label: '30穴',
                                  selected: pc.holeConfig == HoleConfig.h30,
                                  onTap: () => notifier.updatePageConfig(
                                    pc.copyWith(holeConfig: HoleConfig.h30),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Page elements
                            Row(
                              children: [
                                const Text('挿入', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 16),
                                _toggleChip(
                                  label: 'ページ番号',
                                  enabled: pc.showPageNumber,
                                  onTap: () => notifier.updatePageConfig(
                                    pc.copyWith(showPageNumber: !pc.showPageNumber),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _toggleChip(
                                  label: '行番号',
                                  enabled: pc.showLineNumbers,
                                  onTap: () => notifier.updatePageConfig(
                                    pc.copyWith(showLineNumbers: !pc.showLineNumbers),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Margin section header (collapsible sub-section)
                            InkWell(
                              onTap: () => setState(() => _marginExpanded = !_marginExpanded),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Text('余白', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 8),
                                    // Link toggle
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _marginsLinked = !_marginsLinked),
                                      child: Tooltip(
                                        message: _marginsLinked ? '連動解除' : '上下左右を連動',
                                        child: Icon(
                                          _marginsLinked ? Icons.link : Icons.link_off,
                                          size: 16,
                                          color: _marginsLinked
                                              ? const Color(0xFF1A1A2E)
                                              : Colors.black38,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      _marginExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Collapsible margin controls
                            ClipRect(
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: _marginExpanded
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 4),
                                          // Presets
                                          Row(
                                            children: [
                                              _styleChip(
                                                label: 'なし',
                                                selected: pc.marginLeftMm == 0 &&
                                                    pc.marginTopMm == 0,
                                                onTap: () => notifier.updatePageConfig(
                                                  pc.copyWith(
                                                    marginTopMm: 0,
                                                    marginBottomMm: 0,
                                                    marginLeftMm: 0,
                                                    marginRightMm: 0,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              _styleChip(
                                                label: '標準',
                                                selected: pc.marginTopMm == 10 &&
                                                    pc.marginBottomMm == 10 &&
                                                    pc.marginLeftMm == 10 &&
                                                    pc.marginRightMm == 10,
                                                onTap: () => notifier.updatePageConfig(
                                                  pc.copyWith(
                                                    marginTopMm: 10,
                                                    marginBottomMm: 10,
                                                    marginLeftMm: 10,
                                                    marginRightMm: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              _styleChip(
                                                label: '26穴',
                                                selected: pc.marginLeftMm == 20 &&
                                                    pc.marginTopMm == 10,
                                                onTap: () => notifier.updatePageConfig(
                                                  pc.copyWith(
                                                    marginTopMm: 10,
                                                    marginBottomMm: 10,
                                                    marginLeftMm: 20,
                                                    marginRightMm: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          _buildSliderRow(
                                            label: '上',
                                            value: pc.marginTopMm,
                                            min: 0,
                                            max: 30,
                                            onChanged: (v) => _updateMargin(
                                              notifier, pc, top: v,
                                            ),
                                          ),
                                          _buildSliderRow(
                                            label: '下',
                                            value: pc.marginBottomMm,
                                            min: 0,
                                            max: 30,
                                            onChanged: (v) => _updateMargin(
                                              notifier, pc, bottom: v,
                                            ),
                                          ),
                                          _buildSliderRow(
                                            label: '左',
                                            value: pc.marginLeftMm,
                                            min: 0,
                                            max: 30,
                                            onChanged: (v) => _updateMargin(
                                              notifier, pc, left: v,
                                            ),
                                          ),
                                          _buildSliderRow(
                                            label: '右',
                                            value: pc.marginRightMm,
                                            min: 0,
                                            max: 30,
                                            onChanged: (v) => _updateMargin(
                                              notifier, pc, right: v,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),

                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // PDF button — always visible
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isExporting
                    ? null
                    : () => _exportPdf(context, ref, state, notifier),
                child: _isExporting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('PDF 出力'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layer management panel ────────────────────────────────────────────────

  static const _lineColorSwatches = [
    ('#CCCCCC', '灰'),
    ('#1565C0', '青'),
    ('#B71C1C', '赤'),
    ('#1B5E20', '緑'),
    ('#4A148C', '紫'),
    ('#E65100', '橙'),
    ('#37474F', '墨'),
  ];

  static const _addableLayerTypes = [
    (label: '方眼', config: LayerConfig.grid()),
    (label: 'ドット', config: LayerConfig.dot()),
    (label: '片対数', config: LayerConfig.logGrid(xScale: LogScale.linear, yScale: LogScale.log)),
    (label: '両対数', config: LayerConfig.logGrid(xScale: LogScale.log, yScale: LogScale.log)),
    (label: '六角形', config: LayerConfig.hex()),
    (label: '製図', config: LayerConfig.isometric()),
    (label: 'コーネル', config: LayerConfig.cornell()),
  ];

  String _layerLabel(LayerEntity layer) => switch (layer.layerType) {
        'grid' => '方眼',
        'dot' => 'ドット',
        'hex' => '六角形',
        'isometric' => '製図',
        'log_grid' => '対数グリッド',
        'cornell' => 'コーネル',
        _ => layer.layerType,
      };

  Widget _buildLayerListPanel(
    BuildContext context,
    EditorState state,
    EditorNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('レイヤー', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddLayerSheet(context, notifier),
              child: const Icon(Icons.add, size: 20, color: Color(0xFF1A1A2E)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...List.generate(state.layers.length, (i) {
          final layer = state.layers[i];
          final isActive = i == state.activeLayerIndex;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => notifier.setActiveLayerIndex(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1A1A2E).withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isActive
                        ? Border.all(color: const Color(0xFF1A1A2E), width: 1)
                        : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _layerLabel(layer),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 4),
                        ..._lineColorSwatches.map((s) {
                          final (hex, _) = s;
                          final selected =
                              layer.colorHex.toUpperCase() == hex.toUpperCase();
                          return GestureDetector(
                            onTap: () => notifier.updateLayerColor(i, hex),
                            child: Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                color: colorFromHex(hex),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? Colors.black87 : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(
                          width: 64,
                          child: Slider(
                            value: layer.opacity,
                            min: 0.1,
                            max: 1.0,
                            onChanged: (v) => notifier.updateLayerOpacity(i, v),
                            onChangeEnd: (v) => notifier.commitLayerOpacity(i, v),
                          ),
                        ),
                      ],
                      GestureDetector(
                        onTap: () => notifier.toggleLayerVisibility(i),
                        child: Icon(
                          layer.isVisible ? Icons.visibility : Icons.visibility_off,
                          size: 18,
                          color: layer.isVisible ? Colors.black54 : Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (state.layers.length > 1)
                        GestureDetector(
                          onTap: () => notifier.removeLayer(i),
                          child: const Icon(Icons.close, size: 18, color: Colors.black38),
                        ),
                    ],
                  ),
                ),
              ),
              if (isActive) ...[
                _buildLayerPositionPanel(i, layer, notifier),
                const SizedBox(height: 4),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLayerPositionPanel(int index, LayerEntity layer, EditorNotifier notifier) {
    const presets = [
      (label: '全体',   xR: 0.0, yR: 0.0, wR: 1.0, hR: 1.0),
      (label: '上半分', xR: 0.0, yR: 0.0, wR: 1.0, hR: 0.5),
      (label: '下半分', xR: 0.0, yR: 0.5, wR: 1.0, hR: 0.5),
      (label: '左半分', xR: 0.0, yR: 0.0, wR: 0.5, hR: 1.0),
      (label: '右半分', xR: 0.5, yR: 0.0, wR: 0.5, hR: 1.0),
    ];

    final xMax = (1.0 - layer.widthRatio).clamp(0.0, 1.0);
    final yMax = (1.0 - layer.heightRatio).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー（折りたたみ）
          InkWell(
            onTap: () => setState(() => _positionExpanded = !_positionExpanded),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Text('配置', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(width: 8),
                  // 現在のプリセット名を表示
                  Text(
                    presets.where((p) =>
                      layer.xRatio == p.xR && layer.yRatio == p.yR &&
                      layer.widthRatio == p.wR && layer.heightRatio == p.hR
                    ).map((p) => p.label).firstOrNull ?? 'カスタム',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF1A1A2E)),
                  ),
                  const Spacer(),
                  Icon(
                    _positionExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          // 折りたたみ本体
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _positionExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: presets.map((p) {
                              final selected = layer.xRatio == p.xR &&
                                  layer.yRatio == p.yR &&
                                  layer.widthRatio == p.wR &&
                                  layer.heightRatio == p.hR;
                              return _styleChip(
                                label: p.label,
                                selected: selected,
                                onTap: () => notifier.updateLayerRegion(
                                  index,
                                  xRatio: p.xR, yRatio: p.yR,
                                  widthRatio: p.wR, heightRatio: p.hR,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 4),
                          _buildRatioSlider(
                            label: 'X',
                            value: layer.xRatio,
                            max: xMax,
                            onChanged: (v) => notifier.updateLayerRegion(index, xRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                          _buildRatioSlider(
                            label: 'Y',
                            value: layer.yRatio,
                            max: yMax,
                            onChanged: (v) => notifier.updateLayerRegion(index, yRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                          _buildRatioSlider(
                            label: '幅',
                            value: layer.widthRatio,
                            onChanged: (v) => notifier.updateLayerRegion(index, widthRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                          _buildRatioSlider(
                            label: '高さ',
                            value: layer.heightRatio,
                            onChanged: (v) => notifier.updateLayerRegion(index, heightRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    double max = 1.0,
  }) {
    final effective = value.clamp(0.0, max);
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ),
        Expanded(
          child: Slider(
            value: effective,
            min: 0.0,
            max: max > 0 ? max : 0.01,
            divisions: ((max > 0 ? max : 0.01) * 20).round().clamp(1, 100),
            onChanged: max > 0 ? onChanged : null,
            onChangeEnd: onChangeEnd,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(effective * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  void _showAddLayerSheet(BuildContext context, EditorNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'レイヤーを追加',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ..._addableLayerTypes.map((t) => ListTile(
                  title: Text(t.label),
                  onTap: () {
                    notifier.addLayer(t.config);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Layer controls ────────────────────────────────────────────────────────

  Widget _buildLayerControls(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier,
    LayerConfig? config,
  ) {
    return switch (config) {
      GridLayerConfig() => _buildGridControls(context, ref, state, notifier, config),
      HexLayerConfig() => _buildHexControls(notifier, config),
      IsometricLayerConfig() => _buildIsometricControls(notifier, config),
      DotLayerConfig() => _buildDotControls(notifier, config),
      LogGridLayerConfig() => _buildLogGridControls(notifier, config),
      CornellLayerConfig() => _buildCornellControls(notifier, config),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildGridControls(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier,
    GridLayerConfig config,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const SizedBox(width: 80),
            const Spacer(),
            const Text('縦横連動', style: TextStyle(fontSize: 12, color: Colors.black54)),
            Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: state.isGridLinked,
                onChanged: (_) => notifier.toggleGridLink(),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        _buildSliderRow(
          label: 'グリッド幅',
          value: config.cellWidthMm,
          min: 1,
          max: 20,
          onChanged: (v) => _onGridSizeChange(context, ref, v, notifier.updateGridWidth),
        ),
        _buildSliderRow(
          label: 'グリッド高さ',
          value: config.cellHeightMm,
          min: 1,
          max: 20,
          enabled: !state.isGridLinked,
          onChanged: (v) => _onGridSizeChange(context, ref, v, notifier.updateGridHeight),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('線種', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            _styleChip(
              label: '実線',
              selected: config.lineStyle == LineStyle.solid,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(lineStyle: LineStyle.solid),
              ),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '破線',
              selected: config.lineStyle == LineStyle.dashed,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(lineStyle: LineStyle.dashed),
              ),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '点線',
              selected: config.lineStyle == LineStyle.dotted,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(lineStyle: LineStyle.dotted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('表示', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            _styleChip(
              label: '横線',
              selected: config.showHorizontal,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(showHorizontal: !config.showHorizontal),
              ),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '縦線',
              selected: config.showVertical,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(showVertical: !config.showVertical),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHexControls(EditorNotifier notifier, HexLayerConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSliderRow(
          label: '六角形サイズ',
          value: config.hexSizeMm,
          min: 2,
          max: 20,
          onChanged: (v) =>
              notifier.updateActiveLayerConfig(config.copyWith(hexSizeMm: v)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('向き', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            _styleChip(
              label: 'フラット',
              selected: config.orientation == HexOrientation.flat,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(orientation: HexOrientation.flat),
              ),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '尖り',
              selected: config.orientation == HexOrientation.pointy,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(orientation: HexOrientation.pointy),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIsometricControls(EditorNotifier notifier, IsometricLayerConfig config) {
    return _buildSliderRow(
      label: '間隔',
      value: config.spacingMm,
      min: 2,
      max: 20,
      onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(spacingMm: v)),
    );
  }

  Widget _buildDotControls(EditorNotifier notifier, DotLayerConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSliderRow(
          label: 'ドット間隔',
          value: config.spacingMm,
          min: 2,
          max: 20,
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(spacingMm: v)),
        ),
        _buildSliderRow(
          label: 'ドット径',
          value: config.dotRadiusMm * 2,
          min: 0.2,
          max: 2.0,
          onChanged: (v) =>
              notifier.updateActiveLayerConfig(config.copyWith(dotRadiusMm: v / 2)),
        ),
      ],
    );
  }

  Widget _buildCornellControls(EditorNotifier notifier, CornellLayerConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSliderRow(
          label: 'キーワード欄',
          value: config.leftColMm,
          min: 20,
          max: 80,
          onChanged: (v) =>
              notifier.updateActiveLayerConfig(config.copyWith(leftColMm: v)),
        ),
        _buildSliderRow(
          label: 'サマリー欄',
          value: config.bottomRowMm,
          min: 10,
          max: 60,
          onChanged: (v) =>
              notifier.updateActiveLayerConfig(config.copyWith(bottomRowMm: v)),
        ),
        _buildSliderRow(
          label: '罫線間隔',
          value: config.lineSpacingMm,
          min: 4,
          max: 12,
          onChanged: (v) =>
              notifier.updateActiveLayerConfig(config.copyWith(lineSpacingMm: v)),
        ),
      ],
    );
  }

  Widget _buildLogGridControls(EditorNotifier notifier, LogGridLayerConfig config) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('X軸', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            _styleChip(
              label: '等間隔',
              selected: config.xScale == LogScale.linear,
              onTap: () => notifier.updateActiveLayerConfig(
                  config.copyWith(xScale: LogScale.linear)),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '対数',
              selected: config.xScale == LogScale.log,
              onTap: () => notifier.updateActiveLayerConfig(
                  config.copyWith(xScale: LogScale.log)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('Y軸', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            _styleChip(
              label: '等間隔',
              selected: config.yScale == LogScale.linear,
              onTap: () => notifier.updateActiveLayerConfig(
                  config.copyWith(yScale: LogScale.linear)),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '対数',
              selected: config.yScale == LogScale.log,
              onTap: () => notifier.updateActiveLayerConfig(
                  config.copyWith(yScale: LogScale.log)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (config.xScale == LogScale.log)
          _buildSliderRow(
            label: 'X デケード',
            value: config.xDecades.toDouble(),
            min: 1,
            max: 5,
            onChanged: (v) => notifier.updateActiveLayerConfig(
                config.copyWith(xDecades: v.round())),
          ),
        if (config.yScale == LogScale.log)
          _buildSliderRow(
            label: 'Y デケード',
            value: config.yDecades.toDouble(),
            min: 1,
            max: 5,
            onChanged: (v) => notifier.updateActiveLayerConfig(
                config.copyWith(yDecades: v.round())),
          ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    bool enabled = true,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: enabled ? Colors.black87 : Colors.black38,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '${value.toStringAsFixed(1)}mm',
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.black87 : Colors.black38,
            ),
          ),
        ),
      ],
    );
  }

  Widget _styleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1A1A2E).withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: enabled ? const Color(0xFF1A1A2E) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_box : Icons.check_box_outline_blank,
              size: 14,
              color: enabled ? const Color(0xFF1A1A2E) : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? const Color(0xFF1A1A2E) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCountDialog extends StatefulWidget {
  const _PageCountDialog({required this.initial});
  final int initial;

  @override
  State<_PageCountDialog> createState() => _PageCountDialogState();
}

class _PageCountDialogState extends State<_PageCountDialog> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initial.clamp(1, 50);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ページ数'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _count > 1 ? () => setState(() => _count--) : null,
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$_count',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _count < 50 ? () => setState(() => _count++) : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _count),
          child: const Text('出力'),
        ),
      ],
    );
  }
}
