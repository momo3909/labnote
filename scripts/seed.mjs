/**
 * LabNote テストデータ投入スクリプト
 *
 * 前提:
 *   1. Firebase サービスアカウントキーを scripts/serviceAccountKey.json に配置
 *      (Firebase Console → プロジェクト設定 → サービスアカウント → 秘密鍵を生成)
 *   2. `npm install` を実行済み
 *
 * 実行:
 *   cd scripts && npm run seed
 *
 * 作成されるデータ:
 *   - テストユーザー 10 人 (Firebase Auth + users コレクション)
 *   - ギャラリーテンプレート 50 件 (各ユーザー 5 件)
 *   - ランダムフォロー関係
 *   - ランダムいいね
 */

import { readFileSync } from 'fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { randomUUID } from 'crypto';

// ── 初期化 ───────────────────────────────────────────────────────────────────

const serviceAccount = JSON.parse(
  readFileSync(new URL('./serviceAccountKey.json', import.meta.url), 'utf8')
);

initializeApp({ credential: cert(serviceAccount) });

const auth = getAuth();
const db = getFirestore();

// ── テストユーザー定義 ────────────────────────────────────────────────────────

const TEST_PASSWORD = 'TestLabNote2024!';

const TEST_USERS = [
  { email: 'test01@labnote-test.com', displayName: '田中 一郎', bio: '理系大学1年生。数学と物理が好き。' },
  { email: 'test02@labnote-test.com', displayName: '鈴木 花子', bio: '化学専攻の3年生。実験ノートを丁寧に書くのが趣味。' },
  { email: 'test03@labnote-test.com', displayName: '佐藤 健太', bio: '数学科M2。数式を綺麗に書きたい。' },
  { email: 'test04@labnote-test.com', displayName: '山田 美咲', bio: '生物系の学部生。コーネル式ノートを愛用中。' },
  { email: 'test05@labnote-test.com', displayName: '伊藤 拓也', bio: '電気工学専攻。グラフをよく書く。' },
  { email: 'test06@labnote-test.com', displayName: '渡辺 さくら', bio: '医学部生。解剖図をよく書く。' },
  { email: 'test07@labnote-test.com', displayName: '小林 雄介', bio: '物理専攻D1。論文の計算メモ用に使っています。' },
  { email: 'test08@labnote-test.com', displayName: '加藤 莉奈', bio: '情報科学の学部3年。アルゴリズムの図解に使用。' },
  { email: 'test09@labnote-test.com', displayName: '吉田 誠', bio: '建築学科。製図練習に最適。' },
  { email: 'test10@labnote-test.com', displayName: '山本 あかり', bio: '薬学部4年生。化学構造式をよく書きます。' },
];

// ── テンプレートデータ定義 ────────────────────────────────────────────────────

// LayerEntity JSON を生成するヘルパー
function makeLayer({ layerType, config, colorHex = '#CCCCCC', opacity = 1.0, yRatio = 0.0, heightRatio = 1.0 }) {
  return JSON.stringify({
    uuid: randomUUID(),
    sortOrder: 0,
    isVisible: true,
    opacity,
    colorHex,
    bgColorHex: '',
    layerType,
    configJson: JSON.stringify({ runtimeType: layerType, ...config }),
    xRatio: 0.0,
    yRatio,
    widthRatio: 1.0,
    heightRatio,
  });
}

// PageConfig JSON
function makePageConfig({ holeConfig = 'h26', showLineNumbers = false } = {}) {
  return JSON.stringify({
    paperSize: 'a4',
    orientation: 'portrait',
    marginTopMm: 10.0,
    marginBottomMm: 10.0,
    marginLeftMm: 10.0,
    marginRightMm: 10.0,
    holeConfig,
    pageCount: 1,
    showPageNumber: false,
    showLineNumbers,
  });
}

