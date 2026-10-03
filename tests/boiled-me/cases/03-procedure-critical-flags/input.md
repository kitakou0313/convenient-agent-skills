# APIコンテナの起動手順

1. 利用するバージョンのイメージを取得する。バージョンは必ず固定し、`latest` は使わない。`docker pull registry.example.com/api:2.4.1`
2. コンテナを起動する。`docker run -d -p 8443:8443 --restart=always --name api registry.example.com/api:2.4.1` ホスト側とコンテナ側のポートは同じ8443を指定する。
3. 起動後、`curl -fsS https://localhost:8443/healthz` を実行し、HTTP 200 が返ることを確認する。
4. 200 が返らない場合は、`docker logs --tail 200 api` で直近200行のログを確認し、原因を調べる。
