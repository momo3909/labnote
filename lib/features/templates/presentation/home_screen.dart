import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../features/paywall/domain/free_limits.dart';
import '../../../features/paywall/presentation/paywall_modal.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';
import '../../../shared/widgets/layer_stack_preview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // heightRatio の目安（A4, 上下マージン各10mm → 有効高さ約277mm）:
  //   ヘッダー2フィールド1行 ≈ 9mm/277mm ≈ 0.05
  //   ヘッダー4フィールド2行 ≈ 20mm/277mm ≈ 0.10
  static final _presets = <({String label, IconData icon, String layerType, List<LayerPreset> configs})>[
    // 基本（フルページ）
    (label: '方眼',     icon: Icons.grid_on,              layerType: 'grid',
     configs: <LayerPreset>[(config: const LayerConfig.grid(), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    (label: 'ドット',   icon: Icons.grain,                layerType: 'dot',
     configs: <LayerPreset>[(config: const LayerConfig.dot(), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    (label: 'コーネル', icon: Icons.view_agenda_outlined,  layerType: 'cornell',
     configs: <LayerPreset>[(config: const LayerConfig.cornell(), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    (label: '片対数',   icon: Icons.show_chart,            layerType: 'log_semi',
     configs: <LayerPreset>[(config: const LayerConfig.logGrid(xScale: LogScale.linear, yScale: LogScale.log, yDecades: 3), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    (label: '両対数',   icon: Icons.multiline_chart,       layerType: 'log_log',
     configs: <LayerPreset>[(config: const LayerConfig.logGrid(xScale: LogScale.log, yScale: LogScale.log, xDecades: 2, yDecades: 3), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    (label: '六角形',   icon: Icons.hexagon_outlined,      layerType: 'hex',
     configs: <LayerPreset>[(config: const LayerConfig.hex(), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    (label: '製図',     icon: Icons.architecture,          layerType: 'isometric',
     configs: <LayerPreset>[(config: const LayerConfig.isometric(), yRatio: 0.0, heightRatio: 1.0, colorHex: null)]),
    // 理系特化（v7）— ヘッダーを上部に、コンテンツを下部に配置
    (label: '実験ノート', icon: Icons.science_outlined, layerType: 'header', configs: <LayerPreset>[
      (config: const LayerConfig.header(titleLabel: '目的', dateLabel: '方法', nameLabel: '結果', showSubject: true, subjectLabel: '考察', rowHeightMm: 10.0),
       yRatio: 0.0, heightRatio: 0.10, colorHex: null),
      (config: const LayerConfig.grid(cellWidthMm: 5.0, cellHeightMm: 5.0, boldEvery: 5),
       yRatio: 0.10, heightRatio: 0.90, colorHex: null),
    ]),
    (label: '講義ノート', icon: Icons.menu_book_outlined, layerType: 'cornell', configs: <LayerPreset>[
      (config: const LayerConfig.header(showName: false, titleLabel: '科目', showDate: true, dateLabel: '日付', rowHeightMm: 9.0),
       yRatio: 0.0, heightRatio: 0.05, colorHex: null),
      (config: const LayerConfig.cornell(), yRatio: 0.05, heightRatio: 0.95, colorHex: null),
    ]),
    (label: '演習シート', icon: Icons.edit_note, layerType: 'grid', configs: <LayerPreset>[
      (config: const LayerConfig.header(titleLabel: '科目', dateLabel: '日付', showName: true, rowHeightMm: 9.0),
       yRatio: 0.0, heightRatio: 0.08, colorHex: null),
      (config: const LayerConfig.grid(cellWidthMm: 5.0, cellHeightMm: 8.0),
       yRatio: 0.08, heightRatio: 0.92, colorHex: null),
    ]),
    // グラフ用紙: ドット（背面）+ 黒い座標軸（最前面、負方向あり）
    (label: 'グラフ用紙', icon: Icons.scatter_plot_outlined, layerType: 'graphAxis', configs: <LayerPreset>[
      (config: const LayerConfig.dot(spacingMm: 5.0, alignToOrigin: true), yRatio: 0.0, heightRatio: 1.0, colorHex: null),
      (config: const LayerConfig.graphAxis(showNegative: true, tickIntervalMm: 5.0), yRatio: 0.0, heightRatio: 1.0, colorHex: '#000000'),
    ]),
    (label: '数式罫線', icon: Icons.horizontal_rule, layerType: 'customLine', configs: <LayerPreset>[
      (config: LayerConfig.customLine(lineSets: [
        LineSet(isHorizontal: true, count: 50, spacingMm: 12.0, subLines: [
          SubLineConfig(positionRatio: 0.33),
          SubLineConfig(positionRatio: 0.67),
        ]),
      ]), yRatio: 0.0, heightRatio: 1.0, colorHex: null),
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('LabNote')),
      body: ListView(
        children: [
          _buildPresetsSection(context, ref),
          _buildSavedSection(context, templatesAsync),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/editor'),
        icon: const Icon(Icons.add),
        label: const Text('新規作成'),
      ),
    );
  }

  Widget _buildPresetsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'テンプレート',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _presets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final p = _presets[i];
              final isPro = ref.watch(entitlementNotifierProvider).valueOrNull ?? false;
              final needsPro = proLayerTypes.contains(p.layerType);
              return _PresetCard(
                label: p.label,
                icon: p.icon,
                locked: needsPro && !isPro,
                onTap: () async {
                  if (needsPro && !isPro) {
                    await showPaywallModal(context);
                    return;
                  }
                  if (context.mounted) {
                    context.push('/editor', extra: p.configs);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedSection(
    BuildContext context,
    AsyncValue<List<NotebookTemplate>> templatesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            '保存済み',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ),
        templatesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('読み込みエラー: $e', style: const TextStyle(color: Colors.red)),
          ),
          data: (templates) {
            if (templates.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('保存済みテンプレートはありません', style: TextStyle(color: Colors.black38)),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: templates.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
              itemBuilder: (context, i) {
                final t = templates[i];
                return ListTile(
                  leading: _TemplateThumbnail(template: t),
                  title: Text(t.name),
                  subtitle: Text(
                    _formatDate(t.updatedAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                  onTap: () => context.push('/editor/${t.uuid}'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

class _TemplateThumbnail extends StatelessWidget {
  const _TemplateThumbnail({required this.template});
  final NotebookTemplate template;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 32,
        height: 44,
        child: template.thumbnailPng != null
            ? Image.memory(template.thumbnailPng!, fit: BoxFit.cover)
            : LayerStackPreview(
                pageConfig: template.pageConfig,
                layers: template.layers,
                padding: EdgeInsets.zero,
              ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.label,
    required this.icon,
    required this.onTap,
    this.locked = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 28,
                      color: locked
                          ? Colors.black26
                          : const Color(0xFF1A1A2E)),
                  const SizedBox(height: 6),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: locked ? Colors.black38 : Colors.black87)),
                ],
              ),
            ),
            if (locked)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.lock, size: 12, color: Colors.black38),
              ),
          ],
        ),
      ),
    );
  }
}
