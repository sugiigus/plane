# Plane 日本語版 作業報告

最終更新: 2026-07-22（ai-server 稼働確認済み）

## 実施済み

- 公式リポジトリ `https://github.com/makeplane/plane` を `https://github.com/sugiigus/plane` へフォークした。
- ローカルクローンは `D:\Workspace\Executive Assistant\plane-git-fork`。`origin` はフォーク、`upstream` は公式リポジトリに設定済み。
- 公式既定ブランチが `preview` であることを確認し、`develop` をフォークへpush、`feature/ja-localization` を作成した。
- 既存i18nの日本語ロケール（28名前空間、3,837キー）を確認し、初期言語を日本語へ変更した。
- Djangoの既定言語を `ja`、タイムゾーンを `Asia/Tokyo`、新規プロファイルの言語を `ja` に変更し、マイグレーション `0122_profile_default_language_ja.py` を追加した。
- ホーム／プロフィールの日時を選択中ロケールに追従させ、主要な残存英語ラベルを日本語に補完した。
- デプロイ、バックアップ、更新、ヘルスチェック、Dockerの送信元制限用スクリプトと運用文書を追加した。
- `develop` へマージし、`/opt/plane-jp` の `develop` から ai-server にデプロイした。
- Caddy とリアルタイム通信サービスの実行時環境変数を本番Composeオーバーレイで明示的に渡すよう修正した。
- `192.168.1.200:8085` を `192.168.1.7` だけに限定し、UFW に加えて Docker の `DOCKER-USER` 規則を systemd で永続化した。

## サーバー調査結果

- Ubuntu 26.04 LTS、LAN IP `192.168.1.200`、Docker 29.1.3、Docker Compose 利用可。
- 既存の fxnews 関連コンテナは停止・変更していない。
- UFW は有効。Plane は `192.168.1.7` からの `192.168.1.200:8085/tcp` だけを許可している。
- `plane-jp-firewall.service` は有効・稼働中。Docker の公開ポートへの DNAT 後にも `192.168.1.7` 以外を拒否する。
- 運用URL: `http://192.168.1.200:8085`。

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
| ai-server PostgreSQL             | `pg_isready` と読み取りクエリが成功                        |
| ai-server DBマイグレーション     | `0122_profile_default_language_ja` を含め完了（exit 0）    |
| ai-server Plane サービス         | API、Web、Admin、Live、Proxy が稼働                        |
| 管理用PCからの到達性             | `192.168.1.7` から TCP・HTTP 200 を確認                    |

## 留意事項

ローカルのDockerビルドは `dl-cdn.alpinelinux.org` の証明書をDocker BuildKitが信頼できず、`apk add` で停止した。TLS検証を無効化して回避しない。Docker Desktopに組織のルートCAを安全に信頼させる、またはネットワーク側のTLS検査を適切に設定する必要がある。

ローカルDocker Desktopの証明書問題は未解消だが、ai-server では安全にビルド・稼働できている。認証情報、`.env`、SSH鍵、トークンはGitに追加していない。

## 初回利用と今後の手順

1. 管理用PCから `http://192.168.1.200:8085` を開き、初回管理者アカウントとワークスペースを作成する。
2. 日本語のタスク作成、コメント、検索、リアルタイム更新を実利用で確認する。
3. 更新時は `/opt/plane-jp/deploy/update.sh` を実行する。実行前に自動バックアップされる。
4. ローカル開発が必要になった時点で、Docker Desktopの組織CA信頼設定を解消する。
