#!/bin/bash
cd /Users/wnus/backend-server
git fetch origin main
git reset --hard origin/main
npm ci
npm install
pm2 restart backend-api
pm2 list
pm2 startOrRestart server.js --name backend-api
