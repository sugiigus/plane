# Ubuntu サーバーデプロイ

対象サーバーは SSH エイリアス `ai-server`、LAN IP は `192.168.1.200`、配置先は `/opt/plane-jp`、公開 URL は `http://192.168.1.200:8085` である。既存の 8000/8765/8766/3000/3100 と既存コンテナを停止しない。

```bash
ssh ai-server
sudo git clone --branch develop https://github.com/sugiigus/plane.git /opt/plane-jp
sudo chown -R "$USER":"$USER" /opt/plane-jp
cd /opt/plane-jp
cp deploy/.env.example .env
# .env と apps/*/.env を作成し、固有の秘密情報と http://192.168.1.200:8085 を設定する
./deploy/configure-lan-access.sh
./deploy/deploy.sh
```

`deploy/deploy.sh` は構成検証、ソースからのイメージビルド、起動、ヘルスチェックを行う。PostgreSQL、Valkey、RabbitMQ、MinIO は `plane-jp_*` 名前付きボリュームで永続化される。Docker サービスは有効化済みで、`restart: unless-stopped` によりOS再起動後に復旧する。

サーバー上の `.env` と `apps/api/.env` は `chmod 600` とし、リポジトリ・GitHub・バックアップ外部共有に置かない。
