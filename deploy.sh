#!/bin/bash
cd /Users/wnus/backend-server
echo "pulling latest code from github..."
git pull origin main
if [ $? -ne 0]; then
  echo "git pull failed! deployment aborted, server not restarted"
  exi1 1
fi
echo "code pulled from github"
pm2 restart backend-api
echo "server restarted via pm2"
