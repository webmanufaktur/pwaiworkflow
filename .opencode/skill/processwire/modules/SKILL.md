---
name: processwire-modules
description: Module types, module development, autoload modules, site modules, third-party modules, LazyCron, and module configuration
compatibility: opencode
metadata:
  domain: processwire
  scope: modules
---

## What I Do

I provide comprehensive guidance for ProcessWire modules:

- Module architecture and types
- Creating custom modules
- Autoload modules and initialization
- Module configuration
- Core vs site modules
- Third-party module installation
- LazyCron for scheduled tasks
- Module dependencies

## When to Use Me

Use this skill when:

- Creating a new module
- Understanding module types (Process, Fieldtype, Inputfield, etc.)
- Setting up autoload modules
- Adding scheduled tasks with LazyCron
- Installing third-party modules
- Making modules configurable

---

## Module Basics

### What Are Modules?

A module is a PHP class that:

- Extends a ProcessWire core class (usually `WireData`)
- Implements the `Module` interface
- Is stored in a `.module` or `.module.php` file

### Core vs Site Modules

| Type             | Location         | Purpose                    |
| ---------------- | ---------------- | -------------------------- |
| **Core modules** | `/wire/modules/` | Included with ProcessWire  |
| **Site modules** | `/site/modules/` | Custom/third-party modules |

### Installing Modules

1. **Upload**: Place module files in `/site/modules/ModuleName/`
2. **Refresh**: Admin > Modules > Refresh
3. **Install**: Click Install button

Or install directly:

- Upload ZIP file in admin
- Provide download URL

---

## Creating a Simple Module

### Minimal Module

`/site/modules/HelloWorld/HelloWorld.module`:

```php
<?php namespace ProcessWire;

class HelloWorld extends WireData implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'Hello World',
            'summary' => 'A simple example module',
            'version' => 1,
        ];
    }

    public function hello() {
        return "Hello, " . $this->user->name;
    }
}
```

### Using the Module

```php
// Best Practice: Erst prüfen, dann holen (get() installiert fehlende Module automatisch!)
$module = $modules->isInstalled('HelloWorld') ? $modules->get('HelloWorld') : null;
if($module) echo $module->hello();
```

---

## Module Info

Provide module information via `getModuleInfo()`:

```php
public static function getModuleInfo() {
    return [
        'title' => 'My Module',
        'summary' => 'Short description of what it does',
        'version' => 100,  // 1.0.0
        'author' => 'Your Name',
        'href' => 'https://example.com/module-docs',
        'autoload' => false,
        'singular' => true,
        'permanent' => false,
        'requires' => ['ProcessWire>=3.0.0'],
        'installs' => ['OtherModule'],
        'permission' => 'some-permission',
        'icon' => 'plug',
    ];
}
```

### Key Properties

| Property     | Type        | Description                  |
| ------------ | ----------- | ---------------------------- |
| `title`      | string      | Display name                 |
| `summary`    | string      | Short description            |
| `version`    | int         | Version number (100 = 1.0.0) |
| `autoload`   | bool/string | Auto-load on boot            |
| `singular`   | bool        | Only one instance allowed    |
| `requires`   | array       | Dependencies                 |
| `installs`   | array       | Modules to install with this |
| `permission` | string      | Required permission          |
| `icon`       | string      | FontAwesome icon name        |

### Alternative: Info File

Create `HelloWorld.info.php`:

```php
<?php namespace ProcessWire;
$info = [
    'title' => 'Hello World',
    'summary' => 'A simple example module',
    'version' => 1,
];
```

Or `HelloWorld.info.json`:

```json
{
  "title": "Hello World",
  "summary": "A simple example module",
  "version": 1
}
```

---

## Autoload Modules

Modules that load automatically when ProcessWire boots.

### Enable Autoload

```php
public static function getModuleInfo() {
    return [
        'title' => 'My Autoload Module',
        'version' => 1,
        'autoload' => true,
    ];
}
```

### Conditional Autoload

```php
// Only autoload in admin
'autoload' => 'template=admin'

// Only on front-end
'autoload' => 'template!=admin'

// Custom condition
'autoload' => 'page.id>0'
```

### Initialization Methods

```php
class MyModule extends WireData implements Module {

    /**
     * Called when module is loaded (for autoload modules)
     */
    public function init() {
        // Early initialization
        // API may not be fully ready
    }

    /**
     * Called when API is ready (for autoload modules)
     */
    public function ready() {
        // API is ready, hooks can be added here
        if($this->page->template == 'admin') {
            $this->message("Welcome to the admin!");
        }
    }
}
```

