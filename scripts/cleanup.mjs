/**
 * テストデータ削除スクリプト
 * 実行: cd scripts && npm run cleanup
 */

import { readFileSync } from 'fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const serviceAccount = JSON.parse(
  readFileSync(new URL('./serviceAccountKey.json', import.meta.url), 'utf8')
);

initializeApp({ credential: cert(serviceAccount) });

const auth = getAuth();
const db = getFirestore();

const TEST_EMAILS = Array.from({ length: 10 }, (_, i) =>
  `test${String(i + 1).padStart(2, '0')}@labnote-test.com`
);

async function deleteCollection(ref, batchSize = 100) {
  const snap = await ref.limit(batchSize).get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
  await deleteCollection(ref, batchSize);
}

(async () => {
  console.log('🗑️  テストデータを削除します...\n');

  // Auth ユーザー削除 & Firestore users 削除
  for (const email of TEST_EMAILS) {
    try {
      const user = await auth.getUserByEmail(email);

      // following サブコレクション削除
      await deleteCollection(
        db.collection('users').doc(user.uid).collection('following')
      );

      // users ドキュメント削除
      await db.collection('users').doc(user.uid).delete();

      // Auth ユーザー削除
      await auth.deleteUser(user.uid);
      console.log(`  ✓ 削除: ${email}`);
    } catch {
      console.log(`  - スキップ (存在しない): ${email}`);
    }
  }

  // ギャラリーテンプレート削除（テストユーザーの投稿のみ）
  console.log('\n  gallery_templates を検索中...');
  const testEmails = new Set(TEST_EMAILS);
  const uids = new Set();

  for (const email of TEST_EMAILS) {
    try {
      const u = await auth.getUserByEmail(email).catch(() => null);
      if (u) uids.add(u.uid);
    } catch {}
  }

  // uid ベースで gallery_templates を削除（再取得は不可なので authorId で検索）
  // ※ cleanup 前に uid を収集しているが、Auth 削除後は uid は保持
  const tmplSnap = await db.collection('gallery_templates').get();
  let deleted = 0;
  for (const doc of tmplSnap.docs) {
    const authorId = doc.data().authorName;
    // authorName が TEST_USERS にあるものを削除
    const testNames = ['田中 一郎','鈴木 花子','佐藤 健太','山田 美咲','伊藤 拓也',
                       '渡辺 さくら','小林 雄介','加藤 莉奈','吉田 誠','山本 あかり'];
    if (testNames.includes(doc.data().authorName)) {
      await deleteCollection(doc.ref.collection('comments'));
      await doc.ref.delete();
      deleted++;
    }
  }

  console.log(`  ✓ gallery_templates 削除: ${deleted} 件`);
  console.log('\n🎉 クリーンアップ完了');
})();
