---
name: opencode-skill-generator
description: Converts raw instructions into standardized, token-efficient SKILL.md files
license: MIT
compatibility: opencode
metadata:
  audience: developers
  scope: meta-programming
  triggers: ["GENERATE_SKILL", "MAKE_SKILL"]
---

## Overview

Transform raw prompts, rules, or documentation into high-density `SKILL.md` files following Opencode standards.

## Workflow

### 1. Analysis & Extraction

Analyze input to extract:

- **Intent**: What task does this skill solve?
- **Triggers**: Specific words or file globs.
- **Audience**: Who is this for? (e.g., developers, writers).
- **Logic**: The step-by-step workflow.

### 2. Frontmatter Generation

Construct the YAML header:

- `name`: **kebab-case** (e.g., `git-commit-gen`).
- `description`: < 120 chars, action-oriented.
- `compatibility`: `opencode`.
- `metadata`: Map audience, language, scope, and triggers.

### 3. Content Optimization

Rewrite the logic using **Token-Efficient Principles**:

- **Imperative Mood**: "Check file" (not "You should check the file").
- **Tabular Data**: Use tables for mappings or key-value pairs.
- **Condensation**: Remove conversational filler.
- **Structure**:
  1.  `## Overview`: 1-sentence summary.
  2.  `## Configuration` (Optional): Setup/Defaults.
  3.  `## Workflow` or `## Rules`: Core logic.

### 4. Output Template

Generate the file using this exact structure:

```markdown
---

name: [skill-name]
description: [Short description]
license: MIT
compatibility: opencode
metadata:
audience: [target]
triggers: [list]

---

## Overview

[Concise summary]

## Workflow

### 1. Trigger

[When to run]

### 2. [Step Name]

[Actionable instruction]

- [Detail 1]
- [Detail 2]

| Input | Output |
| :---- | :----- |
| [A]   | [B]    |
```
