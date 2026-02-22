---
name: processwire-module-checklist
description: Complete checklist for ProcessWire module development covering hooks, configuration, testing, and deployment
compatibility: opencode
metadata:
  domain: processwire
  scope: module-development
---

## What I Do

I provide a comprehensive checklist for ProcessWire module development:

- Pre-development planning and requirements
- Hook setup and lifecycle methods
- Field configuration patterns
- Code quality standards
- Testing strategies
- Deployment and versioning
- Troubleshooting common issues

## When to Use Me

Use this skill when:
- Starting a new module development project
- Reviewing code before commit
- Debugging module issues
- Setting up development environment
- Planning module architecture

---

## Quick Reference: Module Structure

```php
<?php namespace ProcessWire;

class MyModule extends WireData implements Module, ConfigurableModule {

    public static function getModuleInfo() {
        return [
            'title' => 'My Module',
            'summary' => 'Brief description',
            'version' => 100,  // 1.0.0
            'author' => 'Author Name',
            'href' => 'https://example.com',
            'singular' => true,
            'autoload' => true,
            'requires' => 'ProcessWire>=3.0.0',
            'permission' => 'my-module',
            'permissions' => [
                'my-module' => 'Use My Module',
            ],
            'page' => [  // Optional: creates admin page
                'name' => 'my-module',
                'parent' => 'setup',
                'title' => 'My Module',
            ],
            'icon' => 'cog',
        ];
    }

    public function __construct() {
        $this->set('mySetting', 'default');
        parent::__construct();
    }

    public function init() {
        // Early hooks, API may not be ready
        $this->addHookBefore('Pages::save', $this, 'hookPageSave');
    }

    public function ready() {
        // API is ready, most hooks go here
        if($this->page->template == 'admin') {
            // Admin-specific setup
        }
    }

    public function ___hookPageSave(HookEvent $event) {
        $page = $event->arguments(0);
        // Hook logic
    }

    public static function getModuleConfigInputfields(array $data) {
        $inputfields = new InputfieldWrapper();
        // Config fields...
        return $inputfields;
    }
}
```

---

## Phase 1: Pre-Development

### Requirements Checklist

- [ ] Define what "done" looks like
- [ ] List all features to implement
- [ ] Identify affected templates/fields
- [ ] List edge cases to handle
- [ ] Research existing patterns in core modules
- [ ] Check for similar modules in `/site/modules/`

### Module Type Selection

| Need | Module Type | Base Class |
|------|-------------|------------|
| Admin tool with pages | Process | `Process implements Module` |
| Modify behavior | Autoload | `WireData implements Module` |
| Custom field type | Fieldtype | `Fieldtype implements Module` |
| Custom input | Inputfield | `Inputfield implements Module` |
| Text formatting | Textformatter | `Textformatter implements Module` |
| Email sending | WireMail | `WireMail implements Module` |

---

## Phase 2: Hook Setup

### init() vs ready()

```
Need to access $page, $user, $pages?
├─ YES → Use ready()
└─ NO → Use init()
    (for very early hooks like URL routing)
```

### Hook Type Selection

| Need | Hook Type | Example |
|------|-----------|---------|
| Validate/modify arguments | `before` | `Pages::saveReady` |
| Modify return value | `after` | `Pages::saved` |
| Replace behavior | `replace` | `Page::render` |
| Add method to class | `Method` | `Page::myMethod` |
| Add property to class | `Property` | `Page::myProperty` |

### Hook Patterns

```php
// Basic hook
$this->addHookBefore('Pages::save', $this, 'myHook');

// Conditional hook (template-specific)
$this->addHookBefore('Page(template=product)::render', $this, 'myHook');

// With priority (lower = earlier)
$this->addHookBefore('Pages::save', $this, 'myHook', ['priority' => 50]);

// Store hook ID for removal
$hookId = $this->addHookBefore('Pages::save', $this, 'myHook');
$this->removeHook($hookId);  // Remove later
```

