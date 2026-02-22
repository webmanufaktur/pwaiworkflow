---
name: processwire-best-practices
description: Best practices for ProcessWire development - coding standards, database handling, module development
license: MIT
compatibility: opencode
metadata:
 -developers
  language: php
  scope: best audience: processwire-practices
  pw-version: "3.0+"
---

## Overview

Best practices for ProcessWire development including code style, database handling, and module development patterns.

## Code Style Guidelines

### General

- **Indentation**: 2 spaces
- **Encoding**: UTF-8 without BOM
- **Line Endings**: LF (Unix)

### Naming Conventions

| Entity          | Format      | Example                    |
| :-------------- | :---------- | :------------------------- |
| **Classes**     | StudlyCaps  | `MyCustomModule`           |
| **Methods**     | camelCase   | `renderPage()`             |
| **Properties**  | camelCase   | `$isLoading`               |
| **Constants**   | UPPER_SNAKE | `DEFAULT_LIMIT`            |
| **Variables**   | camelCase   | `$page`, `$user`           |
| **PW Fields**   | snake_case  | `hero_image`               |
| **Templates**   | kebab-case  | `blog-post`                |

### PHP Syntax

```php
<?php namespace ProcessWire;

if(!defined("PROCESSWIRE")) die();

/**
 * Class description
 *
 * @property string $title
 */
class MyClass extends WireData {
    
    /** @var string */
    protected $name = 'default';
    
    public function __construct() {
        parent::__construct();
    }
    
    public function greet(string $name): string {
        return "Hello, $name";
    }
}
```

### Type Safety & Visibility

- Use type hints and return types
- Declare property types (PHP 7.4+)
- Use PHPDoc `@param` and `@return`
- Always use `public`, `protected`, or `private`

### Namespaces & Locations

- Custom classes: `ProcessWire` namespace
- Page classes: `site/classes/` (e.g., `HomePage.php` for template "home")
- Modules: `site/modules/`

---

## Database Changes

### ALWAYS Use RockMigrations

When you need to create or modify:
- **Fields** - Use `$rm->createField()`
- **Templates** - Use `$rm->createTemplate()`
- **Pages** - Use `$rm->createPage()`
- **Fieldgroups** - Let RockMigrations handle automatically

```php
// CORRECT - Always use RockMigrations
$rm->createField('my_field', 'text', ['label' => 'My Field']);
$rm->createTemplate('my-template', ['label' => 'My Template']);
$rm->createPage(template: 'my-template', parent: '/', title: 'My Page');
```

### NEVER Modify Database Directly

- Never write raw SQL queries to create fields, templates, or pages
- Never use `$db->query()` or similar for schema changes
- Always go through ProcessWire API or RockMigrations
- If you must run SQL for data migration, create a migration file first

### Creating Pages with Data

Use **named parameters** with colon syntax for `createPage()`:

```php
// CORRECT - Named parameters with colon syntax
$rm->createPage(
  template: 'client',
  parent: '/clients/',
  name: 'demo-client',
  title: 'Demo Client',
  data: [
    'client_email' => 'demo@example.com',
    'client_status' => 'active',
  ],
);

// WRONG - Array syntax will fail with "Array to string conversion"
$rm->createPage('/clients/demo-client/', [
  'template' => 'client',
  'title' => 'Demo Client',
]);
```

### Creating Templates with Parent

```php
// Use array syntax for createTemplate with parent
$rm->createTemplate('client', [
  'label' => 'Client',
  'icon' => 'user',
  'parent' => '/clients/',
  'fields' => ['title', 'client_email'],
]);
```

---

## Key API Variables

| Variable   | Class   | Description         |
| :--------- | :------ | :------------------ |
| `$page`    | Page    | Current page        |
| `$pages`   | Pages   | Page management     |
| `$modules` | Modules | Module loader      |
| `$input`   | WireInput | GET/POST handling |
| `$sanitizer` | Sanitizer | Input sanitization |
| `$session` | Session | Session management  |
| `$log`     | WireLog | Logging             |
| `$config`  | Config  | Configuration       |

---

## Security

- **NEVER** trust user input - use `$sanitizer`
- CSRF protection: `$session->CSRF()`
- Production: `$config->debug = false`
- File permissions: config.php: 600, dirs: 755, files: 644

---

## Module Development

### Basic Module Structure

```php
<?php namespace ProcessWire;

class MyModule extends WireData implements Module {

  public static function getModuleInfo() {
    return [
      'title' => 'My Module',
      'version' => 1,
      'summary' => 'Module description',
      'autoload' => true,
      'singular' => true,
    ];
  }

  public function init() {
    // Initialization code
  }

  public function ___install() {
    // Install tasks
  }

  public function ___uninstall() {
    // Uninstall tasks
  }
}
```

---

## Debugging

- Enable: `$config->debug = true` in `site/config.php`
- Log: `$log->save('name', 'message')`
- Debug panel in admin footer

---

## Error Handling

- Use try/catch for operations that may fail
- Return appropriate HTTP status codes
- Log errors: `$log->save('error', $message)`
- Don't expose stack traces in production
