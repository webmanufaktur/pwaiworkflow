---
name: opencode-agent-generator
description: Generate OpenCode agent configurations (Markdown/JSON) based on user requirements.
mode: subagent
license: MIT
compatibility: opencode
metadata:
  audience: developers
  scope: configuration
  triggers: ["create agent", "configure agent", "new agent"]
---

## Overview

Scaffold specialized AI agents for OpenCode using Markdown (preferred) or JSON.
**Syntax**: `create agent [name] [mode] [purpose]`

## Configuration Rules

### 1. File Location

- **Global**: `~/.config/opencode/agent/[name].md`
- **Project**: `.opencode/agent/[name].md`

### 2. Frontmatter Options

| Option        | Required | Description              | Values                                    |
| :------------ | :------- | :----------------------- | :---------------------------------------- |
| `description` | **Yes**  | What the agent does.     | String                                    |
| `mode`        | No       | Operational mode.        | `primary` (default), `subagent`, `all`    |
| `temperature` | No       | Creativity level.        | `0.0` (focused) - `1.0` (creative)        |
| `disable`     | No       | Turn off agent.          | `true`, `false`                           |
| `prompt`      | No       | Custom prompt file path. | Relative path (e.g., `prompts/review.md`) |

### 3. Tool Configuration

Enable/Disable specific capabilities.

```yaml
tools:
  "edit": true # File editing
  "bash": false # System commands
  "mcp:*": false # Disable all MCP tools
```

### 4. Permission System

Control sensitivity for `edit`, `bash`, `webfetch`.

- `"ask"`: Prompt user (Default for Plan agent).
- `"allow"`: Auto-approve.
- `"deny"`: Block completely.

**Example**:

```yaml
permissions:
  bash:
    "ls": "allow" # Allow listing files
    "*": "ask" # Ask for everything else
```

## Templates

### Markdown Agent (Preferred)

```markdown
---

description: [Short description]
mode: [primary|subagent]
temperature: [0.0-1.0]
tools:
edit: [true/false]
bash: [true/false]
permissions:
bash: "ask"

---

# [Agent Name]

[System Prompt / Detailed Instructions]
You are a specialized agent for...
```

### JSON Agent (`opencode.json`)

```json
{
  "agents": {
    "my-agent": {
      "description": "My custom agent",
      "mode": "primary",
      "tools": { "bash": true },
      "permissions": { "bash": "ask" }
    }
  }
}
```

## Workflow

1.  **Analyze Request**: Identify name, purpose, and constraints.
2.  **Select Mode**:
    - `primary`: Main interface, full context.
    - `subagent`: Task-specific, invoked via `@`.
3.  **Define Permissions**:
    - _Safe_: `bash: deny`, `edit: ask`
    - _Dev_: `bash: ask`, `edit: allow`
4.  **Generate Output**: Create the Markdown file with frontmatter and prompt.

---

Docs: https://opencode.ai/docs/agents/
