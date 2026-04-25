import 'package:flutter/material.dart';
import '../../../../../shared/models/layer_config.dart';
import '../../../domain/editor_notifier.dart';
import 'cornell_controls.dart';
import 'dot_controls.dart';
import 'grid_controls.dart';
import 'guide_controls.dart';
import 'hex_controls.dart';
import 'isometric_controls.dart';
import 'log_grid_controls.dart';
import 'manuscript_controls.dart';
import 'polar_controls.dart';
import 'region_controls.dart';
import 'timetable_controls.dart';

class LayerControls extends StatelessWidget {
  const LayerControls({
    super.key,
    required this.config,
    required this.notifier,
    required this.isGridLinked,
  });

  final LayerConfig? config;
  final EditorNotifier notifier;
  final bool isGridLinked;

  @override
  Widget build(BuildContext context) {
    return switch (config) {
      GridLayerConfig c => GridControls(
          config: c,
          notifier: notifier,
          isGridLinked: isGridLinked,
        ),
      HexLayerConfig c => HexControls(config: c, notifier: notifier),
      IsometricLayerConfig c => IsometricControls(config: c, notifier: notifier),
      DotLayerConfig c => DotControls(config: c, notifier: notifier),
      LogGridLayerConfig c => LogGridControls(config: c, notifier: notifier),
      CornellLayerConfig c => CornellControls(config: c, notifier: notifier),
      PolarLayerConfig c => PolarControls(config: c, notifier: notifier),
      ManuscriptLayerConfig c => ManuscriptControls(config: c, notifier: notifier),
      TimetableLayerConfig c => TimetableControls(config: c, notifier: notifier),
      RegionLayerConfig c => RegionControls(config: c, notifier: notifier),
      GuideLayerConfig c => GuideControls(config: c, notifier: notifier),
      _ => const SizedBox.shrink(),
    };
  }
}
