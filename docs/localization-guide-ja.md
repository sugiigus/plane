# 日本語化ガイド

Plane は `packages/i18n` の i18next を使う。日本語ロケールは `src/locales/ja/` の 28 JSON 名前空間で管理され、英語ロケールのキーを削除・直接置換しない。

- 初期言語は `FALLBACK_LANGUAGE = "ja"`。利用者が変更した言語はブラウザの `userLanguage` に保存され、設定画面から他言語へ戻せる。
- 新規プロファイルの既定言語は Django モデルとマイグレーションで `ja` とする。既存ユーザーの言語は移行しない。
- サーバーの既定ロケールは `ja`、タイムゾーンは `Asia/Tokyo`。主要なホーム・プロフィール日時は現在の選択言語（日本語なら `ja-JP`）を使用する。
- 用語は Workspace=ワークスペース、Project=プロジェクト、Issue=タスク、Cycle=スプリント、Module=モジュール、Assignee=担当者、Priority=優先度、State=ステータスを基本とする。

翻訳変更後は `pnpm --filter @plane/i18n check:sync` を実行し、英語にないキーや不足キーを確認する。固有名詞、URL、プロトコル名は必要に応じて英語を残す。
