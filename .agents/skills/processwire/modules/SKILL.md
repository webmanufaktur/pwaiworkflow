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
| `permissions`| array       | Multiple permissions to create |
| `icon`       | string      | FontAwesome icon name        |

### Custom Permissions

Define multiple permissions that are auto-created on install:

```php
public static function getModuleInfo() {
    return [
        'title' => 'My Module',
        'permission' => 'my-module-view',  // Main permission
        'permissions' => [
            'my-module-view' => 'View items',
            'my-module-edit' => 'Edit items',
            'my-module-admin' => 'Administer module',
        ],
    ];
}

// Check permissions
if($user->hasPermission('my-module-edit')) { /* ... */ }
```

### Sub-Module Installer

Install helper modules automatically:

```php
public static function getModuleInfo() {
    return [
        'title' => 'My Suite',
        'installs' => ['MySuiteWorker', 'MySuiteCron'],
    ];
}

// Sub-module prevents standalone install
class MySuiteWorker extends WireData implements Module {
    public static function getModuleInfo() {
        return [
            'title' => 'Suite Worker',
            'autoload' => true,
            'requires' => 'MySuite',  // Requires parent
        ];
    }
}
```

### Alternative: Info File

Create `HelloWorld.info.php` (supports translatable strings):

```php
<?php namespace ProcessWire;
$info = [
    'title' => __('Hello World', __FILE__),
    'summary' => __('A simple example module', __FILE__),
    'version' => 1,
    'permission' => 'hello-world',
    'permissions' => [
        'hello-world' => __('Use Hello World', __FILE__),
    ],
    'page' => [
        'name' => 'hello-world',
        'parent' => 'setup',
        'title' => __('Hello World', __FILE__),
    ],
    'nav' => [
        ['url' => './', 'label' => __('List', __FILE__), 'icon' => 'list'],
        ['url' => 'add/', 'label' => __('Add New', __FILE__), 'icon' => 'plus'],
    ],
];
```

Load in module init:

```php
public function init() {
    parent::init();
    include(__DIR__ . '/MyModule.info.php');
    // $info now available
}
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

### Behavior-Modifying Hook Modules

Create modules that modify core behavior by hooking:

```php
class PageEditPerUser extends WireData implements Module, ConfigurableModule {

    public static function getModuleInfo() {
        return [
            'title' => 'Page Edit Per User',
            'version' => 1,
            'autoload' => true,  // Required for hooks
            'singular' => true,
        ];
    }

    public function init() {
        // Hook into Page::editable to modify access
        $this->addHookAfter('Page::editable', $this, 'hookPageEditable');
        $this->addHookAfter('Page::viewable', $this, 'hookPageViewable');
    }

    public function hookPageEditable($event) {
        if($event->return) return; // Already editable
        
        // Custom logic - check if user has access
        if($this->user->hasPermission('page-edit')) {
            $event->return = $this->user->editable_pages->has($event->object);
        }
    }
}
```

---

## Module Types

### WireMail Modules

Custom email sending with fallback support:

```php
class WireMailMyProvider extends WireMail implements Module, ConfigurableModule {

    public static function getModuleInfo() {
        return [
            'title' => 'My Mail Provider',
            'version' => 1,
        ];
    }

    public function ___send() {
        $numSent = 0;
        foreach($this->mail['to'] as $toEmail) {
            // $this->mail contains: to, toName, from, fromName, subject, body, bodyHTML, headers, attachments
            $numSent += $this->sendTo($toEmail);
        }
        return $numSent;
    }
}
```

Access email properties via `$this->mail['subject']`, `$this->mail['body']`, etc.

### Process Modules

Admin applications with their own pages. Process modules are the primary way to add custom admin tools.

#### Basic Structure

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
        // Default view: /admin/setup/my-app/
        return "<h1>My App</h1>";
    }

    public function executeEdit() {
        // /admin/setup/my-app/edit/
        return "<h1>Edit View</h1>";
    }
}
```

#### Auto-Created Admin Pages

The `page` property in `getModuleInfo()` tells ProcessWire to automatically create an admin page on install:

