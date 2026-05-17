import 'package:flutter/material.dart';
import '../../../../shared/models/layer_config.dart';
import '../../../../shared/models/notebook_template.dart';
import '../../../../shared/painters/painter_utils.dart';
import '../../domain/editor_notifier.dart';
import 'editor_widgets.dart';

const _lineColorSwatches = [
  ('#CCCCCC', '灰'),
  ('#1565C0', '青'),
  ('#B71C1C', '赤'),
  ('#1B5E20', '緑'),
  ('#4A148C', '紫'),
  ('#E65100', '橙'),
  ('#37474F', '墨'),
];

const _bgColorSwatches = [
  ('', '透明'),
  ('#FFFDE7', '薄黄'),
  ('#E3F2FD', '薄青'),
  ('#E8F5E9', '薄緑'),
  ('#FCE4EC', '薄ピンク'),
  ('#F3E5F5', '薄紫'),
  ('#FFFFFF', '白'),
];

const _addableLayerTypes = [
  (label: '方眼', config: LayerConfig.grid()),
  (label: 'ドット', config: LayerConfig.dot()),
  (label: '片対数', config: LayerConfig.logGrid(xScale: LogScale.linear, yScale: LogScale.log)),
  (label: '両対数', config: LayerConfig.logGrid(xScale: LogScale.log, yScale: LogScale.log)),
  (label: '六角形', config: LayerConfig.hex()),
  (label: '製図', config: LayerConfig.isometric()),
  (label: 'コーネル', config: LayerConfig.cornell()),
  (label: '極座標', config: LayerConfig.polar()),
  (label: '原稿用紙', config: LayerConfig.manuscript()),
  (label: '時間割', config: LayerConfig.timetable()),
  (label: '領域分割', config: LayerConfig.region()),
  (label: 'ガイド', config: LayerConfig.guide(guideType: GuideType.axis)),
  (label: '五線譜', config: LayerConfig.staff()),
  (label: '方眼＋罫線', config: LayerConfig.ruledGrid()),
  (label: 'スタンプ', config: LayerConfig.stamp()),
  (label: 'カスタム線', config: LayerConfig.customLine()),
  (label: '表', config: LayerConfig.table()),
  (label: '座標軸', config: LayerConfig.graphAxis()),
  (label: 'ヘッダー', config: LayerConfig.header()),
];

String _layerLabel(LayerEntity layer) => switch (layer.layerType) {
      'grid' => '方眼',
      'dot' => 'ドット',
      'hex' => '六角形',
      'isometric' => '製図',
      'log_grid' => '対数グリッド',
      'cornell' => 'コーネル',
      'polar' => '極座標',
      'manuscript' => '原稿用紙',
      'timetable' => '時間割',
      'region' => '領域分割',
      'guide' => 'ガイド',
      'staff' => '五線譜',
      'ruledGrid' => '方眼＋罫線',
      'stamp' => 'スタンプ',
      'customLine' => 'カスタム線',
      'table' => '表',
      'graphAxis' => '座標軸',
      'header' => 'ヘッダー',
      _ => layer.layerType,
    };

class LayerListPanel extends StatelessWidget {
  const LayerListPanel({super.key, required this.state, required this.notifier});

  final EditorState state;
  final EditorNotifier notifier;

