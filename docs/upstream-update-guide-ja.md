# 公式 Plane 更新取り込み手順

本フォークの基準ブランチは公式の `preview`。更新前に `develop` の稼働版をバックアップし、作業ツリーがクリーンであることを確認する。

```bash
git fetch upstream
git switch preview
git merge --no-ff upstream/preview
git push origin preview
git switch develop
git merge --no-ff preview
# pnpm i18n同期検査、lint、型検査、ビルド、ローカル確認
git push origin develop
```

競合時は `packages/i18n/src/locales/ja/`、既定言語、日時ロケールの変更を残す。解消後に `pnpm --filter @plane/i18n check:sync` と日本語UI確認を実行する。サーバー反映は `/opt/plane-jp/deploy/update.sh` を使用する。失敗時はバックアップと直前コミットを使い、DBの復元は必要な場合だけ行う。
