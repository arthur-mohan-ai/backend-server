#!/bin/zsh
set -e
cd /Users/wnus/backend-server
git fetch origin main
git reset --hard origin/main
npm ci
npm run build
pm2 startOrRestart ecosystem.config.cjs
pm2 save
pm2 list