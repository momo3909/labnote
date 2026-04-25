import 'package:flutter/material.dart';
import '../../../../shared/models/page_config.dart';
import '../../domain/editor_notifier.dart';
import 'editor_widgets.dart';

class PageSettingsPanel extends StatefulWidget {
  const PageSettingsPanel({super.key, required this.pageConfig, required this.notifier});

  final PageConfig pageConfig;
  final EditorNotifier notifier;

  @override
  State<PageSettingsPanel> createState() => _PageSettingsPanelState();
}

class _PageSettingsPanelState extends State<PageSettingsPanel> {
  bool _marginExpanded = false;
  bool _marginsLinked = false;

  PageConfig get pc => widget.pageConfig;
  EditorNotifier get notifier => widget.notifier;

  void _updateMargin({double? top, double? bottom, double? left, double? right}) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              child: buildStyleChip(
                label: e.key,
                selected: pc.paperSize == e.value,
                onTap: () => notifier.updatePageConfig(pc.copyWith(paperSize: e.value)),
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),

        // Orientation
        Row(
          children: [
            const Text('向き', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: '縦',
              selected: pc.orientation == PaperOrientation.portrait,
              onTap: () => notifier.updatePageConfig(pc.copyWith(orientation: PaperOrientation.portrait)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '横',
              selected: pc.orientation == PaperOrientation.landscape,
              onTap: () => notifier.updatePageConfig(pc.copyWith(orientation: PaperOrientation.landscape)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Hole punch
        Row(
          children: [
            const Text('穴', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: 'なし',
              selected: pc.holeConfig == HoleConfig.none,
              onTap: () => notifier.updatePageConfig(pc.copyWith(holeConfig: HoleConfig.none)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '26穴',
              selected: pc.holeConfig == HoleConfig.h26,
              onTap: () => notifier.updatePageConfig(pc.copyWith(holeConfig: HoleConfig.h26)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '30穴',
              selected: pc.holeConfig == HoleConfig.h30,
              onTap: () => notifier.updatePageConfig(pc.copyWith(holeConfig: HoleConfig.h30)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Page elements
        Row(
          children: [
            const Text('挿入', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildToggleChip(
              label: 'ページ番号',
              enabled: pc.showPageNumber,
              onTap: () => notifier.updatePageConfig(pc.copyWith(showPageNumber: !pc.showPageNumber)),
            ),
            const SizedBox(width: 8),
            buildToggleChip(
              label: '行番号',
              enabled: pc.showLineNumbers,
              onTap: () => notifier.updatePageConfig(pc.copyWith(showLineNumbers: !pc.showLineNumbers)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Margin section (collapsible)
        InkWell(
          onTap: () => setState(() => _marginExpanded = !_marginExpanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Text('余白', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _marginsLinked = !_marginsLinked),
                  child: Tooltip(
                    message: _marginsLinked ? '連動解除' : '上下左右を連動',
                    child: Icon(
                      _marginsLinked ? Icons.link : Icons.link_off,
                      size: 16,
                      color: _marginsLinked ? const Color(0xFF1A1A2E) : Colors.black38,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _marginExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _marginExpanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      // Margin presets
                      Row(
                        children: [
                          buildStyleChip(
                            label: 'なし',
                            selected: pc.marginLeftMm == 0 && pc.marginTopMm == 0,
                            onTap: () => notifier.updatePageConfig(pc.copyWith(
                              marginTopMm: 0, marginBottomMm: 0,
                              marginLeftMm: 0, marginRightMm: 0,
                            )),
                          ),
                          const SizedBox(width: 6),
                          buildStyleChip(
                            label: '標準',
                            selected: pc.marginTopMm == 10 && pc.marginBottomMm == 10 &&
                                pc.marginLeftMm == 10 && pc.marginRightMm == 10,
                            onTap: () => notifier.updatePageConfig(pc.copyWith(
                              marginTopMm: 10, marginBottomMm: 10,
                              marginLeftMm: 10, marginRightMm: 10,
                            )),
                          ),
                          const SizedBox(width: 6),
                          buildStyleChip(
                            label: '26穴',
                            selected: pc.marginLeftMm == 20 && pc.marginTopMm == 10,
                            onTap: () => notifier.updatePageConfig(pc.copyWith(
                              marginTopMm: 10, marginBottomMm: 10,
                              marginLeftMm: 20, marginRightMm: 10,
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      buildSliderRow(
                        label: '上',
                        value: pc.marginTopMm,
                        min: 0,
                        max: 30,
                        onChanged: (v) => _updateMargin(top: v),
                      ),
                      buildSliderRow(
                        label: '下',
                        value: pc.marginBottomMm,
                        min: 0,
                        max: 30,
                        onChanged: (v) => _updateMargin(bottom: v),
                      ),
                      buildSliderRow(
                        label: '左',
                        value: pc.marginLeftMm,
                        min: 0,
                        max: 30,
                        onChanged: (v) => _updateMargin(left: v),
                      ),
                      buildSliderRow(
                        label: '右',
                        value: pc.marginRightMm,
                        min: 0,
                        max: 30,
                        onChanged: (v) => _updateMargin(right: v),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
