---
name: commit-generator
description: Analyzes git status, groups changes logically, and generates conventional commit messages
license: MIT
compatibility: opencode
metadata:
  audience: developers
  language: bash
  scope: version-control
  triggers: ["COMMIT", "generate commit message"]
---

## Overview

Automates the creation of semantic git commits by analyzing file changes, grouping them by context, and applying conventional commit standards.

## Workflow

### 1. Trigger Check

Activate **only** if the user request contains:

- "generate commit message"
- "COMMIT"

### 2. Analysis & Grouping

Inspect repo state via `git diff --cached --name-status` and `git status --porcelain`. Group files by logic:

| Path/Type         | Category | Grouping Logic            |
| :---------------- | :------- | :------------------------ |
| `src/components/` | UI       | Feature/Component name    |
| `src/pages/`      | Pages    | Route name                |
| `src/content/`    | Content  | Collection type           |
| `src/styles/`     | Styles   | Global or Tailwind config |
| `public/`         | Assets   | Static assets             |
| `*.config.*`      | Config   | Configuration updates     |
| `package*.json`   | Deps     | Package management        |
| `README.md`       | Docs     | Documentation             |

### 3. Message Formatting

Format: `type(scope): subject` (lowercase, concise).

| Prefix      | Use Case       | Example                               |
| :---------- | :------------- | :------------------------------------ |
| `feat:`     | New features   | `feat(header): add mobile navigation` |
| `fix:`      | Bug fixes      | `fix(auth): resolve login timeout`    |
| `perf:`     | Performance    | `perf(image): optimize hero banner`   |
| `docs:`     | Documentation  | `docs: update installation guide`     |
| `style:`    | Formatting     | `style: fix indentation`              |
| `refactor:` | Code structure | `refactor: simplify data fetching`    |
| `test:`     | Tests          | `test: add unit tests for user`       |
| `chore:`    | Maintenance    | `chore: update dependencies`          |

### 4. Interactive Confirmation

Present the plan to the user:

> **Proposed Commits:**
>
> 1. `feat(blog): add new post layout`
>    - `src/pages/blog/[slug].astro`
>    - `src/styles/blog.css`
> 2. `chore: update tailwind`
>    - `package.json`
>    - `pnpm-lock.yaml`
>
> "Would you like to proceed with these commits? [y/n/edit]"

### 5. Execution Strategy

Handle user response:

- **[n]**: Stop and ask for clarification.
- **[edit]**: Allow modification of groups or messages.
- **[y]**: Execute sequentially for each group:
  1.  `git add [specific_files]`
  2.  `git commit -m "[message]"`
  3.  Output: "✨ Committed: [message]"

**Final Output**: "🎉 All changes committed successfully."
