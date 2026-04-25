import 'package:flutter/material.dart';
import '../../../../shared/widgets/layer_stack_preview.dart';
import '../../domain/editor_notifier.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.state, required this.previewKey});

  final EditorState state;
  final GlobalKey previewKey;

  @override
  Widget build(BuildContext context) {
    return LayerStackPreview(
      pageConfig: state.pageConfig,
      layers: state.layers,
      previewKey: previewKey,
    );
  }
}
