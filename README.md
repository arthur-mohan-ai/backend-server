# Backend Server
Public API Base URL: https://api.arthurmohanai.blog

> Node backend running on Mac Mini, served via Cloudflare Zero Trust Tunnel.
> PM2 manages node service in background; closing Terminal will NOT take backend offline.

## ⚠️ Important Notes
- Do NOT run multiple node instances at the same time.

## Local Test Endpoint
`http://localhost:3000/api/hello`

## Public Online Endpoint
`https://api.arthurmohanai.blog/api/hello`

## Team Git Workflow
```bash
git clone https://github.com/arthur-mohan-ai/backend-server.git
cd backend-server
npm install
git checkout -b feature/your-feature-name
git add .
git commit -m "add: description of your changes"
git push origin feature/your-feature-name
