#!/bin/bash
cd /Users/wnus/backend-server
git fetch origin main
git reset --hard origin/main
pm2 restart backend-api
pm2 list
