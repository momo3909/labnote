import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';
import '../../../shared/painters/grid_layer_painter.dart';
import '../../../shared/painters/hex_layer_painter.dart';
import '../../../shared/painters/isometric_layer_painter.dart';
import '../../../core/constants/print_constants.dart';
import '../domain/editor_notifier.dart';
import '../../export/presentation/export_service.dart';
import '../../paywall/domain/entitlement_notifier.dart';
import '../../paywall/domain/free_limits.dart';
import '../../paywall/presentation/paywall_modal.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key, this.templateUuid, this.presetConfig});
  final String? templateUuid;
  final LayerConfig? presetConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final param = (uuid: templateUuid, preset: presetConfig);
    final state = ref.watch(editorNotifierProvider(param));
    final notifier = ref.read(editorNotifierProvider(param).notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(templateUuid == null ? '新規作成' : 'テンプレート編集'),
        actions: [
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
      body: Column(
        children: [
          Expanded(child: _buildPreview(state)),
          _buildBottomSheet(context, ref, state, notifier),
        ],
      ),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier,
  ) async {
    // 名前未設定の場合は先に保存
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
      uuid = await notifier.saveTemplate(null);
      ref.invalidate(templatesProvider);
    }

    if (!context.mounted) return;

    // ページ数選択（フリーは1ページのみ）
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

    // Export
    final template = await ref.read(templateRepositoryProvider).getByUuid(uuid);
    if (template == null || !context.mounted) return;
    await ExportService.sharePdf(template, pageCount: pageCount);

    // ソフトプロンプト（フリーユーザー・出力完了後）
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
    // 新規保存の場合のみ制限チェック
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
    await notifier.saveTemplate(null);
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

  Widget _buildLayerPaint(LayerConfig? config, PageConfig pageConfig) {
    const color = Color(0xFFAAAAAA);
    return switch (config) {
      GridLayerConfig() => CustomPaint(
          painter: GridLayerPainter(config: config, pageConfig: pageConfig, color: color),
        ),
      HexLayerConfig() => CustomPaint(
          painter: HexLayerPainter(config: config, pageConfig: pageConfig, color: color),
        ),
      IsometricLayerConfig() => CustomPaint(
          painter: IsometricLayerPainter(config: config, pageConfig: pageConfig, color: color),
        ),
      _ => const SizedBox.expand(),
    };
  }

  Widget _buildPreview(EditorState state) {
    final paperWidthMm = state.pageConfig.paperSize == PaperSize.a4 ? a4WidthMm : b5WidthMm;
    final paperHeightMm = state.pageConfig.paperSize == PaperSize.a4 ? a4HeightMm : b5HeightMm;
    final activeLayer = state.activeLayer;
    final config = activeLayer?.config;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: paperWidthMm / paperHeightMm,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
              ],
            ),
                    child: _buildLayerPaint(config, state.pageConfig),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, WidgetRef ref, EditorState state, EditorNotifier notifier) {
    final config = state.activeLayer?.config;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLayerControls(context, ref, state, notifier, config),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('用紙', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              _styleChip(
                label: 'A4',
                selected: state.pageConfig.paperSize == PaperSize.a4,
                onTap: () => notifier.updatePageConfig(
                  state.pageConfig.copyWith(paperSize: PaperSize.a4),
                ),
              ),
              const SizedBox(width: 8),
              _styleChip(
                label: 'B5',
                selected: state.pageConfig.paperSize == PaperSize.b5,
                onTap: () => notifier.updatePageConfig(
                  state.pageConfig.copyWith(paperSize: PaperSize.b5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _exportPdf(context, ref, state, notifier),
              child: const Text('PDF 出力'),
            ),
          ),
        ],
      ),
    );
  }

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
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(lineStyle: LineStyle.solid)),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '破線',
              selected: config.lineStyle == LineStyle.dashed,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(lineStyle: LineStyle.dashed)),
            ),
            const SizedBox(width: 8),
            _styleChip(
              label: '点線',
              selected: config.lineStyle == LineStyle.dotted,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(lineStyle: LineStyle.dotted)),
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
          onChanged: (v) => notifier.updateActiveLayerConfig(config.copyWith(hexSizeMm: v)),
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
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: enabled ? Colors.black87 : Colors.black38),
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
            style: TextStyle(fontSize: 12, color: enabled ? Colors.black87 : Colors.black38),
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
          style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black87),
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
