# Contributing to Shotski

This file describes how we work together on this repository. It applies to
everyone, including the repository admins. If a rule gets in the way, change it
through a PR rather than ignoring it.

## The one rule that matters most

**`main` is production.** `deploy.sh` resets the Mac mini to whatever is on
`origin/main` and restarts the server. Anything that lands on `main` goes live
the next time someone deploys.

Therefore:

- Never commit or push directly to `main`, not even a one-line fix.
- Every change goes through a pull request and is reviewed by the other person
  before it is merged.

## Everyday workflow

```bash
git checkout main
git pull                                  # always start from the latest main
git checkout -b feat/short-description    # see "Branch names" below

# ...work, then commit in small logical steps...
git add <files>
git commit -m "feat: short description"

git push -u origin feat/short-description
```

Then open a PR on GitHub, request a review, and wait for approval.

After the PR is merged:

```bash
git checkout main
git pull
git branch -d feat/short-description
```

and delete the remote branch with the "Delete branch" button on the PR page.

## Branch names

Format: `type/short-description`, all lowercase, words separated by hyphens.

| Type        | Use for                                              |
|-------------|------------------------------------------------------|
| `feat/`     | A new feature                                        |
| `fix/`      | A bug fix                                            |
| `docs/`     | Documentation only                                   |
| `refactor/` | Restructuring code without changing behavior         |
| `chore/`    | Dependencies, config, build and deploy scripts       |
| `test/`     | Adding or fixing tests                               |

Examples: `feat/photographer-signup`, `fix/upload-timeout`, `docs/data-model`.

Do not use underscores or capital letters in branch names.

## Commit messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type: short description in the imperative mood
```

- `type` is one of `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `style`
  (formatting only, no logic change).
- Write the description as a command: "add upload endpoint", not "added" or "adds".
- Lowercase, no period at the end, 72 characters or fewer.
- One logical change per commit. If the message needs "and", consider two commits.
- If more explanation is needed, leave a blank line after the first line and
  write the details below it.

Examples:

```
feat: add photographer signup endpoint
fix: reject orders with a platform fee above the order amount
chore: add npm ci to deploy script
```

## Pull requests

- Keep each PR focused on one thing. Small PRs get reviewed faster and are
  easier to revert.
- Title: same format as a commit message.
- Description should cover:
  - **What** changed and **why**
  - **How it was tested** (commands run, endpoints checked)
  - **Deployment notes**: anything that must be done on the server, such as new
    environment variables, database migrations or PM2 changes. Write "None" if
    there are none.
  - `Closes #<issue number>` if the PR completes an issue.

### Reviewing

- We are 12 hours apart, so aim to review within 24 hours.
- Review for correctness and for understanding: if you cannot explain what a
  change does, ask in a comment before approving.
- Use "Request changes" for anything that must be fixed before merging, and a
  normal comment for suggestions.

### Merging and deploying

- After approval, the PR author merges.
- **Exception:** PRs that change deployment (`deploy.sh`, PM2 configuration,
  environment variables, database migrations, or dependencies) are merged by
  whoever can deploy to the Mac mini (currently Arthur), who deploys right after
  merging and checks `https://api.arthurmohanai.blog/api/hello`.
- Use "Create a merge commit" (the default).

## Naming conventions

### Database (PostgreSQL)

| Item            | Convention                                   | Example                    |
|-----------------|----------------------------------------------|----------------------------|
| Table           | plural, `snake_case`                         | `order_items`              |
| Column          | `snake_case`, full words, no abbreviations   | `thumbnail_key`            |
| Primary key     | `id`, `BIGINT GENERATED ALWAYS AS IDENTITY`  | `id`                       |
| Foreign key     | `<singular table>_id`, `BIGINT`              | `photographer_id`          |
| Money           | integer cents, suffix `_cents`               | `amount_cents`             |
| Timestamp       | `TIMESTAMPTZ`, suffix `_at`                  | `created_at`               |
| Boolean         | prefix `is_` or `has_`                       | `is_public`                |
| Enum-like value | `TEXT` + `CHECK`, lowercase `snake_case`     | `'pending'`, `'approved'`  |
| Time zone       | IANA name as `TEXT`                          | `'America/Denver'`         |
| File in R2      | object key, suffix `_key`, never a public URL| `original_key`             |

The source of truth for the schema is `docs/data-model.md` until migrations exist.

### TypeScript

| Item                              | Convention         | Example               |
|-----------------------------------|--------------------|-----------------------|
| Variables, functions              | `camelCase`        | `createOrder`         |
| Types, interfaces, classes        | `PascalCase`       | `OrderItem`           |
| React components and their files  | `PascalCase`       | `PhotoGrid.tsx`       |
| Other files and folders           | `kebab-case`       | `order-service.ts`    |
| True constants                    | `UPPER_SNAKE_CASE` | `MAX_UPLOAD_BYTES`    |

### HTTP API

- Paths start with `/api/`, use plural nouns in `kebab-case`:
  `GET /api/orders`, `GET /api/orders/:id`, `POST /api/shoot-sessions`.
- JSON fields use `camelCase` (`amountCents`), even though database columns use
  `snake_case`. The data layer converts between them.
- Errors are returned as:

  ```json
  { "error": { "code": "ORDER_NOT_FOUND", "message": "Order 42 does not exist" } }
  ```

  with a matching HTTP status code (400, 401, 403, 404, 500, ...).

## Secrets

- Never commit secrets: passwords, API keys, database URLs, tokens.
- Secrets live in `.env`, which is git-ignored. Keep an up-to-date
  `.env.example` with the variable names and dummy values.
- If a secret is ever committed, rotate it immediately. Deleting the commit is
  not enough, because it stays in the Git history.

## Dependencies

- Discuss before adding a major library (frameworks, ORMs, auth, payment).
- Always commit `package-lock.json` together with `package.json` changes.
- Never commit `node_modules` or build output (`dist`).

## Language

- Code, comments, commit messages, branch names and PR titles: English.
- Design documents and PR discussions: Chinese or English, whichever is clearer.

## Line endings

We develop on both Windows and macOS. `.gitattributes` makes Git store all text
files with LF line endings in the repository, so the same file never shows up
as changed just because of the operating system. Do not change it without
discussion.
