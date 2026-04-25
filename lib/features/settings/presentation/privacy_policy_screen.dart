import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プライバシーポリシー')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: _PolicyContent(),
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _para(
          'LabNote（以下「本アプリ」）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めます。本ポリシーは、本アプリが収集する情報とその利用方法について説明します。',
        ),
        _section('1. 収集する情報'),
        _para('本アプリは以下の情報を収集する場合があります。'),
        _bullet('アカウント情報: Googleアカウントでログインした場合、氏名・メールアドレス・プロフィール画像URL'),
        _bullet('ユーザー作成コンテンツ: テンプレートデータ（レイヤー構成・設定値）、プロフィール情報（表示名・自己紹介・アイコン画像）'),
        _bullet('利用データ: ギャラリーへの投稿・いいね・ダウンロード数'),
        _section('2. 情報の利用目的'),
        _bullet('アプリ機能の提供（テンプレート保存・ギャラリー共有）'),
        _bullet('ユーザー認証・アカウント管理'),
        _bullet('アプリの改善・不具合対応'),
        _section('3. 第三者への提供'),
        _para('収集した情報は、以下の場合を除き第三者に提供しません。'),
        _bullet('法令に基づく開示が必要な場合'),
        _bullet('ユーザー本人の同意がある場合'),
        _section('4. 利用する外部サービス'),
        _para('本アプリは以下の外部サービスを利用しており、各サービスのプライバシーポリシーが適用されます。'),
        _bullet('Firebase / Google Cloud（認証・データ保存）: https://policies.google.com/privacy'),
        _bullet('Google Sign-In: https://policies.google.com/privacy'),
        _section('5. データの保存と管理'),
        _para('収集したデータはGoogle Cloud（Firebase）のサーバーに保存されます。アカウントを削除した場合、関連するデータの削除をお申し付けください。'),
        _section('6. お問い合わせ'),
        _para('本ポリシーに関するお問い合わせは、App Store のサポートページよりご連絡ください。'),
        _section('7. 改定'),
        _para('本ポリシーは必要に応じて改定することがあります。重要な変更がある場合はアプリ内でお知らせします。'),
        const SizedBox(height: 16),
        Text(
          '最終更新: 2026年4月',
          style: TextStyle(fontSize: 12, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      );

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6)),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.6)),
            ),
          ],
        ),
      );
}
