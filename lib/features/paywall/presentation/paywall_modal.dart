import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/entitlement_notifier.dart';

const _tosUrl = 'https://momo3909.github.io/labnote/terms.html';
const _privacyUrl = 'https://momo3909.github.io/labnote/privacy.html';

Future<bool> showPaywallModal(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PaywallModal(),
  );
  return result == true;
}

class PaywallModal extends ConsumerWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(rcOfferingsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: const Icon(Icons.close, color: Colors.black38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hexagon_outlined, size: 28, color: Color(0xFF1A1A2E)),
              SizedBox(width: 8),
              Icon(Icons.grid_on, size: 28, color: Color(0xFF1A1A2E)),
              SizedBox(width: 8),
              Icon(Icons.architecture, size: 28, color: Color(0xFF1A1A2E)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Pro プランにアップグレード',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 18, color: Color(0xFF1A1A2E)),
                    const SizedBox(width: 10),
                    Text(f, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          offeringsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => _fallbackButtons(context, ref),
            data: (offerings) => offerings != null
                ? _packageButtons(context, ref, offerings)
                : _fallbackButtons(context, ref),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => _restore(context, ref),
                child: const Text('購入を復元', style: TextStyle(fontSize: 12)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('・', style: TextStyle(color: Colors.black38)),
              ),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(_tosUrl),
                    mode: LaunchMode.externalApplication),
                child: const Text('利用規約', style: TextStyle(fontSize: 12)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('・', style: TextStyle(color: Colors.black38)),
              ),
              TextButton(
                onPressed: () => launchUrl(Uri.parse(_privacyUrl),
                    mode: LaunchMode.externalApplication),
                child: const Text('プライバシーポリシー',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _packageButtons(
    BuildContext context,
    WidgetRef ref,
    Offerings offerings,
  ) {
    final current = offerings.current;
    if (current == null) return _fallbackButtons(context, ref);

    return Column(
      children: [
        _trialButton(context, ref, current),
        const SizedBox(height: 10),
        Row(
          children: [
            if (current.monthly != null)
              Expanded(
                child: _priceButton(
                  context: context,
                  ref: ref,
                  package: current.monthly!,
                  label: '¥200 / 月',
                  sub: '',
                  primary: false,
                ),
              ),
            if (current.monthly != null && current.annual != null)
              const SizedBox(width: 10),
            if (current.annual != null)
              Expanded(
                child: _priceButton(
                  context: context,
                  ref: ref,
                  package: current.annual!,
                  label: '¥1,200 / 年',
                  sub: '2ヶ月分お得',
                  primary: false,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _trialButton(BuildContext context, WidgetRef ref, Offering offering) {
    final pkg = offering.annual ?? offering.monthly;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: pkg != null ? () => _purchase(context, ref, pkg) : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A2E),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('7日間 無料で試す', style: TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _priceButton({
    required BuildContext context,
    required WidgetRef ref,
    required Package package,
    required String label,
    required String sub,
    required bool primary,
  }) {
    return OutlinedButton(
      onPressed: () => _purchase(context, ref, package),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFF1A1A2E)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          if (sub.isNotEmpty)
            Text(sub,
                style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _fallbackButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('7日間 無料で試す（準備中）',
                style: TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'App Storeで課金が設定されると利用可能になります',
          style: TextStyle(fontSize: 11, color: Colors.black38),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _purchase(
      BuildContext context, WidgetRef ref, Package package) async {
    final isPro =
        await ref.read(entitlementNotifierProvider.notifier).purchase(package);
    if (context.mounted) Navigator.pop(context, isPro);
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final isPro =
        await ref.read(entitlementNotifierProvider.notifier).restore();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPro ? '購入を復元しました' : '復元できる購入が見つかりませんでした'),
        ),
      );
      if (isPro) Navigator.pop(context, true);
    }
  }

  static const _features = [
    '全テンプレート（六角形・製図）',
    '複数ページ PDF 出力',
    'グリッド 1mm 単位調整',
    'カスタム保存 無制限',
  ];
}
