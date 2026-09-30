#!/bin/zsh
cd /Users/wnus/backend-server
git fetch origin main
git reset --hard origin/main
npm ci
pm2 restart backend-api
