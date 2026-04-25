import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../dev/seed_data.dart';
import '../../../features/auth/data/firebase_auth_repository.dart';
import '../../../features/paywall/domain/entitlement_notifier.dart';
import '../../../features/paywall/presentation/paywall_modal.dart';
import '../../../features/profile/domain/profile_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProAsync = ref.watch(entitlementNotifierProvider);
    final isPro = isProAsync.valueOrNull ?? false;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isAnonymous = firebaseUser == null || firebaseUser.isAnonymous;
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // アカウントセクション
          _sectionHeader('アカウント'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (isAnonymous) ...[
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Colors.black54),
                    title: const Text('ゲストユーザー'),
                    subtitle: const Text('ログインしてプロフィールを作成できます', style: TextStyle(fontSize: 12)),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.indigo),
                    title: const Text('ログイン / アカウント作成'),
                    onTap: () => context.push('/login'),
                  ),
                ] else ...[
                  Builder(builder: (context) {
                    // isAnonymous が false の時点で currentUser は非 null
                    final user = FirebaseAuth.instance.currentUser;
                    return profileAsync.when(
                      loading: () => const ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('読み込み中...'),
                      ),
                      error: (error, _) => ListTile(
                        leading: const Icon(Icons.person, color: Colors.black54),
                        title: Text(user?.displayName ?? 'ユーザー'),
                      ),
                      data: (profile) => ListTile(
                        leading: _AvatarWidget(
                          avatarBytes: profile?.avatarBytes,
                          avatarUrl: profile?.avatarUrl ?? user?.photoURL,
                          radius: 20,
                        ),
                        title: Text(
                          profile?.displayName.isNotEmpty == true
                              ? profile!.displayName
                              : (user?.displayName ?? 'ユーザー'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          user?.email ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Colors.black54),
                    title: const Text('マイプロフィールを編集'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                    onTap: () => context.push('/profile'),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.leaderboard_outlined, color: Colors.black54),
                    title: const Text('ランキング'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                    onTap: () => context.push('/ranking'),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                  onTap: () => context.push('/privacy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 開発用セクション
          _sectionHeader('開発者メニュー'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.science_outlined, color: Colors.indigo),
                  title: const Text('テストデータを作成'),
                  subtitle: const Text('テンプレート10件をギャラリーに追加'),
                  onTap: () => _seedData(context),
                ),
                const Divider(height: 1, indent: 16),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  title: const Text('テストデータを削除',
                      style: TextStyle(color: Colors.red)),
                  subtitle: const Text('_isSeed=trueのデータをすべて削除'),
                  onTap: () => _cleanData(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _seedData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('テストデータを作成'),
        content: const Text('ギャラリーにテスト用テンプレート10件を追加しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('作成')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await SeedData.run();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テストデータを作成しました')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }

  Future<void> _cleanData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('テストデータを削除'),
        content: const Text('_isSeed=trueのデータをすべて削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await SeedData.clean();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テストデータを削除しました')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await FirebaseAuthRepository().signOut();
    if (context.mounted) context.go('/profile');
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

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.avatarBytes,
    required this.avatarUrl,
    required this.radius,
  });
  final dynamic avatarBytes;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (avatarBytes != null) {
      return CircleAvatar(radius: radius, backgroundImage: MemoryImage(avatarBytes));
    }
    if (avatarUrl != null) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(avatarUrl!));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.indigo.shade100,
      child: Icon(Icons.person, size: radius, color: Colors.indigo),
    );
  }
}
