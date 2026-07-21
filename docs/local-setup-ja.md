# Windows ローカル環境

作業場所は `D:\Workspace\Executive Assistant\plane-git-fork`。必要なのは Git、Node.js 22.18 以上、Corepack/pnpm、Docker Desktop である。

```powershell
cd 'D:\Workspace\Executive Assistant\plane-git-fork'
$env:NODE_OPTIONS='--use-system-ca'
corepack pnpm install --frozen-lockfile
Copy-Item .env.example .env
Copy-Item apps/api/.env.example apps/api/.env
Copy-Item apps/web/.env.example apps/web/.env
Copy-Item apps/admin/.env.example apps/admin/.env
Copy-Item apps/space/.env.example apps/space/.env
Copy-Item apps/live/.env.example apps/live/.env
docker compose -f docker-compose-local.yml up -d
pnpm dev
```

Docker Desktop が起動していることを `docker info` で確認する。`.env` はローカル専用であり、絶対にコミットしない。停止時は通常の `docker compose -f docker-compose-local.yml down` を使い、`-v` は使用しない。

確認項目は、ログイン画面が日本語であること、日本語のワークスペース・プロジェクト・タスク・コメント・検索、ステータス変更、再起動後のデータ保持、ブラウザとサービスログの重大エラーなしである。
