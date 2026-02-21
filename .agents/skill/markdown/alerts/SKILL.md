---
name: alerts
description: Create GitHub-flavored markdown alerts (callouts) for READMEs and issues
license: MIT
compatibility: opencode
metadata:
  audience: developers
  language: markdown
  scope: documentation
  platform: github
---

## Overview

Use special blockquote syntax to render colored alert boxes in GitHub Markdown.
**Syntax**: `> [!TYPE]` followed by the alert content.

## Alert Types

### Note (Blue)

Highlights information users should see even when skimming.

```markdown
> [!NOTE]
> Highlights information that users should take into account, even when skimming.
```

### Tip (Green)

Optional advice to help users be more successful.

```markdown
> [!TIP]
> Optional information to help a user be more successful.
```

### Important (Purple)

Crucial information necessary for success.

```markdown
> [!IMPORTANT]
> Crucial information necessary for users to succeed.
```

### Warning (Yellow)

Critical content demanding attention due to potential risks.

```markdown
> [!WARNING]
> Critical content demanding immediate user attention due to potential risks.
```

### Caution (Red)

Warning about negative consequences of an action.

```markdown
> [!CAUTION]
> Negative potential consequences of an action.
```

## Best Practices

1.  **Case Sensitivity**: The type identifier (e.g., `[!NOTE]`) is case-insensitive, but uppercase is standard convention.
2.  **Spacing**: A space is required after the `>` symbol.
3.  **Multiline**: All lines of the alert must start with `>`.
4.  **Nesting**: Standard markdown (bold, code blocks, lists) works inside the alert body.

### Example: Multiline with Formatting

```markdown
> [!TIP]
> Use the `--dry-run` flag to test without changes.
>
> 1. Open terminal
> 2. Run `npm run deploy --dry-run`
```
