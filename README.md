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

### ProcessWire

- [Advanced Modules](./.agents/skill/processwire/advanced-modules/SKILL.md)
- [API](./.agents/skill/processwire/api/SKILL.md)
- [Custom Page Classes](./.agents/skill/processwire/custom-page-classes/SKILL.md)
- [Field Configuration](./.agents/skill/processwire/field-configuration/SKILL.md)
- [Fields](./.agents/skill/processwire/fields/SKILL.md)
- [Getting Started](./.agents/skill/processwire/getting-started/SKILL.md)
- [Hooks](./.agents/skill/processwire/hooks/SKILL.md)
- [Module Checklist](./.agents/skill/processwire/module-checklist/SKILL.md)
- [Modules](./.agents/skill/processwire/modules/SKILL.md)
- [Multi-language](./.agents/skill/processwire/multi-language/SKILL.md)
- [RockMigrations](./.agents/skill/processwire/rockmigrations/SKILL.md)
- [Security](./.agents/skill/processwire/security/SKILL.md)
- [Selectors](./.agents/skill/processwire/selectors/SKILL.md)
- [Templates](./.agents/skill/processwire/templates/SKILL.md)
- [User Access](./.agents/skill/processwire/user-access/SKILL.md)

### PHP

- [ProcessWire Standards](./.agents/skill/php/php-processwire-standards/SKILL.md)

### Git

- [Commit Message Generator](./.agents/skill/git/commit-generator/SKILL.md)

### Markdown

- [GitHub Markdown Alerts](./.agents/skill/markdown/alerts/SKILL.md)

### General

- [Prompt Rephraser](./.agents/skill/general/prompt-rephraser/SKILL.md)
- [Skill Generator](./.agents/skill/general/opencode-skill-generator/SKILL.md)
- [Prompt Optimizer](./.agents/skill/general/prompt-optimizer/SKILL.md)

---

[1]: https://processwire.com/
[2]: https://opencode.ai/
[3]: https://github.com/moonshot-ai/kimi-cli