### Hookable Methods

```php
// Use ___ prefix for hookable methods
public function ___savePage(HookEvent $event) {
    // Other modules can hook this
}

// Call without ___ to apply hooks
$this->savePage($event);
```

---

## Phase 3: Field Configuration

### Configuration Access Pattern

**ALWAYS use `$field->get('property')` - works everywhere:**

```php
// CORRECT: Works in all contexts
$field = $this->fields->get('my_field');
$value = $field->get('myConfigOption');

// WRONG: Only works with addHookProperty
$inputfield->myConfigOption;  // Don't use this pattern
```

### getConfigInputfields Hook

```php
public function addConfigHook(HookEvent $event) {
    if (!$event->object instanceof InputfieldText) return;
    
    $inputfields = $event->return;
    $field = $this->fields->get($event->object->name);
    
    $f = $this->modules->get('InputfieldCheckbox');
    $f->attr('name', 'myOption');
    $f->label = $this->_('My Option');
    if($field && $field->get('myOption')) {
        $f->attr('checked', 'checked');
    }
    
    $inputfields->append($f);
}
```

### Pattern Mixing Warning

```php
// NEVER mix patterns - causes configuration not saving bugs

// In one place:
$field->get('generateGuid');  // ✓ Correct

// In another place:
$inputfield->generateGuid;    // ✗ WRONG - breaks persistence
```

---

## Phase 4: Code Quality

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes | PascalCase | `MyModule` |
| Methods | camelCase | `savePage()` |
| Variables | camelCase | `$myVariable` |
| Constants | UPPER_CASE | `MAX_RETRIES` |
| Hookable methods | `___` prefix | `___savePage()` |

### PHPDoc Example

```php
/**
 * Generate GUID on page save
 *
 * Hookable method called before page is saved.
 *
 * @param HookEvent $event Hook event object
 * @return void
 */
public function ___generateGuid(HookEvent $event) {
    $page = $event->arguments(0);
}
```

### Input Sanitization

```php
// Text input
$text = $sanitizer->text($input->post->text);

// For selectors (CRITICAL for security)
$search = $sanitizer->selectorValue($input->get->search);
$pages->find("title~=$search");

// Page names
$name = $sanitizer->pageName($input->post->name);

// Integers
$int = (int) $input->post->number;
```

### Exception Types

| Type | Use When |
|------|----------|
| `WireException` | General ProcessWire errors |
| `WirePermissionException` | Access denied |
| `Wire404Exception` | Page not found |
| `WireValidationException` | Validation failures |

---

## Phase 5: Testing

### Manual Testing Checklist

- [ ] Module installs without errors
- [ ] Module uninstall works cleanly
- [ ] Hooks fire at expected times
- [ ] New pages work correctly
- [ ] Existing pages not broken
- [ ] Configuration persists after save
- [ ] No PHP warnings in logs

### Edge Cases Checklist

- [ ] Empty strings handled
- [ ] Null values handled
- [ ] Maximum values enforced
- [ ] Zero values handled
- [ ] Special characters (quotes, unicode)
- [ ] SQL injection attempts blocked

### Performance Testing

```php
// Profile slow operations
$timer = \Debug::timer();
$result = $this->expensiveOperation();
$elapsed = $timer->total();

if($elapsed > 0.2) {
    $this->log->save('performance', "Slow: {$elapsed}s");
}
```

### Common Performance Issues

| Issue | Fix |
|-------|-----|
| N+1 queries | Use caching or preload data |
| Heavy render hooks | Move to save hooks |
| Large result sets | Add `limit()` to selectors |
| No caching | Use `WireCache` for expensive lookups |

---

## Phase 6: Deployment

### Version Numbering

```php
// Semantic versioning in getModuleInfo()
'version' => 102,  // 1.0.2 = 1*100 + 0*10 + 2

// MAJOR.MINOR.PATCH
// 100 = 1.0.0
// 101 = 1.0.1 (bug fix)
// 110 = 1.1.0 (new feature)
// 200 = 2.0.0 (breaking change)
```

