import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/editor/domain/editor_notifier.dart';
import '../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../features/paywall/domain/free_limits.dart';
import '../../../features/paywall/presentation/paywall_modal.dart';
import '../../../shared/models/layer_config.dart';
import '../../../shared/models/notebook_template.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _presets = [
    (label: '方眼', icon: Icons.grid_on, layerType: 'grid'),
    (label: 'ドット', icon: Icons.grain, layerType: 'dot'),
    (label: '六角形', icon: Icons.hexagon_outlined, layerType: 'hex'),
    (label: '製図', icon: Icons.architecture, layerType: 'isometric'),
    (label: '計算用紙', icon: Icons.calculate_outlined, layerType: 'grid_calc'),
    (label: '実験ノート', icon: Icons.science_outlined, layerType: 'grid_exp'),
  ];

  static LayerConfig _presetConfig(String layerType) => switch (layerType) {
    'dot' => const LayerConfig.dot(),
    'hex' => const LayerConfig.hex(),
    'isometric' => const LayerConfig.isometric(),
    'grid_calc' => const LayerConfig.grid(cellWidthMm: 5.0, cellHeightMm: 10.0),
    'grid_exp' => const LayerConfig.grid(cellWidthMm: 5.0, cellHeightMm: 5.0, boldEvery: 5),
    _ => const LayerConfig.grid(),
  };

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
                    context.push('/editor', extra: _presetConfig(p.layerType));
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
                  leading: Icon(_templateIcon(t.layersJson), color: const Color(0xFF1A1A2E)),
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

  IconData _templateIcon(List<String> layersJson) {
    if (layersJson.isEmpty) return Icons.grid_on_outlined;
    final first = layersJson.first.toLowerCase();
    if (first.contains('"hex"') || first.contains("'hex'")) return Icons.hexagon_outlined;
    if (first.contains('"isometric"') || first.contains("'isometric'")) return Icons.architecture;
    return Icons.grid_on_outlined;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
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
