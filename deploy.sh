#!/bin/zsh
cd /Users/wnus/backend-server
git fetch origin main
git reset --hard origin/main
npm install
pm2 restart backend-api
