#!/bin/bash
set -exo pipefail

# # ディレクトリ情報の取得
# CURRENT_PATH=$(cd $(dirname $0); pwd)
# ROOT_PATH=$CURRENT_PATH/..

# mktemp で作業用のディレクトリを作成 (カレントディレクトリが汚れないようにするため, 不要なファイルが zip に入らないようにするため)
TEMPDIR=$(mktemp -d)
# 各自のバケット名に書き換え
ARTIFACT_BUCKET="aoiorio-bucket-lambda-artifacts"

# function で使うバイナリをzipファイルに追加
cp function/* "$TEMPDIR"
cd "$TEMPDIR"
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap main.go
zip "$TEMPDIR"/deployment-package.zip -r ./bootstrap
cd -

# ソースコードをzipファイルに追加
# zip -g deployment-package.zip -j $ROOT_PATH/src/main.py

# S3にアップロードしてlambda関数の参照を書き換える
aws s3 cp "$TEMPDIR"/deployment-package.zip s3://$ARTIFACT_BUCKET/
aws lambda update-function-code --function-name hello_go_function --s3-bucket $ARTIFACT_BUCKET --s3-key deployment-package.zip

# デプロイ時の一時ファイルを削除
rm -rf "$TEMPDIR"

set +x
echo "INFO: Deploy success 🍕"