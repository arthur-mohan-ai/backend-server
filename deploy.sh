#!/bin/bash
cd /Users/wnus/backend-server
git pull origin main
echo "Code pulled from GitHub"
pkill -f "node server.js"
node server.js
