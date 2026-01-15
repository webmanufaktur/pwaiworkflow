---
name: php-processwire-standards
description: Coding standards, security, and best practices for ProcessWire PHP development
license: MIT
compatibility: opencode
metadata:
  audience: developers
  language: php
  framework: processwire
  triggers:
    type: glob
    globs: "*.php"
---

## Code Style & Conventions

### General Setup

- **Version**: PHP 8.2+
- **Indentation**: 2 spaces
- **Encoding**: UTF-8 without BOM
- **Namespace**: `ProcessWire`
- **Pattern**: Functional/Declarative over duplication.

### Naming Conventions

| Entity        | Format                      | Example                     |
| :------------ | :-------------------------- | :-------------------------- |
| **Classes**   | StudlyCaps                  | `MyCustomModule`            |
| **Methods**   | camelCase                   | `renderPage()`              |
| **Constants** | camelCase                   | `defaultConfig`             |
| **Variables** | camelCase (Auxiliary verbs) | `isLoading`, `hasError`     |
| **PW Fields** | snake_case                  | `hero_image`, `body_text`   |
| **Templates** | kebab-case                  | `blog-post`, `contact-form` |

## Quality & Architecture

- **Type Safety**: Use type hints and return types wherever possible.
- **Visibility**: Explicitly declare `public`, `protected`, or `private`.
- **Hooks**: Design for extensibility; use hookable methods where appropriate.
- **Docs**: Use PHPDoc for inline documentation.

## Security & Data

- **Sanitization**: **NEVER** trust input. Use `$sanitizer` for all incoming data.
- **Auth**: Implement proper authentication and CSRF protection.
- **Sensitivity**: Never expose sensitive data.

## Error Handling

- **Logging**: Use `$log->save('name', 'msg')` (ProcessWire Logger).
- **Exceptions**: Implement proper try/catch blocks.
- **Response**: Return appropriate HTTP status codes and custom error messages.

## Workflow

- **VCS**: Git with proper code reviews.
- **Versioning**: Semantic Versioning (SemVer).
- **Maintenance**: Maintain active changelogs and test in multiple environments.
