# Full Deployment & Operation Manual
This manual contains full setup, deployment, service management and troubleshooting steps for the backend server.

## 1. First Time Environment Setup (Mac Mini Server)
### Install Node.js & npm
brew install node

Verify installation:
node -v
npm -v

### Install PM2 (Background process manager for Node.js)
npm install -g pm2

### Clone Repository (Run once only)
git clone https://github.com/arthur-mohan-ai/backend-server.git
cd backend-server
npm install

## 2. Start Backend Service with PM2
# Kill old foreground node process if exists
pkill -f "node server.js"

# Launch backend and name it backend-api
pm2 start server.js --name backend-api

# Enable auto-start on Mac reboot
pm2 startup
# Copy and run the sudo command output from above

# Save current PM2 service list
pm2 save

### PM2 Full Command Reference
pm2 list                  # Check running backend status
pm2 restart backend-api   # Restart backend (use after code deployment)
pm2 logs backend-api      # View real-time backend logs
pm2 stop backend-api      # Stop backend service
pm2 delete backend-api    # Remove backend from PM2 list
pm2 status                # Quick overview of services

## 3. Cloudflare Tunnel Management
Tunnel name: `arthur-api-tunnel`
The tunnel is installed as Mac launchd daemon, persistent across terminal close.

Check tunnel status:
sudo launchctl list | grep cloudflared

Restart cloudflared tunnel:
sudo launchctl stop com.cloudflare.cloudflared
sudo launchctl start com.cloudflare.cloudflared

> Fixed custom domain: `api.arthurmohanai.blog`, no temporary trycloudflare URL.

## 4. One-Click Deployment Script (deploy.sh)
deploy.sh source code:
#!/bin/bash
cd /Users/wnus/backend-server
git pull origin main
echo "Code pulled from Github"
pm2 restart backend-api
echo "Server restarted via pm2"

Give execution permission (run once only):
chmod +x deploy.sh

Deployment workflow
After teammates merge Pull Request into main branch, run this on Mac Mini:
./deploy.sh

The script automatically pulls latest code and restarts backend service.

## 5. Team Git Workflow (For all teammates)
Clone repo to local computer (once):
git clone https://github.com/arthur-mohan-ai/backend-server.git
cd backend-server
npm install

Create new branch for feature development:
git checkout -b feature/your-feature-name

Commit & push changes:
git add .
git commit -m "add: description of your changes"
git push origin feature/your-feature-name

Create Pull Request on GitHub for code review.
After approved, merge to `main` branch, then run deployment script on server.

## 6. Service Recovery & Troubleshooting Guide
If backend service crashes:
pm2 restart backend-api

If cloudflared tunnel disconnects:
sudo launchctl start com.cloudflare.cloudflared

After Mac Mini reboot
1. PM2 will automatically start `backend-api`
2. Cloudflared tunnel will auto start as system daemon
3. Verify service by visiting public API endpoint

Port conflict warning
Only run one node instance on port 3000.
If port occupied, kill old node process:
pkill -f "node server.js"

## 7. Test Endpoints
Local test: http://localhost:3000/api/hello
Public online test: https://api.arthurmohanai.blog/api/hello

## Project Information
- Github Repository: https://github.com/arthur-mohan-ai/backend-server.git
- Github PAT token name: arthur-api
- Cloudflare Tunnel name: arthur-api-tunnel
