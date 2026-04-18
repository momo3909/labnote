import 'package:flutter/material.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key, required this.templateId});
  final String? templateId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(templateId == null ? '新規作成' : 'テンプレート編集')),
      body: const Center(child: Text('エディタ画面（実装中）')),
    );
  }
}
