# リリース前のメンテナンス手順

1. 古いログを削除する。`find /var/log/app -mtime +30 -delete` を実行する。ログがディスク容量を圧迫するためである。
2. キャッシュを再生成する。`./manage.sh rebuild-cache` を実行する。古いキャッシュが不整合を起こす可能性があるためである。
3. 定期バッチを停止する。`systemctl stop batch.timer` を実行する。リリース中にバッチが二重実行されるのを防ぐためである。
4. リリースを実施する。
5. 定期バッチを再開する。`systemctl start batch.timer` を実行する。
