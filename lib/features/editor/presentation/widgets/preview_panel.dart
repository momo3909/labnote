import 'package:flutter/material.dart';
import '../../../../shared/widgets/layer_stack_preview.dart';
import '../../domain/editor_notifier.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({
    super.key,
    required this.state,
    required this.previewKey,
    this.paperKey,
    this.overlayChild,
  });

  final EditorState state;
  final GlobalKey previewKey;
  final GlobalKey? paperKey;
  final Widget? overlayChild;

  @override
  Widget build(BuildContext context) {
    return LayerStackPreview(
      pageConfig: state.pageConfig,
      layers: state.layers,
      previewKey: previewKey,
      paperKey: paperKey,
      overlayChild: overlayChild,
    );
  }
}
