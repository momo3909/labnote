import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/layer_config.dart';
import '../domain/editor_notifier.dart';
import '../../export/presentation/export_service.dart';
import '../../paywall/domain/entitlement_notifier.dart';
import '../../paywall/domain/free_limits.dart';
import '../../paywall/presentation/paywall_modal.dart';
import 'widgets/layer_controls/layer_controls.dart';
import 'widgets/layer_list_panel.dart';
import 'widgets/page_settings_panel.dart';
import 'widgets/preview_panel.dart';
import 'widgets/settings_bottom_sheet.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.templateUuid, this.presetConfig});
  final String? templateUuid;
  final LayerConfig? presetConfig;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  bool _isExporting = false;
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
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || boundary.debugNeedsPaint || boundary.size.isEmpty) return null;
      final image = await boundary.toImage(pixelRatio: 1.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  // ── Export / Save ─────────────────────────────────────────────────────────

  Future<void> _exportPdf(EditorState state, EditorNotifier notifier) async {
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

  Future<void> _showSaveDialog(EditorState state, EditorNotifier notifier) async {
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
                  onPressed: () => _showSaveDialog(state, notifier),
                  child: const Text('保存'),
                ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, bodyConstraints) {
          final previewArea = LayoutBuilder(
            builder: (context, constraints) {
              _previewSize = constraints.biggest;
              return Stack(
                children: [
                  InteractiveViewer(
                    transformationController: _transformController,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.3,
                    maxScale: 6.0,
                    child: PreviewPanel(state: state, previewKey: _previewKey),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildZoomButtons(),
                  ),
                ],
              );
            },
          );

          final isWide = MediaQuery.of(context).size.shortestSide > 600;
          if (isWide) {
            return Row(
              children: [
                Expanded(child: previewArea),
                SizedBox(
                  width: 320,
                  child: _buildSideSettings(state, notifier),
                ),
              ],
            );
          }

          final maxSheetContentH =
              (bodyConstraints.maxHeight * 0.42).clamp(120.0, 320.0);
          return Column(
            children: [
              Expanded(child: previewArea),
              SettingsBottomSheet(
                state: state,
                notifier: notifier,
                isExporting: _isExporting,
                onExport: () => _exportPdf(state, notifier),
                maxSheetContentH: maxSheetContentH,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSideSettings(EditorState state, EditorNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayerListPanel(state: state, notifier: notifier),
                  const SizedBox(height: 8),
                  LayerControls(
                    config: state.activeLayer?.config,
                    notifier: notifier,
                    isGridLinked: state.isGridLinked,
                  ),
                  const SizedBox(height: 8),
                  PageSettingsPanel(pageConfig: state.pageConfig, notifier: notifier),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isExporting ? null : () => _exportPdf(state, notifier),
                child: _isExporting
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('PDF 出力'),
              ),
            ),
          ),
        ],
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
          child: const Text('確定'),
        ),
      ],
    );
  }
}
