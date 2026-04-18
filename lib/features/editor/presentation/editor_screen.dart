import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/page_config.dart';
import '../../../shared/painters/grid_layer_painter.dart';
import '../../../core/constants/print_constants.dart';
import '../domain/editor_notifier.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key, this.templateUuid});
  final String? templateUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider(templateUuid));
    final notifier = ref.read(editorNotifierProvider(templateUuid).notifier);
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
          _buildBottomSheet(state, notifier),
        ],
      ),
    );
  }

  Future<void> _showSaveDialog(
    BuildContext context,
    WidgetRef ref,
    EditorState state,
    EditorNotifier notifier,
  ) async {
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
            child: config is GridLayerConfig
                ? CustomPaint(
                    painter: GridLayerPainter(
                      config: config,
                      pageConfig: state.pageConfig,
                      color: const Color(0xFFAAAAAA),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(EditorState state, EditorNotifier notifier) {
    final config = state.activeLayer?.config;
    final gridConfig = config is GridLayerConfig ? config : const GridLayerConfig();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
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
            value: gridConfig.cellWidthMm,
            min: 1,
            max: 20,
            onChanged: notifier.updateGridWidth,
          ),
          _buildSliderRow(
            label: 'グリッド高さ',
            value: gridConfig.cellHeightMm,
            min: 1,
            max: 20,
            enabled: !state.isGridLinked,
            onChanged: notifier.updateGridHeight,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('線種', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              _styleChip(
                label: '実線',
                selected: gridConfig.lineStyle == LineStyle.solid,
                onTap: () => notifier.updateActiveLayerConfig(
                  gridConfig.copyWith(lineStyle: LineStyle.solid),
                ),
              ),
              const SizedBox(width: 8),
              _styleChip(
                label: '破線',
                selected: gridConfig.lineStyle == LineStyle.dashed,
                onTap: () => notifier.updateActiveLayerConfig(
                  gridConfig.copyWith(lineStyle: LineStyle.dashed),
                ),
              ),
              const SizedBox(width: 8),
              _styleChip(
                label: '点線',
                selected: gridConfig.lineStyle == LineStyle.dotted,
                onTap: () => notifier.updateActiveLayerConfig(
                  gridConfig.copyWith(lineStyle: LineStyle.dotted),
                ),
              ),
              const Spacer(),
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
            child: FilledButton(onPressed: () {}, child: const Text('PDF 出力')),
          ),
        ],
      ),
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
