#!/bin/bash
# 廢土卡牌手遊 - 一鍵建立並推播至 GitHub
set -e

REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
    echo "========================================================"
    echo "請輸入您的 GitHub 儲存庫 URL（例如 https://github.com/使用者/wasteland-card-game.git）"
    echo "用法: ./setup_and_push.sh <儲存庫URL>"
    echo "========================================================"
    read -p "請貼上 GitHub Repository URL: " REPO_URL
fi

if [ -z "$REPO_URL" ]; then
    echo "❌ 未提供 URL，取消推播。"
    exit 1
fi

echo "🚀 開始設定遠端儲存庫: $REPO_URL ..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"
git branch -M main

echo "📦 正在推播至 GitHub main 分支..."
git push -u origin main

echo "✅ 推播成功！"
echo "請前往 GitHub 儲存庫 Settings -> Pages，將 Source 設為 'GitHub Actions'，即可自動發布手機版網頁！"