  void _showAddLayerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'レイヤーを追加',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).padding.bottom + 8,
              ),
              children: _addableLayerTypes
                  .map((t) => ListTile(
                        title: Text(t.label),
                        onTap: () {
                          notifier.addLayer(t.config);
                          Navigator.pop(ctx);
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('レイヤー', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddLayerSheet(context),
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
                if (state.layers.length > 1)
                  _LayerZOrderBar(index: i, total: state.layers.length, notifier: notifier),
                _LayerColorPanel(index: i, layer: layer, notifier: notifier),
                _LayerPositionPanel(index: i, layer: layer, notifier: notifier),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _LayerZOrderBar extends StatelessWidget {
  const _LayerZOrderBar({
    required this.index,
    required this.total,
    required this.notifier,
  });

  final int index;
  final int total;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isBack  = index == 0;
    final isFront = index == total - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
      child: Row(
        children: [
          const Text('順序:', style: TextStyle(fontSize: 11, color: Colors.black45)),
          const SizedBox(width: 6),
          _btn(Icons.vertical_align_bottom, '最背面', isBack  ? null : () => notifier.moveLayerToBack(index)),
          _btn(Icons.keyboard_arrow_down,   '背面へ', isBack  ? null : () => notifier.moveLayerDown(index)),
          _btn(Icons.keyboard_arrow_up,     '前面へ', isFront ? null : () => notifier.moveLayerUp(index)),
          _btn(Icons.vertical_align_top,    '最前面', isFront ? null : () => notifier.moveLayerToFront(index)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String tooltip, VoidCallback? onTap) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              icon,
              size: 18,
              color: onTap != null ? const Color(0xFF1A1A2E) : Colors.black12,
            ),
          ),
        ),
      );
}

class _LayerPositionPanel extends StatefulWidget {
  const _LayerPositionPanel({
    required this.index,
    required this.layer,
    required this.notifier,
  });

  final int index;
  final LayerEntity layer;
  final EditorNotifier notifier;

  @override
  State<_LayerPositionPanel> createState() => _LayerPositionPanelState();
}

class _LayerPositionPanelState extends State<_LayerPositionPanel> {
  bool _expanded = false;

  static const _presets = [
    (label: '全体',   xR: 0.0, yR: 0.0, wR: 1.0, hR: 1.0),
    (label: '上半分', xR: 0.0, yR: 0.0, wR: 1.0, hR: 0.5),
    (label: '下半分', xR: 0.0, yR: 0.5, wR: 1.0, hR: 0.5),
    (label: '左半分', xR: 0.0, yR: 0.0, wR: 0.5, hR: 1.0),
    (label: '右半分', xR: 0.5, yR: 0.0, wR: 0.5, hR: 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final notifier = widget.notifier;
    final index = widget.index;
    final xMax = (1.0 - layer.widthRatio).clamp(0.0, 1.0);
    final yMax = (1.0 - layer.heightRatio).clamp(0.0, 1.0);

    final currentPresetLabel = _presets
        .where((p) =>
            layer.xRatio == p.xR &&
            layer.yRatio == p.yR &&
            layer.widthRatio == p.wR &&
            layer.heightRatio == p.hR)
        .map((p) => p.label)
        .firstOrNull ?? 'カスタム';

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Text('配置', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(width: 8),
                  Text(
                    currentPresetLabel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF1A1A2E)),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: _presets.map((p) {
                              final selected = layer.xRatio == p.xR &&
                                  layer.yRatio == p.yR &&
                                  layer.widthRatio == p.wR &&
                                  layer.heightRatio == p.hR;
                              return buildStyleChip(
                                label: p.label,
                                selected: selected,
                                onTap: () => notifier.updateLayerRegion(
                                  index,
                                  xRatio: p.xR,
                                  yRatio: p.yR,
                                  widthRatio: p.wR,
                                  heightRatio: p.hR,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 4),
                          buildRatioSlider(
                            label: 'X',
                            value: layer.xRatio,
                            max: xMax,
                            onChanged: (v) => notifier.updateLayerRegion(index, xRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                          buildRatioSlider(
                            label: 'Y',
                            value: layer.yRatio,
                            max: yMax,
                            onChanged: (v) => notifier.updateLayerRegion(index, yRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                          buildRatioSlider(
                            label: '幅',
                            value: layer.widthRatio,
                            onChanged: (v) => notifier.updateLayerRegion(index, widthRatio: v),
                            onChangeEnd: (_) => notifier.commitLayerRegion(index),
                          ),
                          buildRatioSlider(
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
}

class _LayerColorPanel extends StatelessWidget {
  const _LayerColorPanel({
    required this.index,
    required this.layer,
    required this.notifier,
  });

  final int index;
  final LayerEntity layer;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 40,
                child: Text('線色', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ),
              ..._lineColorSwatches.map((s) {
                final (hex, _) = s;
                final selected = layer.colorHex.toUpperCase() == hex.toUpperCase();
                return GestureDetector(
                  onTap: () => notifier.updateLayerColor(index, hex),
                  child: Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(right: 4),
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
              const Spacer(),
              SizedBox(
                width: 72,
                child: Slider(
                  value: layer.opacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: (v) => notifier.updateLayerOpacity(index, v),
                  onChangeEnd: (v) => notifier.commitLayerOpacity(index, v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const SizedBox(
                width: 40,
                child: Text('背景', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ),
              ..._bgColorSwatches.map((s) {
                final (hex, _) = s;
                final selected = layer.bgColorHex == hex;
                return GestureDetector(
                  onTap: () => notifier.updateLayerBgColor(index, hex),
                  child: Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: hex.isEmpty ? Colors.transparent : colorFromHex(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.black87 : Colors.black26,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: hex.isEmpty
                        ? const Center(
                            child: Text('×',
                                style: TextStyle(fontSize: 9, color: Colors.black38)),
                          )
                        : null,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
