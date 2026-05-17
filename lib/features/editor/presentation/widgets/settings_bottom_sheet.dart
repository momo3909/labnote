import 'package:flutter/material.dart';
import '../../domain/editor_notifier.dart';
import 'layer_list_panel.dart';
import 'page_settings_panel.dart';
import 'layer_controls/layer_controls.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({
    super.key,
    required this.state,
    required this.notifier,
    required this.isExporting,
    required this.onExport,
    required this.maxSheetContentH,
  });

  final EditorState state;
  final EditorNotifier notifier;
  final bool isExporting;
  final VoidCallback onExport;
  final double maxSheetContentH;

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expand/collapse header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
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
                    _expanded ? Icons.expand_less : Icons.expand_more,
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
              child: _expanded
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: widget.maxSheetContentH),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            LayerListPanel(state: state, notifier: notifier),
                            const SizedBox(height: 8),
                            LayerControls(
                              config: state.activeLayer?.config,
                              notifier: notifier,
                              isGridLinked: state.isGridLinked,
                            ),
                            const SizedBox(height: 8),
                            PageSettingsPanel(
                              pageConfig: state.pageConfig,
                              notifier: notifier,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // PDF export button — always visible
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.isExporting ? null : widget.onExport,
                child: widget.isExporting
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
}
