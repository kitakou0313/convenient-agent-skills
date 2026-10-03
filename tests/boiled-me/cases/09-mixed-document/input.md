# CIのGitHub Actionsへの移行

## 背景
CIは、JenkinsからGitHub Actionsへ移行すべきである。Jenkinsの保守に月20時間かかっており、これを削減できる。また、Jenkinsプラグインの脆弱性対応が遅れがちで、セキュリティ上のリスクになっている。

## 移行手順
1. `.github/workflows/ci.yml` を作成し、ビルドとテストのジョブを定義する。
2. リポジトリのシークレットに `DEPLOY_TOKEN` を登録する。
3. ローカルで `act -j build` を実行し、ワークフローの動作を事前に検証する。

## 切り替え方針
移行後は、Jenkinsを2週間並行稼働させたうえで停止するのがよい。並行稼働中であれば、GitHub Actions側に問題が見つかった場合にJenkinsへすぐ戻せるためである。

## Jenkins停止手順
1. 2週間の並行稼働で問題がないことを確認する。
2. `jenkins-cli disable-job` で、対象のジョブをすべて無効化する。
3. Jenkinsサーバーを停止する。
