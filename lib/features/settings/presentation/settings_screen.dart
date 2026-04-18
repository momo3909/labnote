import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../features/paywall/presentation/paywall_modal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProAsync = ref.watch(entitlementNotifierProvider);
    final isPro = isProAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _sectionHeader('プラン'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isPro ? Icons.workspace_premium : Icons.lock_outline,
                    color: isPro ? Colors.amber.shade700 : Colors.black54,
                  ),
                  title: Text(isPro ? 'Pro プラン' : '無料プラン'),
                  subtitle: Text(
                    isPro
                        ? '全機能をご利用いただけます'
                        : '保存3件・1ページ出力・グリッド5mm以上',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isPro
                      ? null
                      : FilledButton(
                          onPressed: () => showPaywallModal(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('アップグレード',
                              style: TextStyle(fontSize: 12)),
                        ),
                ),
                if (!isPro) ...[
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.black54),
                    title: const Text('購入を復元'),
                    onTap: () async {
                      final restored = await ref
                          .read(entitlementNotifierProvider.notifier)
                          .restore();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              restored ? '購入を復元しました' : '復元できる購入が見つかりません',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('アプリ情報'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.black54),
                  title: Text('バージョン'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.black54)),
                ),
                const Divider(height: 1, indent: 16),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: Colors.black54),
                  title: const Text('プライバシーポリシー'),
                  trailing: const Icon(Icons.open_in_new,
                      size: 16, color: Colors.black38),
                  onTap: () {
                    // TODO: プライバシーポリシーURLを開く
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }
}
