#!/bin/bash
cd /Users/wnus/backend-server
echo "🔄 Pulling latest code from GitHub..."
git pull origin main
if [ $? -ne 0 ]; then
    echo "❌ Git pull FAILED! Deployment aborted, server NOT restarted."
    exit 1
fi
echo "✅ Code pulled from Github"
pm2 restart backend-api
echo "✅ Server restarted via pm2"

