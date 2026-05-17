# LabNote テストデータスクリプト

## セットアップ

### 1. サービスアカウントキーを取得

1. [Firebase Console](https://console.firebase.google.com/) → プロジェクト `labnote-40d54`
2. 歯車アイコン → **プロジェクトの設定**
3. **サービスアカウント** タブ → **新しい秘密鍵を生成**
4. ダウンロードした JSON を `scripts/serviceAccountKey.json` として保存

> ⚠️ `serviceAccountKey.json` は `.gitignore` に含まれています。コミットしないこと。

### 2. 依存パッケージをインストール

```bash
cd scripts
npm install
```

## 実行

### テストデータ投入

```bash
npm run seed
```

作成されるデータ:
- テストユーザー **10 人** (Firebase Auth + Firestore `users`)
- ギャラリーテンプレート **50 件** (各ユーザー 5 件、バリエーション 10 種からランダム)
- ランダムフォロー関係 (各ユーザーが 2〜5 人をフォロー)
- ランダムいいね (各テンプレートに 2〜7 件)
- ランダムコメント (各テンプレートに 0〜3 件)

### テストアカウント

| メールアドレス | パスワード | 名前 |
|---|---|---|
| test01@labnote-test.com | TestLabNote2024! | 田中 一郎 |
| test02@labnote-test.com | TestLabNote2024! | 鈴木 花子 |
| test03@labnote-test.com | TestLabNote2024! | 佐藤 健太 |
| test04@labnote-test.com | TestLabNote2024! | 山田 美咲 |
| test05@labnote-test.com | TestLabNote2024! | 伊藤 拓也 |
| test06@labnote-test.com | TestLabNote2024! | 渡辺 さくら |
| test07@labnote-test.com | TestLabNote2024! | 小林 雄介 |
| test08@labnote-test.com | TestLabNote2024! | 加藤 莉奈 |
| test09@labnote-test.com | TestLabNote2024! | 吉田 誠 |
| test10@labnote-test.com | TestLabNote2024! | 山本 あかり |

### テストデータ削除

```bash
npm run cleanup
```

## 再実行について

`seed.mjs` は冪等です。同じメールアドレスのユーザーが既に存在する場合は Auth ユーザーを再利用し、Firestore データだけ上書き（merge）します。ただしテンプレートは重複して追加されます。再投入する場合は先に `cleanup` を実行してください。
