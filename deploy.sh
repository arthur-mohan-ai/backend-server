#!/bin/bash
cd /Users/wnus/backend-server
git pull origin main
echo "Code pulled from Github"
pm2 restart backend-api
echo "Server restarted via pm2"
