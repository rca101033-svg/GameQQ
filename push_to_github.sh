#!/bin/bash
# 一鍵推播指令碼 (Linux / macOS)
if [ -z "$1" ]; then
    echo "使用方式: ./push_to_github.sh <您的 GitHub 儲存庫 URL>"
    echo "範例: ./push_to_github.sh https://github.com/myname/wasteland-card-game.git"
    exit 1
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$1"
git branch -M main
git push -u origin main
echo "推播完成！請確認 GitHub Actions 是否已自動開始建置。"