### Changelog Format

```markdown
## [1.2.0] - 2024-01-15

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

### Breaking Changes
- Breaking change with migration notes
```

### Pre-Deployment Checklist

- [ ] Version incremented in `getModuleInfo()`
- [ ] CHANGELOG.md updated
- [ ] Full test suite passes
- [ ] Tested on staging environment
- [ ] Database backup ready
- [ ] Rollback plan documented

---

## Phase 7: Troubleshooting

### Configuration Not Saving

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Values don't persist | Pattern mixing | Use `$field->get()` consistently |
| UI doesn't appear | Wrong object type | Check `$event->object` is Inputfield |
| Defaults not loading | Missing name attr | Set `$f->attr('name', 'key')` |

```php
// Debug configuration issues
public function addConfigHook(HookEvent $event) {
    $this->log->save('debug', 'Object: ' . get_class($event->object));
}
```

### Hooks Not Firing

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| No execution | Module not installed | Install via Modules |
| Still no execution | Autoload off | Set `'autoload' => true` |
| Only sometimes | Wrong method | Use `ready()` for API access |

```php
// Debug hook execution
public function myHook(HookEvent $event) {
    $this->log->save('hook-test', 'Hook executed');
}
```

### Wrong Object Context

```php
// Always verify object type
public function myHook(HookEvent $event) {
    $obj = $event->object;
    
    if($obj instanceof Page) {
        // Safe Page operations
    } else if($obj instanceof Field) {
        // Safe Field operations
    } else {
        $this->log->save('error', 'Unexpected: ' . get_class($obj));
        return;
    }
}
```

### Module Not Loading

```bash
# Check PHP syntax
php -l site/modules/MyModule/MyModule.module

# Check error logs
tail -f site/assets/logs/errors.txt
```

| Symptom | Check |
|---------|-------|
| Not in Modules list | Syntax error, wrong namespace |
| Autoload errors | Missing `implements Module` |
| Fatal errors | Missing required keys in getModuleInfo() |

---

## Investigation Protocol

**Before removing or changing code:**

1. **Read entire file** - understand all hook placements
2. **Search all usages**: `grep -rn "pattern" MyModule.module`
3. **Check git history**: `git log -p --all -S "pattern"`
4. **Ask**: "Why was this code added?"
5. **Test change in isolation** first
6. **Update ALL references** consistently
7. **Run full test suite**
8. **Commit with clear message**

---

## Development Environment

### Debug Configuration

```php
// /site/config.php - Development
$config->debug = true;
$config->advanced = true;
$config->chmodDir = '0755';
$config->chmodFile = '0644';
```

### Log Locations

```
/site/assets/logs/errors.txt      # PHP errors
/site/assets/logs/exceptions.txt  # Exceptions
/site/assets/logs/my-module.txt   # Module logs
```

### VS Code Settings

```json
{
  "files.associations": {
    "*.module": "php"
  },
  "intelephense.files.associations": {
    "*.module": "php"
  }
}
```

---

## Cross-References

| For This | Use Skill |
|----------|-----------|
| Hook types and events | `processwire-hooks` |
| Field types and values | `processwire-fields` |
| Module architecture | `processwire-modules` |
| Admin interfaces | `processwire-advanced-modules` |
| Field configuration patterns | `processwire-field-configuration` |
| Selectors for finding pages | `processwire-selectors` |

---

## Key Takeaways

1. **Single pattern for config**: Always use `$field->get('property')`
2. **Hookable methods**: Use `___` prefix, call without `___`
3. **init vs ready**: Use `ready()` when you need `$page`, `$user`, etc.
4. **Sanitize everything**: Especially selector values
5. **Test edge cases**: Empty, null, max, special characters
6. **Version properly**: Semantic versioning, update changelog
7. **Investigate before removing**: Search usages, check history
