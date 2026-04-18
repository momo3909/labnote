import 'package:flutter/material.dart';

class SavedListScreen extends StatelessWidget {
  const SavedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('保存済み')),
      body: const Center(child: Text('保存済みテンプレート（実装中）')),
    );
  }
}
