---
description: マネーフォワード未分類支出の分類
mode: interactive
---
マネーフォワードの未分類支出を適切なカテゴリに分類する。

## 手順

### 1. ページアクセス

Chrome DevTools MCPで `https://moneyforward.com/cf` にアクセス。ログイン済み前提。

### 2. 未分類取引の特定

JavaScript実行で未分類取引を一括取得:

```javascript
// cf-detail-tableからlarge_category_id=0の行を抽出
const table = document.getElementById('cf-detail-table');
const rows = table.querySelectorAll('tr.transaction_list');
const uncats = [];
rows.forEach(row => {
  const lcatInput = row.querySelector('.h_l_ctg');
  if (lcatInput && lcatInput.value === '0') {
    const idInput = row.querySelector('input[name="user_asset_act[id]"]');
    const contentTd = row.querySelectorAll('td')[2];
    uncats.push({
      id: idInput ? idInput.value : '',
      content: contentTd ? contentTd.textContent.trim() : ''
    });
  }
});
return uncats;
```

未分類が0件なら「未分類の支出はありません」と報告して終了。

### 3. カテゴリ判断

取得した未分類取引の内容から適切なカテゴリを判断する。

- 判断に迷う取引はqmd MCPで検索し、ノートから文脈を補完する
- 判断が難しいものはユーザーに確認する
- **分類案をユーザーに提示し、承認を得てから更新を実行する**

### 4. API一括更新

カテゴリIDの対応表をページ上の既存分類済み取引から取得:

```javascript
// 既存取引からカテゴリ名→ID対応を収集
const cats = {};
rows.forEach(row => {
  const lcatInput = row.querySelector('.h_l_ctg');
  const mcatInput = row.querySelector('.h_m_ctg');
  const tds = row.querySelectorAll('td');
  if (lcatInput && tds.length > 5) {
    const key = tds[5].textContent.trim() + '>' + tds[6].textContent.trim();
    if (!cats[key]) cats[key] = { lcat: lcatInput.value, mcat: mcatInput.value };
  }
});
return cats;
```

対応表にないカテゴリ（交通費等）はUIクリックで設定する。

<api_reference>
エンドポイント: `POST https://moneyforward.com/cf/update`
ヘッダー: `X-Requested-With: XMLHttpRequest`
ボディ（FormData）:
- `user_asset_act[id]` — 取引ID
- `user_asset_act[large_category_id]` — 大項目ID
- `user_asset_act[middle_category_id]` — 中項目ID
- `user_asset_act[table_name]` = `user_asset_act`
- `user_asset_act[is_target]` = `1`
- `user_asset_act[is_income]` = `0`
- `authenticity_token` — `meta[name="csrf-token"]`から取得
- `_method` = `put` — **必須。これがないと404になる**
</api_reference>

### 5. 結果確認

更新後にページをリロードし、未分類が0件になったことを確認する。

### 6. 結果出力

分類結果を以下の形式で出力:

```
未分類N件を分類完了。食費: X件、趣味・娯楽: Y件、交通費: Z件...
```
