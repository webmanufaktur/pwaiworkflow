---
name: prompt-optimizer
description: Analyze prompts to reduce token usage while maintaining logic
license: MIT
compatibility: opencode
metadata:
  audience: prompt-engineers
  scope: optimization
  triggers: ["OPTIMIZE"]
---

## Overview

Analyzes prompt files to identify redundancy and inefficiency, generating a token-optimized version.

## Workflow

### 1. Trigger

Activate **only** when the user prompt contains **"OPTIMIZE"** and targets a specific file.

### 2. Analysis Strategy

Review the target content for:

- **Verbosity**: Replace prose with direct commands.
- **Redundancy**: Remove implied actions or repeated instructions.
- **Fragmentation**: Merge related steps (e.g., "Check X" + "If X, do Y" → "If X, do Y").

### 3. Optimization Execution

Generate a revised version applying these techniques:

1.  **Condense**: Use imperative verbs and concise natural language.
2.  **Structure**: Use bullet points or tables instead of paragraphs.
3.  **Prune**: Delete non-essential context.

### 4. Output Protocol

1.  **Present Revision**: Show the optimized content clearly.
2.  **Non-Destructive**: Explicitly state these are _suggestions_. Do not modify the file automatically.
3.  **Formats**: If requested, suggest structured alternatives (YAML/JSON) for further density.