### Adding Hooks in Autoload Modules

```php
public function ready() {
    // Hook after page render
    $this->addHookAfter('Page::render', function($event) {
        $event->return .= '<!-- Rendered by MyModule -->';
    });

    // Hook before page save
    $this->addHookBefore('Pages::save', function($event) {
        $page = $event->arguments(0);
        // Do something before save
    });
}
```

---

## Module Types

### Process Modules

Admin applications with their own pages:

```php
class ProcessMyApp extends Process implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'My Admin App',
            'version' => 1,
            'permission' => 'my-app',
            'page' => [
                'name' => 'my-app',
                'parent' => 'setup',
                'title' => 'My App',
            ],
        ];
    }

    public function execute() {
        // Default view
        return "<h1>My App</h1>";
    }

    public function executeEdit() {
        // /admin/setup/my-app/edit/
        return "<h1>Edit View</h1>";
    }
}
```

### Fieldtype Modules

Define new field types:

```php
class FieldtypeMyType extends Fieldtype implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'My Field Type',
            'version' => 1,
        ];
    }

    public function sanitizeValue(Page $page, Field $field, $value) {
        // Sanitize the value
        return $value;
    }

    public function getInputfield(Page $page, Field $field) {
        $inputfield = $this->modules->get('InputfieldText');
        return $inputfield;
    }
}
```

### Inputfield Modules

Define new input types for the admin:

```php
class InputfieldMyInput extends Inputfield implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'My Input',
            'version' => 1,
        ];
    }

    public function renderReady(Inputfield $parent = null, $renderValueMode = false) {
        // Called before render
        return parent::renderReady($parent, $renderValueMode);
    }

    public function ___render() {
        return "<input type='text' name='{$this->name}' value='{$this->value}'>";
    }

    public function ___processInput(WireInputData $input) {
        $this->value = $input->{$this->name};
        return $this;
    }
}
```

### Textformatter Modules

Format text field output:

```php
class TextformatterMyFormatter extends Textformatter implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'My Formatter',
            'version' => 1,
        ];
    }

    public function format(&$str) {
        // Modify $str in place
        $str = strtoupper($str);
    }
}
```

### WireMail Modules

Custom email sending:

```php
class WireMailMyProvider extends WireMail implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'My Mail Provider',
            'version' => 1,
        ];
    }

    public function ___send() {
        // Send email via custom provider
        return 1; // Number of emails sent
    }
}
```

---

## Configurable Modules

### Simple Configuration

```php
class MyModule extends WireData implements Module, ConfigurableModule {

    public static function getModuleInfo() {
        return [
            'title' => 'Configurable Module',
            'version' => 1,
        ];
    }

    public function __construct() {
        // Set defaults
        $this->apiKey = '';
        $this->enabled = true;
    }

    public static function getModuleConfigInputfields(array $data) {
        $inputfields = new InputfieldWrapper();

        $f = wire('modules')->get('InputfieldText');
        $f->name = 'apiKey';
        $f->label = 'API Key';
        $f->value = isset($data['apiKey']) ? $data['apiKey'] : '';
        $inputfields->add($f);

        $f = wire('modules')->get('InputfieldCheckbox');
        $f->name = 'enabled';
        $f->label = 'Enable Feature';
        $f->checked = isset($data['enabled']) ? $data['enabled'] : false;
        $inputfields->add($f);

        return $inputfields;
    }
}
```

### Accessing Config Values

```php
// In module methods
$apiKey = $this->apiKey;

// From outside
$module = $modules->get('MyModule');
$apiKey = $module->apiKey;
```

---

## LazyCron (Scheduled Tasks)

Execute tasks at intervals without system cron.

### Install LazyCron

Admin > Modules > Core > LazyCron > Install

### Available Intervals

- `every30Seconds`, `everyMinute`
- `every2Minutes`, `every5Minutes`, `every10Minutes`
- `every15Minutes`, `every30Minutes`, `every45Minutes`
- `everyHour`, `every2Hours`, `every4Hours`, `every6Hours`, `every12Hours`
- `everyDay`, `every2Days`, `every4Days`
- `everyWeek`, `every2Weeks`, `every4Weeks`

### Using in Modules

