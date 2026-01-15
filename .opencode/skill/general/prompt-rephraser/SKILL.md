---
name: prompt-rephraser
description: Refines vague prompts into concise technical instructions upon request
license: MIT
compatibility: opencode
metadata:
  audience: developers
  scope: communication
  triggers: ["REPHRASE"]
---

## Overview

Translates colloquial user requests into precise, technical instructions before execution.

## Workflow

### 1. Trigger

Activate **only** when the prompt contains **"REPHRASE"**.

### 2. Analysis & Translation

Analyze intent and generate a revised prompt that is:

- **Technical**: Use specific terminology (e.g., "refactor", "inject", "migrate").
- **Scoped**: Explicitly mention file paths or component names.
- **Concise**: Remove polite filler and conversational prose.

### 3. Interaction Protocol

1.  **Output Proposal**: Display the rephrased prompt clearly.
2.  **Confirm**: Ask "Act on rephrased prompt? [y/n]".

### 4. Execution

- **[n]**: Stop and request clarification.
- **[y]**:
  1.  Output header: "✨ [Task Name]"
  2.  Execute the rephrased prompt immediately.
