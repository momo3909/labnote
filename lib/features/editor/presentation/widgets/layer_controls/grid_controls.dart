import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../../../features/paywall/domain/free_limits.dart';
import '../../../../../features/paywall/presentation/paywall_modal.dart';
import '../../../domain/editor_notifier.dart';
import '../editor_widgets.dart';

class GridControls extends ConsumerWidget {
  const GridControls({
    super.key,
    required this.config,
    required this.notifier,
    required this.isGridLinked,
  });

  final GridLayerConfig config;
  final EditorNotifier notifier;
  final bool isGridLinked;

  Future<void> _onSizeChange(
    BuildContext context,
    WidgetRef ref,
    double value,
    void Function(double) update,
  ) async {
    final isPro = await ref.read(entitlementNotifierProvider.future);
    if (!isPro && value < freeMinGridSizeMm) {
      final upgraded = await showPaywallModal(context);
      if (!upgraded) return;
    }
    update(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                value: isGridLinked,
                onChanged: (_) => notifier.toggleGridLink(),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        buildSliderRow(
          label: 'グリッド幅',
          value: config.cellWidthMm,
          min: 1,
          max: 20,
          onChanged: (v) => _onSizeChange(context, ref, v, notifier.updateGridWidth),
        ),
        buildSliderRow(
          label: 'グリッド高さ',
          value: config.cellHeightMm,
          min: 1,
          max: 20,
          enabled: !isGridLinked,
          onChanged: (v) => _onSizeChange(context, ref, v, notifier.updateGridHeight),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('線種', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: '実線',
              selected: config.lineStyle == LineStyle.solid,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(lineStyle: LineStyle.solid)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '破線',
              selected: config.lineStyle == LineStyle.dashed,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(lineStyle: LineStyle.dashed)),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
              label: '点線',
              selected: config.lineStyle == LineStyle.dotted,
              onTap: () => notifier.updateActiveLayerConfig(config.copyWith(lineStyle: LineStyle.dotted)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('表示', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 16),
            buildStyleChip(
              label: '横線',
              selected: config.showHorizontal,
              onTap: () => notifier.updateActiveLayerConfig(
                config.copyWith(showHorizontal: !config.showHorizontal),
              ),
            ),
            const SizedBox(width: 8),
            buildStyleChip(
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
}
