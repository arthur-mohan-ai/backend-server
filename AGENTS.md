# AGENTS.md

Instructions for AI coding agents (Claude Code, Codex, and others) working in this
repository. Human contributors: see `CONTRIBUTING.md`, which also applies to agents.

## Project

Shotski: a platform where skiers find photographers at ski resorts and pay to download
their photos and videos. The business model (open marketplace vs. resort partnerships)
is not decided yet, so we build the features both models share first. Do not implement
model-specific features (bookings, resort revenue sharing) unless explicitly asked.

## Stack

- npm workspaces monorepo. Run all npm commands from the repository root.
- `apps/api`: Express 5 + TypeScript in strict mode, ES modules (`"type": "module"`,
  `module: NodeNext`).
- Planned but not added yet: Neon (PostgreSQL) with Drizzle ORM, Zod for validation,
  React + Vite frontend in `apps/web`, Cloudflare R2 for media storage.
- Ask before adding any dependency, including the planned ones above.

## Commands

- Install dependencies: `npm ci`
- Add a dependency to the API: `npm install <package> -w @shotski/api`
- Dev server with auto-restart: `npm run dev:api` (http://localhost:3000/api/hello)
- Type check and build: `npm run build`. This must pass before every commit.
- Run the built server: `npm run start:api`
- There is no test suite yet.

## Code rules

- Relative imports must end in `.js`, e.g. `import { db } from "./db.js"`, even though
  the source file is `db.ts`. This is required by NodeNext module resolution.
- Do not use `any`, and do not weaken `tsconfig.json` (keep `strict: true`).
- Follow the naming conventions in `CONTRIBUTING.md`: database `snake_case`, TypeScript
  `camelCase` / `PascalCase`, API JSON fields `camelCase`, and the standard error format.
- The database schema's source of truth is `docs/data-model.md`. Money is stored as
  integer cents, timestamps as `TIMESTAMPTZ`, and media as R2 object keys. Never expose
  a public URL to an original photo or video.
- Never commit secrets. Use `.env` (git-ignored) and keep `.env.example` up to date.

## Git

- Never commit to or push `main`. Create a branch named `type/short-description` and
  open a pull request.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, ...).
- Commit `package-lock.json` together with dependency changes. Never commit
  `node_modules` or `dist`.

## Deployment: be careful

- `main` is production. `deploy.sh` on the Mac mini resets to `origin/main`, runs
  `npm ci` and `npm run build`, and restarts the API with PM2.
- Changes to `deploy.sh`, `ecosystem.config.cjs`, environment variables, dependencies or
  database migrations are deployment changes. Say so in the PR description and list the
  exact manual steps the deployer must run.
- `deploy.sh` overwrites itself during `git reset --hard`, and the shell keeps running
  the old version for the rest of that deploy. A change to `deploy.sh` only takes effect
  from the following deploy; the deployment notes must account for this.
- Never run `deploy.sh` or PM2 commands unless explicitly asked.

## Working with us

- We are learning TypeScript and web development. Prefer small, reviewable changes over
  large rewrites, and explain non-obvious decisions in the PR description.
