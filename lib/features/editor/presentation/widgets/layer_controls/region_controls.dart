import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class RegionControls extends StatelessWidget {
  const RegionControls({super.key, required this.config, required this.notifier});

  final RegionLayerConfig config;
  final EditorNotifier notifier;

  static final _presets = [
    (
      label: '上方眼+下コーネル',
      regions: [
        PageRegion(xRatio: 0, yRatio: 0, widthRatio: 1, heightRatio: 0.5, layerConfig: const LayerConfig.grid()),
        PageRegion(xRatio: 0, yRatio: 0.5, widthRatio: 1, heightRatio: 0.5, layerConfig: const LayerConfig.cornell()),
      ],
    ),
    (
      label: '左製図+右方眼',
      regions: [
        PageRegion(xRatio: 0, yRatio: 0, widthRatio: 0.5, heightRatio: 1, layerConfig: const LayerConfig.isometric()),
        PageRegion(xRatio: 0.5, yRatio: 0, widthRatio: 0.5, heightRatio: 1, layerConfig: const LayerConfig.grid()),
      ],
    ),
    (
      label: '上グラフ+下方眼',
      regions: [
        PageRegion(xRatio: 0, yRatio: 0, widthRatio: 1, heightRatio: 0.5, layerConfig: const LayerConfig.logGrid()),
        PageRegion(xRatio: 0, yRatio: 0.5, widthRatio: 1, heightRatio: 0.5, layerConfig: const LayerConfig.grid()),
      ],
    ),
    (
      label: '3段横',
      regions: [
        PageRegion(xRatio: 0, yRatio: 0, widthRatio: 1, heightRatio: 1 / 3, layerConfig: const LayerConfig.grid()),
        PageRegion(xRatio: 0, yRatio: 1 / 3, widthRatio: 1, heightRatio: 1 / 3, layerConfig: const LayerConfig.dot()),
        PageRegion(xRatio: 0, yRatio: 2 / 3, widthRatio: 1, heightRatio: 1 / 3, layerConfig: const LayerConfig.cornell()),
      ],
    ),
    (
      label: 'ドット+六角形',
      regions: [
        PageRegion(xRatio: 0, yRatio: 0, widthRatio: 0.5, heightRatio: 1, layerConfig: const LayerConfig.dot()),
        PageRegion(xRatio: 0.5, yRatio: 0, widthRatio: 0.5, heightRatio: 1, layerConfig: const LayerConfig.hex()),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('プリセット', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _presets.map((p) => buildStyleChip(
            label: p.label,
            selected: false,
            onTap: () => notifier.updateActiveLayerConfig(RegionLayerConfig(regions: p.regions)),
          )).toList(),
        ),
        if (config.regions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...config.regions.asMap().entries.map((e) => Text(
            '領域${e.key + 1}: ${_regionLabel(e.value.layerConfig)}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          )),
        ],
      ],
    );
  }

  String _regionLabel(LayerConfig lc) => switch (lc) {
    GridLayerConfig() => '方眼',
    HexLayerConfig() => '六角形',
    IsometricLayerConfig() => '製図',
    DotLayerConfig() => 'ドット',
    LogGridLayerConfig() => '対数グリッド',
    CornellLayerConfig() => 'コーネル',
    GuideLayerConfig() => 'ガイド',
    PolarLayerConfig() => '極座標',
    ManuscriptLayerConfig() => '原稿用紙',
    TimetableLayerConfig() => '時間割',
    RegionLayerConfig() => '領域分割',
    StaffLayerConfig() => '五線譜',
    RuledGridLayerConfig() => '方眼＋罫線',
    StampLayerConfig() => 'スタンプ',
    GraphAxisLayerConfig() => '座標軸',
    TableLayerConfig() => '表',
    CustomLineLayerConfig() => 'カスタム線',

    HeaderLayerConfig() => 'ヘッダー',
  };
}
