# LAN 内アクセス制御

公開するのは HTTP のみ、`192.168.1.200:8085` だけである。独自ドメイン、公開DNS、ルーターのポート開放、Cloudflare Tunnel、インターネット向けHTTPSは使用しない。

`deploy/.env.example` の `LISTEN_HTTP_PORT=192.168.1.200:8085` により、Docker の公開ソケットをサーバーのLANアドレスへ限定する。Docker は通常のUFW転送規則を迂回し得るため、次も必須である。

```bash
cd /opt/plane-jp
./deploy/configure-lan-access.sh 192.168.1.7 wlp5s0 80 192.168.1.200 8085
sudo ufw status numbered
sudo iptables -S DOCKER-USER
```

このスクリプトは UFW の送信元限定ルールを追加し、`DOCKER-USER` から専用チェーンへ分岐させて、コンテナのHTTP（DNAT後の80番）を `192.168.1.7` 以外から拒否する。さらに `plane-jp-firewall.service` を有効化し、Dockerの再起動およびOS再起動後にもこの規則を復元する。UFW と競合する `iptables-persistent` は導入しない。既存のUFWルールを削除・初期化してはならない。