```php
'page' => [
    'name' => 'my-tool',           // URL segment
    'parent' => 'setup',           // Parent: 'setup', 'access', or page ID
    'title' => 'My Tool',          // Page title (shown in nav)
]
```

**How it works:**
1. On install, ProcessWire creates a page under the specified parent
2. The page's `process` field is set to this module
3. On uninstall, the page is automatically deleted
4. URL segments map to `execute*()` methods

**Parent options:**
| Parent | Location |
|--------|----------|
| `'setup'` | Admin > Setup |
| `'access'` | Admin > Access |
| `'root'` or `null` | Direct child of admin root |
| Page ID | Specific parent page |

#### Permissions and Access Control

The `permission` property controls who can access the admin page:

```php
public static function getModuleInfo() {
    return [
        'title' => 'Database Backups',
        'permission' => 'db-backup',  // Required permission to access
        'permissions' => [
            'db-backup' => 'Manage database backups (superuser only)',
            'db-restore' => 'Restore database from backup',
        ],
    ];
}
```

**Access flow:**
1. User must have the specified `permission` on one of their roles
2. If no `permission` specified, only superusers can access
3. The `permissions` array creates new permissions on install
4. Add permissions to roles in Admin > Access > Roles

#### Navigation Tabs

Add navigation tabs with the `nav` property:

```php
public static function getModuleInfo() {
    return [
        'title' => 'Database Backups',
        'page' => [
            'name' => 'db-backups',
            'parent' => 'setup',
            'title' => 'DB Backups',
        ],
        'nav' => [
            ['url' => './', 'label' => 'View', 'icon' => 'list'],
            ['url' => 'backup/', 'label' => 'Backup', 'icon' => 'plus-circle'],
            ['url' => 'upload/', 'label' => 'Upload', 'icon' => 'cloud-upload'],
        ],
    ];
}
```

**URL mapping:**
| Nav URL | Method | Full URL |
|---------|--------|----------|
| `'./'` | `execute()` | `/admin/setup/db-backups/` |
| `'backup/'` | `executeBackup()` | `/admin/setup/db-backups/backup/` |
| `'upload/'` | `executeUpload()` | `/admin/setup/db-backups/upload/` |

#### Complete Process Module Example

```php
<?php namespace ProcessWire;

class ProcessMyTool extends Process implements Module {

    public static function getModuleInfo() {
        return [
            'title' => 'My Admin Tool',
            'summary' => 'A complete admin tool example',
            'version' => 1,
            'author' => 'Your Name',
            'icon' => 'cog',
            'requires' => 'ProcessWire>=3.0.0',
            'permission' => 'my-tool',
            'permissions' => [
                'my-tool' => 'Use My Tool',
                'my-tool-admin' => 'Administer My Tool',
            ],
            'page' => [
                'name' => 'my-tool',
                'parent' => 'setup',
                'title' => 'My Tool',
            ],
            'nav' => [
                ['url' => './', 'label' => 'List', 'icon' => 'list'],
                ['url' => 'add/', 'label' => 'Add New', 'icon' => 'plus'],
            ],
        ];
    }

    public function ___execute() {
        // Main list view
        $this->headline('My Tool');
        
        /** @var MarkupAdminDataTable $table */
        $table = $this->modules->get('MarkupAdminDataTable');
        $table->headerRow(['Name', 'Status', 'Actions']);
        
        // Add rows...
        
        return $table->render();
    }

    public function ___executeAdd() {
        // Add new item
        $this->headline('Add New Item');
        $this->breadcrumb('../', 'My Tool');
        
        /** @var InputfieldForm $form */
        $form = $this->modules->get('InputfieldForm');
        
        $f = $this->modules->get('InputfieldText');
        $f->name = 'name';
        $f->label = 'Name';
        $f->required = true;
        $form->add($f);
        
        $f = $this->modules->get('InputfieldSubmit');
        $f->value = 'Save';
        $form->add($f);
        
        if($this->input->post('submit_save')) {
            $form->processInput($this->input->post);
            if(!$form->getErrors()) {
                // Save data...
                $this->message('Saved successfully');
                $this->session->redirect('../');
            }
        }
        
        return $form->render();
    }
}
```

