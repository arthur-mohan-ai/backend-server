# Shotski Backend

Public API Base URL: https://api.arthurmohanai.blog

> TypeScript + Express API running on the Mac mini, served via Cloudflare Zero Trust Tunnel.
> PM2 keeps it running in the background; closing Terminal will NOT take the backend offline.

## Repository layout

```
apps/api/       Express API (TypeScript)
packages/       Shared code between apps (none yet)
docs/           Design documents (e.g. data-model.md)
```

This is an npm workspaces monorepo: run all npm commands from the repository root.

## Getting started

```bash
git clone https://github.com/shotski-server/shotski-backend-server.git
cd shotski-backend-server
npm ci
npm run dev:api
```

Then open http://localhost:3000/api/hello. The dev server restarts automatically when you save a file.

## Build and run like production

```bash
npm run build
npm run start:api
```

## Deployment

Run `deploy.sh` on the Mac mini. It resets to `origin/main`, installs dependencies with `npm ci`,
builds, and (re)starts the API with PM2 using `ecosystem.config.cjs`.

⚠️ Do NOT run multiple node instances at the same time.

## Endpoints

- Local: `http://localhost:3000/api/hello`
- Public: `https://api.arthurmohanai.blog/api/hello`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch names, commit messages, PR and review rules.