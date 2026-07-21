# Plane 日本語版 作業報告

最終更新: 2026-07-22（作業継続前の中間記録）

## 実施済み

- 公式リポジトリ `https://github.com/makeplane/plane` を `https://github.com/sugiigus/plane` へフォークした。
- ローカルクローンは `D:\Workspace\Executive Assistant\plane-git-fork`。`origin` はフォーク、`upstream` は公式リポジトリに設定済み。
- 公式既定ブランチが `preview` であることを確認し、`develop` をフォークへpush、`feature/ja-localization` を作成した。
- 既存i18nの日本語ロケール（28名前空間、3,837キー）を確認し、初期言語を日本語へ変更した。
- Djangoの既定言語を `ja`、タイムゾーンを `Asia/Tokyo`、新規プロファイルの言語を `ja` に変更し、マイグレーション `0122_profile_default_language_ja.py` を追加した。
- ホーム／プロフィールの日時を選択中ロケールに追従させ、主要な残存英語ラベルを日本語に補完した。
- デプロイ、バックアップ、更新、ヘルスチェック、Dockerの送信元制限用スクリプトと運用文書を追加した。

## サーバー調査結果

- Ubuntu 26.04 LTS、LAN IP `192.168.1.200`、Docker 29.1.3、Docker Compose 利用可。
- 8085 は未使用。既存公開ポートは 8000、8765、8766、3000、3100であり、停止・変更していない。
- UFW は有効。`192.168.1.7` 向けの既存限定ルールを確認した。
- 設計上のPlane URL: `http://192.168.1.200:8085`。ComposeのIPバインドとUFWに加え、`DOCKER-USER` で送信元 `192.168.1.7` だけを許可する。

## 検証結果

| 項目                             | 結果                                                       |
| -------------------------------- | ---------------------------------------------------------- |
| 日本語JSON構文                   | 成功                                                       |
| 日本語キー同期                   | 成功（英語3,837キー、欠落0）                               |
| Django設定・マイグレーション構文 | 成功                                                       |
| デプロイスクリプト構文           | 成功                                                       |
| Git差分の空白検査                | 成功                                                       |
| i18n型生成・型検査               | 成功                                                       |
| 全体TypeScript検査               | Windowsのpnpm並列実行／Husky設定ロックで中断（変更箇所外） |
| ローカルCompose構成検査          | 成功                                                       |
| ローカルDockerビルド・起動       | 未完了（Docker BuildKit内のAlpine TLS証明書検証に失敗）    |

## 未実施とブロッカー

ローカルのDockerビルドは `dl-cdn.alpinelinux.org` の証明書をDocker BuildKitが信頼できず、`apk add` で停止した。TLS検証を無効化して回避しない。Docker Desktopに組織のルートCAを安全に信頼させる、またはネットワーク側のTLS検査を適切に設定する必要がある。

このため、ブラウザでの日本語UI・タスク・コメント・検索確認、Dockerイメージビルド、GitHubへの機能ブランチpush、`develop`へのマージ、Ubuntu本番デプロイ、実アクセス制限の適用は未実施である。認証情報、`.env`、SSH鍵、トークンはGitに追加していない。

## 今後の手順

1. Docker Desktopの信頼ストア問題を解消して `docker compose -f docker-compose-local.yml up -d --build` を再実行する。
2. 日本語のUI・日本語入力・検索・永続化をブラウザで確認し、lint／型／ビルドを再実行する。
3. 差分の機密情報検査後、`feature/ja-localization` をcommit・pushし、`develop` へマージする。
4. Ubuntuの `/opt/plane-jp` に `develop` を配置し、秘密情報をサーバー上で生成してからデプロイ・アクセス制限・ヘルスチェックを実施する。
