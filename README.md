# ProcessWire AI Workflows

> [!WARNING]  
> This project is experimental and for demonstration purposes only.

This project is a collection of [OpenCode][2] and [Kimi Code CLI][3] Agents, Rules, Skills, and workflows for [ProcessWire CMS][1] development and general web development.

## What is ProcessWire CMS?

ProcessWire is a flexible and powerful content management system (CMS) that provides developers with a robust platform for building custom websites and applications. It emphasizes simplicity, flexibility, and developer-friendly APIs.

## What is OpenCode?

[OpenCode][2] is an open-source AI workflow platform that lets teams compose agents, skills, and automation rules into end-to-end solutions. It focuses on reusable building blocks, transparent governance, and rapid iteration.

## What is Kimi Code CLI?

[Kimi Code CLI][3] is an AI-powered coding assistant that helps developers write, refactor, and understand code. It supports skills (reusable knowledge modules), agents (specialized assistants), and rules (coding guidelines) to enhance development workflows.

## Multi-Tool Support

This project follows the best practice of using an `.agents/` folder as the canonical location for all AI workflows. This folder is natively supported by:

- **OpenCode**, **Kimi Code CLI**, **Amp**, **Codex**, **Cursor**, **Gemini CLI**, **GitHub Copilot** — work out of the box with `.agents/`

To add support for other CLI/IDE tools that don't support `.agents/` natively (Claude, Cline, Goose, Kiro, Kilocode, Roo, Windsurf, etc.), run:

```bash
./create-symlinks.sh
```

This creates symlinks from tool-specific directories (`.claude/`, `.cline/`, etc.) to the `.agents/skills/` folder, allowing the same skills to work across multiple AI coding assistants.

## Agents

_Agents coming soon..._

## Rules

- _soon_

## Skills

### ProcessWire (22 skills)

- [Advanced Modules](./.agents/skills/processwire/advanced-modules/SKILL.md)
- [API](./.agents/skills/processwire/api/SKILL.md)
- [All Hooks Reference](./.agents/skills/processwire/allhooks.md)
- [Best Practices](./.agents/skills/processwire/best-practices/SKILL.md)
- [Custom Page Classes](./.agents/skills/processwire/custom-page-classes/SKILL.md)
- [Field Configuration](./.agents/skills/processwire/field-configuration/SKILL.md)
- [Fields](./.agents/skills/processwire/fields/SKILL.md)
- [FormBuilder](./.agents/skills/processwire/formbuilder/SKILL.md)
- [Getting Started](./.agents/skills/processwire/getting-started/SKILL.md)
- [Hooks](./.agents/skills/processwire/hooks/SKILL.md)
- [InputField Frontend File](./.agents/skills/processwire/inputfield-frontend-file/SKILL.md)
- [LoginRegister Pro](./.agents/skills/processwire/login-register-pro/SKILL.md)
- [Module Checklist](./.agents/skills/processwire/module-checklist/SKILL.md)
- [Modules](./.agents/skills/processwire/modules/SKILL.md)
- [Multi-language](./.agents/skills/processwire/multi-language/SKILL.md)
- [ProCache](./.agents/skills/processwire/procache/SKILL.md)
- [ProMailer](./.agents/skills/processwire/promailer/SKILL.md)
- [RockMigrations](./.agents/skills/processwire/rockmigrations/SKILL.md)
- [Security](./.agents/skills/processwire/security/SKILL.md)
- [Selectors](./.agents/skills/processwire/selectors/SKILL.md)
- [Templates](./.agents/skills/processwire/templates/SKILL.md)
- [User Access](./.agents/skills/processwire/user-access/SKILL.md)

### PHP

- [ProcessWire Standards](./.agents/skills/php/php-processwire-standards/SKILL.md)

### Astro

- [Astro](./home/aca/.agents/skills/astro/SKILL.md)

### Tailwind CSS

- [Tailwind Theme Builder](./home/aca/.agents/skills/tailwind-theme-builder/SKILL.md)
- [Tailwind Design System](./home/aca/.agents/skills/tailwind-design-system/SKILL.md)
- [Tailwind CSS Patterns](./home/aca/.agents/skills/tailwind-css-patterns/SKILL.md)
- [Tailwind Advanced Layouts](./home/aca/.agents/skills/tailwindcss-advanced-layouts/SKILL.md)

### Git

- [Commit Generator](./.agents/skills/git/commit-generator/SKILL.md)

### Markdown

- [GitHub Markdown Alerts](./.agents/skills/markdown/alerts/SKILL.md)

### General

- [Prompt Rephraser](./.agents/skills/general/prompt-rephraser/SKILL.md)
- [Skill Generator](./.agents/skills/general/opencode-skill-generator/SKILL.md)
- [Prompt Optimizer](./.agents/skills/general/prompt-optimizer/SKILL.md)
- [Find Skills](./home/aca/.agents/skills/find-skills/SKILL.md)

---

[1]: https://processwire.com/
[2]: https://opencode.ai/
[3]: https://github.com/moonshot-ai/kimi-cli