```php
class MyModule extends WireData implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'Scheduled Tasks',
            'version' => 1,
            'autoload' => true,
            'requires' => ['LazyCron'],
        ];
    }

    public function init() {
        $this->addHook('LazyCron::everyHour', $this, 'hourlyTask');
        $this->addHook('LazyCron::everyDay', $this, 'dailyTask');
    }

    public function hourlyTask(HookEvent $e) {
        $seconds = $e->arguments(0);  // Actual elapsed seconds
        // Do hourly work
        $this->log->save('my-module', 'Hourly task executed');
    }

    public function dailyTask(HookEvent $e) {
        // Do daily work
    }
}
```

### Procedural Usage

```php
// In template or _init.php
wire()->addHook('LazyCron::every30Minutes', function($e) {
    // Task to run every 30 minutes
    wire('log')->save('cron', 'Task executed');
});
```

### Making It Accurate

LazyCron is triggered by page views. For accurate timing, set up a system cron:

```bash
# Run every minute
* * * * * wget --quiet --no-cache -O - http://yoursite.com > /dev/null
```

---

## Module Dependencies

### Requiring Other Modules

```php
public static function getModuleInfo() {
    return [
        'title' => 'My Module',
        'version' => 1,
        'requires' => [
            'ProcessWire>=3.0.0',
            'SomeOtherModule',
            'AnotherModule>=2.0.0',
        ],
    ];
}
```

### Installing Other Modules

```php
public static function getModuleInfo() {
    return [
        'title' => 'My Module',
        'version' => 1,
        'installs' => ['HelperModule', 'AnotherHelper'],
    ];
}
```

---

## Common Patterns

### Safely Accessing Modules

`$modules->get()` installs missing modules automatically. Check first:

```php
// Best Practice: Check before get
$module = $modules->isInstalled('ModuleName') 
    ? $modules->get('ModuleName') 
    : null;

if($module) {
    // Module is available
} else {
    // Module not installed - graceful degradation
}

// Alternative (PW 3.0.184+): Prevent auto-install
$module = $modules->get('ModuleName', ['noInstall' => true]);
```

### Accessing API in Modules

```php
class MyModule extends WireData implements Module {

    public function doSomething() {
        // Access API variables via $this
        $page = $this->page;
        $pages = $this->pages;
        $user = $this->user;
        $config = $this->config;
        $sanitizer = $this->sanitizer;

        // Or via wire()
        $pages = $this->wire('pages');
    }
}
```

### Adding Methods to Existing Classes

```php
public function ready() {
    // Add summarize() method to all Page objects
    $this->addHook('Page::summarize', function($event) {
        $page = $event->object;
        $maxLen = $event->arguments(0) ?: 200;
        $event->return = $this->sanitizer->truncate($page->body, $maxLen);
    });
}

// Usage in templates:
echo $page->summarize(150);
```

### Admin Messages and Errors

```php
// Show message to user
$this->message("Operation completed successfully");

// Show warning
$this->warning("Something might be wrong");

// Show error
$this->error("An error occurred");
```

### Logging

```php
// Log to custom log file
$this->log->save('my-module', 'Something happened');

// Log error
$this->log->error('my-module', 'An error occurred');
```

---

## Module File Structure

```
/site/modules/MyModule/
├── MyModule.module           # Main module file
├── MyModule.info.php         # Optional: module info
├── MyModule.config.php       # Optional: config fields
├── README.md                 # Documentation
├── CHANGELOG.md              # Version history
└── assets/                   # Optional: CSS/JS files
    ├── MyModule.css
    └── MyModule.js
```

---

## Pitfalls / Gotchas

1. **$modules->get() auto-installs**: `get()` automatically installs missing modules. Use `isInstalled()` first or `['noInstall' => true]` option (PW 3.0.184+).

2. **Refresh after changes**: Always Modules > Refresh after modifying `getModuleInfo()`.

3. **Naming conventions**: Module class name must match filename (e.g., `HelloWorld` class in `HelloWorld.module`).

4. **Namespace required**: Always use `namespace ProcessWire;` in PW 3.x.

5. **Singular modules**: If `singular => true`, only one instance exists. Access via `$modules->get()`.

6. **init() vs ready()**:
   - `init()`: Called early, API may not be ready
   - `ready()`: Called when API is ready, safe for hooks

7. **Autoload performance**: Only autoload if necessary. Use conditional autoload when possible.

8. **LazyCron timing**: Depends on page views. Low-traffic sites may have delayed execution.

9. **Hook method prefixes**: Use `___` (three underscores) to make methods hookable.

10. **Version numbering**: Use integers (100 = 1.0.0, 101 = 1.0.1, 200 = 2.0.0).

11. **Uninstall cleanup**: Implement `___uninstall()` to clean up module data/pages.
