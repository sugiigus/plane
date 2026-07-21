# 運用ガイド

- 状態確認: `docker compose -p plane-jp -f docker-compose.yml -f deploy/docker-compose.production.yml ps`
- ログ確認: 同じ Compose コマンドに `logs --tail=200 proxy api worker` を付ける。
- ヘルスチェック: `deploy/healthcheck.sh`
- バックアップ: `deploy/backup.sh`。既定保存先は `/var/backups/plane-jp/<timestamp>`。
- 更新: `deploy/update.sh`。バックアップ、`develop` のfast-forward、再ビルド、ヘルスチェックを順に行う。

復元は障害原因を特定してから、別途承認のうえで停止時間を計画し、`pg_restore` と uploads アーカイブを対象ボリュームへ復元する。`docker system prune -a`、`docker volume prune`、`docker compose down -v`、`rm -rf /opt/plane-jp` は使用禁止。稼働中の既存サービスを停止しない。