#### Module Config vs Admin Pages

Two ways to add settings:

**1. Module Configuration (ConfigurableModule)**
- Settings in Modules > Configure
- For global module settings
- User must have `module-admin` permission

```php
class MyModule extends WireData implements Module, ConfigurableModule {
    public static function getModuleConfigInputfields(array $data) {
        $inputfields = new InputfieldWrapper();
        // Add config fields...
        return $inputfields;
    }
}
```

**2. Process Module Admin Page**
- Full admin page with custom URL
- For tools that manage data
- Custom permissions per module

```php
class ProcessMyTool extends Process implements Module {
    // Has 'page' property in getModuleInfo()
}
```

Some modules combine both (e.g., ProcessHannaCode has admin page AND module config for editor settings).

---

## Modules That Modify User Access

Some modules add custom fields to the user template or modify access behavior.

### Adding Fields to User Template

Add fields on install, remove on uninstall:

```php
class PageEditPerUser extends WireData implements Module, ConfigurableModule {

    public function ___install() {
        // Create a new field
        $field = new Field();
        $field->name = 'editable_pages';
        $field->label = 'Pages user may edit';
        $field->type = $this->modules->get('FieldtypePage');
        $field->inputfield = 'InputfieldPageListSelectMultiple';
        $field->description = 'Select pages this user can edit.';
        $field->save();

        // Add to user template's fieldgroup
        $fieldgroup = $this->fieldgroups->get('user');
        $fieldgroup->add($field);
        $fieldgroup->save();

        $this->message("Added field 'editable_pages' to user template.");
    }

    public function ___uninstall() {
        // Remove field from user template
        $field = $this->fields->get('editable_pages');
        $fieldgroup = $this->fieldgroups->get('user');
        
        if($field && $fieldgroup) {
            $fieldgroup->remove($field);
            $fieldgroup->save();
        }
        
        // Delete the field
        if($field) {
            $this->fields->delete($field);
        }
        
        $this->message("Removed field 'editable_pages'");
    }
}
```

### Hooking Access Methods

Modify `Page::editable` or `Page::viewable` to implement custom access:

```php
class PageEditPerUser extends WireData implements Module, ConfigurableModule {

    public static function getModuleInfo() {
        return [
            'title' => 'Page Edit Per User',
            'autoload' => true,  // Required for hooks
            'singular' => true,
        ];
    }

    public function init() {
        // Hook after Page::editable to add our logic
        $this->addHookAfter('Page::editable', $this, 'hookPageEditable');
        $this->addHookAfter('Page::viewable', $this, 'hookPageViewable');
    }

    public function hookPageEditable($event) {
        // If already editable by core rules, skip
        if($event->return) return;

        $page = $event->object;
        
        // Check if user has page-edit permission
        if($this->user->hasPermission('page-edit')) {
            // Check if page is in user's editable_pages field
            $event->return = $this->user->editable_pages->has($page);
        }
    }
}
```

### Access to Module Admin Pages

Access is granted through the permission system:

1. **Define permission** in `getModuleInfo()`:
   ```php
   'permission' => 'my-tool-access',
   'permissions' => [
       'my-tool-access' => 'Access My Tool',
   ],
   ```

2. **Permission is auto-created** when module is installed

3. **Add permission to roles** in Admin > Access > Roles

4. **Users with that role** can access the module's admin page

5. **In code**, check permissions:
   ```php
   // In module methods
   if(!$this->user->hasPermission('my-tool-access')) {
       throw new WirePermissionException('No access');
   }
   
   // Or check for superuser
   if(!$this->user->isSuperuser()) {
       throw new WireException('Superuser required');
   }
   ```

---

## Fieldtype Modules

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

12. **WireMail routing**: If using WireMailRouter, it intercepts all mail. Test with `$mail->new(['module' => 'WireMailSmtp'])` to bypass.

13. **Hook order matters**: When multiple modules hook the same method, load order affects execution. Use hook priority if needed.

14. **Session state in wizards**: Use `$session->getFor($this, 'key')` to namespace session data per module.
