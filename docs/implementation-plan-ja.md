# Plane 日本語版・LAN内運用 実装計画

## 現状分析（2026-07-22）

- 公式リポジトリは `makeplane/plane`、既定ブランチは `preview`（コミット `a8e53b6ac7b87bd8e3e931d21188f7679c7ab6c4`）。
- フォークは `https://github.com/sugiigus/plane`、ローカル作業場所は `D:\Workspace\Executive Assistant\plane-git-fork`。
- フロントエンドは Next.js 系のモノレポで、`packages/i18n` の i18next を使う。`ja` は英語と同数の 28 名前空間で既に提供されている。
- バックエンドは Django、標準タイムゾーンは UTC、プロファイルの既定言語は `en`。これらを日本向けに変更する。
- Windows は Git/GitHub CLI/Node.js を備えるが、Docker Desktop エンジンは停止中。pnpm は未取得で、Node の証明書検証エラーを解消してから導入する必要がある。
- Ubuntu サーバーは `192.168.1.200`（Ubuntu 26.04、Docker 29.1.3、30 GiB RAM、349 GiB 空き）。`8085` は未使用、UFW は有効、既存サービスは 8000/8765/8766/3000/3100 を使用中。

## フォーク・ブランチ戦略

`preview` を公式追従の基準、`develop` を社内統合、`feature/ja-localization` を変更作業に使用する。`origin` は `Sugiigus/plane`、`upstream` は `makeplane/plane` とする。公式リポジトリには push しない。

## 日本語対応

既存の `packages/i18n/src/locales/ja/` を利用し、`FALLBACK_LANGUAGE`、新規プロファイルの言語、Django の言語・タイムゾーンを `ja` / `Asia/Tokyo` に変更する。日付時刻を表示する主要コンポーネントは現在の選択言語に追従させる。未訳の主要ラベルは同じ JSON ロケール内で補完する。既存ユーザーの保存済み言語は変更しない。

## 変更予定ファイル

- `packages/i18n/src/constants/language.ts`
- `packages/i18n/src/locales/ja/common.json`
- `apps/web/core/components/{user,home}/user-greetings.tsx`
- `apps/web/core/components/profile/time.tsx`
- `apps/api/plane/settings/common.py`
- `apps/api/plane/db/models/user.py` とそのマイグレーション
- `deploy/` と `docs/` の運用文書

## ローカル起動・テスト

Docker Desktop を起動後、`NODE_OPTIONS=--use-system-ca corepack pnpm install --frozen-lockfile` を実行し、公式 `setup.sh` 相当の開発用環境変数を作成する。`docker compose -f docker-compose-local.yml up -d` と `pnpm dev` で確認する。i18n 同期検査、lint、型検査、ビルド、Docker Compose 構成検査を実行し、実行不能な項目は報告書へ記録する。

## Ubuntu デプロイ

サーバー上の `/opt/plane-jp` に `develop` を Git clone する。公式ルート Compose を `plane-jp` プロジェクト名でビルド・起動し、DB・Redis・RabbitMQ・MinIO の名前付きボリュームを永続化する。環境変数はサーバー上の `.env` と `apps/api/.env` にのみ保存し、Gitには含めない。公開 URL は `http://192.168.1.200:8085` とする。

## LAN 内アクセス制限

Compose の HTTP 公開は `192.168.1.200:8085` にのみバインドする。加えて Docker が UFW を迂回できるため、`DOCKER-USER` チェーンで受信インターフェース `wlp5s0` のコンテナ向け HTTP を `192.168.1.7` だけ許可し、他は拒否する。ルールの永続化と、UFW の送信元限定ルールを併用する。HTTPS、DNS、ルーター設定、外部トンネルは使用しない。

## バックアップ、更新、ロールバック

バックアップは Compose 停止なしで PostgreSQL の `pg_dump`、アップロード用ボリュームのアーカイブ、設定ファイルの権限付きコピーを行う。更新前に必ずバックアップし、`upstream` の差分を検査して `preview`、`develop` の順にマージする。失敗時は直前コミットを checkout して再ビルドし、DB復元が必要なときだけ明示的な復元手順を実行する。

## 既存サービスへの影響とリスク

既存の 8000/8765/8766/3000/3100 と Docker コンテナは停止・削除しない。Plane はビルド時にCPU・メモリ・ディスクを消費する。Compose が作る汎用コンテナ名との衝突、Docker でのファイアウォール迂回、ローカルの証明書チェーン、初回アカウント作成時の認証方式が主なリスクであり、構成検査・ヘルスチェック・限定公開で確認する。