// テンプレートバリエーション (各ユーザーに割り当て)
const TEMPLATE_VARIANTS = [
  {
    name: '方眼ノート（5mm）',
    description: 'A4・5mm方眼。数式や図を書くのに最適。',
    tags: ['方眼', '理系', '数学'],
    layerTypes: ['grid'],
    layersJson: [
      makeLayer({ layerType: 'grid', config: { cellWidthMm: 5.0, cellHeightMm: 5.0, lineStyle: 'solid' }, colorHex: '#AAAACC' }),
    ],
    pageConfigJson: makePageConfig({ showLineNumbers: false }),
  },
  {
    name: 'コーネル式ノート',
    description: '授業ノートに最適なコーネル式レイアウト。キーワード・サマリー欄つき。',
    tags: ['コーネル', '授業', '講義'],
    layerTypes: ['cornell'],
    layersJson: [
      makeLayer({ layerType: 'cornell', config: { leftColMm: 40.0, bottomRowMm: 25.0, lineSpacingMm: 6.0, keywordLabel: 'キーワード', summaryLabel: 'サマリー' }, colorHex: '#CCAAAA' }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: 'ドットノート',
    description: 'ドット方眼。手書きに自由度が高い。',
    tags: ['ドット', 'バレットジャーナル'],
    layerTypes: ['dot'],
    layersJson: [
      makeLayer({ layerType: 'dot', config: { spacingMm: 5.0, dotRadiusMm: 0.4, alignToOrigin: false }, colorHex: '#AACCAA' }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: 'グラフ用紙',
    description: 'ドット＋座標軸。実験データのプロットに。',
    tags: ['グラフ', '実験', '座標'],
    layerTypes: ['dot', 'graphAxis'],
    layersJson: [
      makeLayer({ layerType: 'dot', config: { spacingMm: 5.0, dotRadiusMm: 0.4, alignToOrigin: true }, colorHex: '#BBBBDD' }),
      makeLayer({ layerType: 'graphAxis', config: { showXAxis: true, showYAxis: true, arrowTip: true, showTickMarks: true, tickIntervalMm: 5.0, tickLengthMm: 1.5, xTickSide: 'both', yTickSide: 'both', xLabel: 'x', yLabel: 'y', showNegative: true }, colorHex: '#111111' }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: '数式罫線ノート',
    description: '∫・Σなど上付き下付きが書きやすいサブ線入り罫線。',
    tags: ['数式', '罫線', '数学'],
    layerTypes: ['customLine'],
    layersJson: [
      makeLayer({
        layerType: 'customLine',
        config: {
          lineSets: [
            {
              isHorizontal: true,
              count: 20,
              spacingMm: 12.0,
              startMm: 0.0,
              strokeWidthMm: 0.3,
              lineStyle: 'solid',
              subLines: [
                { positionRatio: 0.33, strokeWidthMm: 0.15, lineStyle: 'dashed' },
                { positionRatio: 0.67, strokeWidthMm: 0.15, lineStyle: 'dashed' },
              ],
            },
          ],
        },
        colorHex: '#8888CC',
      }),
    ],
    pageConfigJson: makePageConfig({ showLineNumbers: true }),
  },
  {
    name: '実験ノート',
    description: '目的・方法・結果・考察欄つきの実験記録用テンプレート。',
    tags: ['実験', '理系', 'レポート'],
    layerTypes: ['header', 'grid'],
    layersJson: [
      makeLayer({ layerType: 'header', config: { showTitle: true, titleLabel: '目的', showDate: true, dateLabel: '方法', showName: true, nameLabel: '結果', showSubject: true, subjectLabel: '考察', rowHeightMm: 10.0, showBorder: true }, colorHex: '#DDDDDD', yRatio: 0.0, heightRatio: 0.1 }),
      makeLayer({ layerType: 'grid', config: { cellWidthMm: 5.0, cellHeightMm: 5.0, lineStyle: 'solid' }, colorHex: '#AAAACC', yRatio: 0.1, heightRatio: 0.9 }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: '極座標グラフ',
    description: '極座標系のグラフ用紙。波形や複素数の描画に。',
    tags: ['極座標', 'グラフ', '物理'],
    layerTypes: ['polar'],
    layersJson: [
      makeLayer({ layerType: 'polar', config: { rings: 8, sectors: 12 }, colorHex: '#AACCCC' }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: '六角形ノート',
    description: '化学の結合図や有機化学の構造式に最適。',
    tags: ['六角形', '化学', '有機化学'],
    layerTypes: ['hex'],
    layersJson: [
      makeLayer({ layerType: 'hex', config: { hexSizeMm: 6.0, orientation: 'flat' }, colorHex: '#CCAACC' }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: '製図用等角図',
    description: '3Dスケッチや立体図形の描画に。',
    tags: ['製図', '等角', '建築'],
    layerTypes: ['isometric'],
    layersJson: [
      makeLayer({ layerType: 'isometric', config: { spacingMm: 5.0, lineStyle: 'solid' }, colorHex: '#CCCCAA' }),
    ],
    pageConfigJson: makePageConfig(),
  },
  {
    name: '講義ノート（コーネル式）',
    description: '科目名・日付欄つきのコーネル式講義ノート。',
    tags: ['コーネル', '講義', '授業'],
    layerTypes: ['header', 'cornell'],
    layersJson: [
      makeLayer({ layerType: 'header', config: { showTitle: true, titleLabel: '科目', showDate: true, dateLabel: '日付', showName: false, showSubject: false, rowHeightMm: 9.0, showBorder: true }, colorHex: '#DDDDDD', yRatio: 0.0, heightRatio: 0.05 }),
      makeLayer({ layerType: 'cornell', config: { leftColMm: 40.0, bottomRowMm: 25.0, lineSpacingMm: 6.0, keywordLabel: 'キーワード', summaryLabel: 'サマリー' }, colorHex: '#CCAAAA', yRatio: 0.05, heightRatio: 0.95 }),
    ],
    pageConfigJson: makePageConfig(),
  },
];

// ── ユーティリティ ────────────────────────────────────────────────────────────

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function shuffle(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function pick(arr, n) {
  return shuffle(arr).slice(0, n);
}

function randomPastDate(daysAgo = 60) {
  const ms = Date.now() - randomInt(0, daysAgo) * 86400000;
  return new Date(ms);
}

// ── メイン処理 ────────────────────────────────────────────────────────────────

async function createUsers() {
  console.log('\n📦 Step 1: テストユーザー作成...');
  const users = [];

  for (const u of TEST_USERS) {
    // Firebase Auth ユーザーを作成（既存なら取得）
    let authUser;
    try {
      authUser = await auth.getUserByEmail(u.email);
      console.log(`  ✓ 既存: ${u.email}`);
    } catch {
      authUser = await auth.createUser({
        email: u.email,
        password: TEST_PASSWORD,
        displayName: u.displayName,
        emailVerified: true,
      });
      console.log(`  ✓ 新規: ${u.email}`);
    }

    // Firestore users ドキュメント作成
    await db.collection('users').doc(authUser.uid).set(
      {
        displayName: u.displayName,
        bio: u.bio,
        templateCount: 0,
        totalLikes: 0,
        followerCount: 0,
        followingCount: 0,
        createdAt: randomPastDate(90),
      },
      { merge: true }
    );

    users.push({ uid: authUser.uid, ...u });
  }

  return users;
}

async function createTemplates(users) {
  console.log('\n📦 Step 2: ギャラリーテンプレート作成...');
  const allTemplates = [];

  for (const [i, user] of users.entries()) {
    // 各ユーザーに 5 種のテンプレートをランダムに割り当て
    const variants = pick(TEMPLATE_VARIANTS, 5);

    for (const variant of variants) {
      const docRef = db.collection('gallery_templates').doc();
      const data = {
        name: variant.name,
        authorId: user.uid,
        authorName: user.displayName,
        description: variant.description,
        pageConfigJson: variant.pageConfigJson,
        layersJson: variant.layersJson,
        layerTypes: variant.layerTypes,
        tags: variant.tags,
        downloadCount: randomInt(0, 30),
        likeCount: 0,
        createdAt: randomPastDate(60),
      };

      await docRef.set(data);
      allTemplates.push({ id: docRef.id, authorId: user.uid });
      console.log(`  ✓ ${user.displayName} → ${variant.name}`);
    }

    // templateCount を投稿数に更新
    await db.collection('users').doc(user.uid).set(
      { templateCount: variants.length },
      { merge: true }
    );
  }

  return allTemplates;
}

async function createFollows(users) {
  console.log('\n📦 Step 3: フォロー関係構築...');
  const batch = db.batch();
  let batchCount = 0;

  for (const user of users) {
    const others = users.filter(u => u.uid !== user.uid);
    const targets = pick(others, randomInt(2, 5));

    for (const target of targets) {
      batch.set(
        db.collection('users').doc(user.uid).collection('following').doc(target.uid),
        { createdAt: randomPastDate(30) }
      );
      batch.set(
        db.collection('users').doc(user.uid),
        { followingCount: FieldValue.increment(1) },
        { merge: true }
      );
      batch.set(
        db.collection('users').doc(target.uid),
        { followerCount: FieldValue.increment(1) },
        { merge: true }
      );
      batchCount++;
      console.log(`  ✓ ${user.displayName} → ${target.displayName}`);

      // Firestore バッチは 500 操作まで
      if (batchCount >= 100) {
        await batch.commit();
        batchCount = 0;
      }
    }
  }

  if (batchCount > 0) await batch.commit();
}

async function createLikes(users, templates) {
  console.log('\n📦 Step 4: いいね設定...');

  for (const template of templates) {
    const likers = pick(
      users.filter(u => u.uid !== template.authorId),
      randomInt(2, 7)
    );

    if (likers.length === 0) continue;

    const batch = db.batch();

    // テンプレートの likeCount を更新
    batch.update(
      db.collection('gallery_templates').doc(template.id),
      { likeCount: FieldValue.increment(likers.length) }
    );

    // 著者の totalLikes を更新
    batch.set(
      db.collection('users').doc(template.authorId),
      { totalLikes: FieldValue.increment(likers.length) },
      { merge: true }
    );

    await batch.commit();
    console.log(`  ✓ template:${template.id.slice(0, 6)}... → ❤️ ${likers.length}`);
  }
}

async function createComments(users, templates) {
  console.log('\n📦 Step 5: コメント投稿...');

  const COMMENTS = [
    'とても使いやすいです！',
    '数式を書くのにぴったりです。',
    'シンプルで好きです。',
    '授業ノートに活用しています。',
    'グリッドの間隔が絶妙ですね。',
    'いつも使わせてもらっています！',
    'おしゃれなデザインですね。',
    '実験ノートにちょうど良い。',
    '使いやすいレイアウトありがとうございます。',
    'このサイズが一番書きやすい。',
  ];

  for (const template of templates) {
    const commenters = pick(users.filter(u => u.uid !== template.authorId), randomInt(0, 3));

    for (const commenter of commenters) {
      const text = COMMENTS[randomInt(0, COMMENTS.length - 1)];
      await db
        .collection('gallery_templates')
        .doc(template.id)
        .collection('comments')
        .add({
          authorId: commenter.uid,
          authorName: commenter.displayName,
          text,
          createdAt: randomPastDate(30),
        });
      console.log(`  ✓ ${commenter.displayName}: "${text}"`);
    }
  }
}

async function printSummary(users, templates) {
  console.log('\n🎉 完了！\n');
  console.log('──────────────────────────────────────');
  console.log(`👤 テストユーザー: ${users.length} 人`);
  console.log(`📋 ギャラリー投稿: ${templates.length} 件`);
  console.log('\nテストアカウント (パスワード共通)');
  console.log(`  パスワード: ${TEST_PASSWORD}`);
  users.forEach(u => console.log(`  ${u.email}  (${u.displayName})`));
  console.log('──────────────────────────────────────');
}

// ── 実行 ─────────────────────────────────────────────────────────────────────

(async () => {
  try {
    const users = await createUsers();
    const templates = await createTemplates(users);
    await createFollows(users);
    await createLikes(users, templates);
    await createComments(users, templates);
    await printSummary(users, templates);
  } catch (err) {
    console.error('\n❌ エラー:', err);
    process.exit(1);
  }
})();
