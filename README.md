# LabNote

理系大学生向けノート設計アプリのFlutterソースコードです。

## 主な機能

- 多種レイヤー対応（方眼・ドット・罫線・コーネル・対数グラフ・極座標・数式罫線・表・座標軸・ヘッダー等）
- PDF出力（複数ページ対応）
- テンプレートギャラリー（Firestore連携・いいね・コメント・フォロー）
- スタンプ機能（化学・物理・数学図形の自由配置）
- サブスクリプション（RevenueCat連携）
- Undo/Redo・サムネイル保存・レイヤードラッグ移動

## 技術スタック

- Flutter 3.x / Dart
- Riverpod (`riverpod_annotation`) + freezed
- Drift（ローカルDB）
- Firebase（Auth / Firestore / Storage）
- RevenueCat（サブスクリプション管理）
- dart-pdf（PDF生成）
- go_router（ルーティング）

---

## セットアップ手順

### 1. 依存パッケージのインストール

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. Firebase の設定

1. [Firebase Console](https://console.firebase.google.com) で新規プロジェクトを作成
2. iOS アプリを追加し `GoogleService-Info.plist` をダウンロード
3. `ios/Runner/GoogleService-Info.plist` に配置
4. `lib/firebase_options.dart` の `YOUR_***` をご自身の値に書き換え

```dart
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',        // Firebase Console → プロジェクト設定
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  iosBundleId: 'YOUR_BUNDLE_ID',     // Runner.xcodeproj のBundle IDと一致させる
);
```

5. `firebase.json` の `YOUR_PROJECT_ID` / `YOUR_IOS_APP_ID` も同様に書き換え
6. Firestore・Storage のセキュリティルールを Firebase Console でデプロイ

```bash
firebase deploy --only firestore:rules,storage
```

### 3. RevenueCat の設定

1. [RevenueCat](https://app.revenuecat.com) でプロジェクトを作成
2. iOS アプリを追加し Public API key を取得
3. `lib/features/paywall/domain/entitlement_notifier.dart` を書き換え

```dart
const _rcApiKeyIos = 'YOUR_REVENUECAT_IOS_API_KEY';
```

4. RevenueCat ダッシュボードでエンタイトルメント ID `pro` を作成し、App Store の商品と紐付け

> サブスクリプション機能が不要な場合は `entitlement_notifier.dart` の `_fetchIsPro()` を常に `true` を返すよう変更してください。

### 4. Bundle ID の変更

`ios/Runner.xcodeproj` を Xcode で開き、Bundle Identifier をご自身のものに変更してください。

### 5. Info.plist の Google ログイン設定

Firebase で Google ログインを有効にすると、`GoogleService-Info.plist` に以下の値が含まれます。  
この値を `ios/Runner/Info.plist` の該当箇所に反映してください。

| Info.plist のキー | GoogleService-Info.plist の対応キー |
|---|---|
| `GIDClientID` | `CLIENT_ID` |
| `CFBundleURLSchemes` 内の値 | `REVERSED_CLIENT_ID` |

**手順:**

1. `GoogleService-Info.plist` を開き `CLIENT_ID` と `REVERSED_CLIENT_ID` の値をコピー
2. `ios/Runner/Info.plist` を開き以下を書き換え

```xml
<!-- GIDClientID -->
<key>GIDClientID</key>
<string>YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com</string>
↓
<string>（CLIENT_ID の値）</string>

<!-- CFBundleURLSchemes -->
<string>com.googleusercontent.apps.YOUR_GOOGLE_CLIENT_ID</string>
↓
<string>（REVERSED_CLIENT_ID の値）</string>
```

---

## 開発時の注意

```bash
# freezed / Riverpod のコード生成（モデル変更後に必須）
dart run build_runner build --delete-conflicting-outputs

# 静的解析
flutter analyze --no-fatal-infos
```

デバッグビルドではサブスクリプションチェックをスキップし、全機能が利用可能です。

---

## ライセンス

購入者による商用利用・改変・再配布を許可します。ただし本ソースコードをそのままの形で再販売することは禁止します。
