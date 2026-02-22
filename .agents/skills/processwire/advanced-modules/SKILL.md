---
name: processwire-advanced-modules
description: Advanced module development techniques including Admin UIs, security patterns, virtual templates, and robust integrations
compatibility: opencode
metadata:
  domain: processwire
  scope: modules-advanced
---

## What I Do

I provide guidance for complex ProcessWire module development scenarios:

- Building rich **Admin Interfaces** (Process modules)
- Implementing **Secure Configuration** patterns
- Creating advanced **Fieldtypes** (Multi-value, Virtual Templates)
- Handling **System Operations** (remote requests, file ops, preflight checks)
- Creating **Installers** and sub-modules
- Managing **Custom Database Tables**
- Implementing **AJAX** and dynamic assets
- **Multi-step wizards** with session state
- **Post-render operations** with `__destruct()`
- **Iterable modules** with IteratorAggregate/Countable

## When to Use Me

Use this skill when:

- You need to create a backend tool with forms, tables, or wizards
- You are handling sensitive API keys or credentials in a module
- You are developing a complex Fieldtype that needs to store structural data
- You need to download files or interact with external APIs reliably
- You need to perform environment checks before installation
- You need to store high-volume or non-page data in custom tables
- You need to inject Javascript/CSS into the admin interface

---

## Multi-Step Wizards

Build complex import/export or configuration wizards spanning multiple steps.

### Session State Management

Use namespaced session storage to persist data between steps:

```php
class ImportPagesCSV extends Process implements Module {

    protected function sessionGet($key, $fallback = null) {
        $value = $this->session->getFor($this, $key);
        return $value === null ? $fallback : $value;
    }

    protected function sessionSet($key, $value) {
        $this->session->setFor($this, $key, $value);
    }

    public function ___execute() {
        // Step 1
        $form = $this->buildForm1();
        if($this->input->post('submit')) {
            if($this->processForm1($form)) {
                $this->session->redirect('./fields/');
            }
        }
        return $form->render();
    }

    public function ___executeFields() {
        // Step 2 - retrieve session data
        $template = $this->templates->get($this->sessionGet('csvTemplate'));
        $parent = $this->pages->get($this->sessionGet('csvParent'));
        $csvFilename = $this->sessionGet('csvFilename');

        if(!$template || !$parent->id || !$csvFilename) {
            $this->error("Missing required data");
            $this->session->redirect('../');
        }
        // ... process step 2
    }
}
```

### Wizard Navigation

```php
public function ___execute() {
    // Clear previous wizard state on fresh start
    if(!$this->input->post('submit')) {
        $this->sessionSet('wizard_step', 1);
        $this->sessionSet('wizard_data', []);
    }
    
    $step = (int) $this->sessionGet('wizard_step', 1);
    return $this->renderStep($step);
}
```

---

## Iterable Modules

Make modules foreach-able and countable like collections.

### Implementing IteratorAggregate and Countable

```php
class MarkupLoadRSS extends WireData implements Module, \IteratorAggregate, \Countable {

    protected $items = null;

    public function init() {
        $this->items = new WireArray();
    }

    /**
     * Make module foreach-able
     */
    public function getIterator(): \Traversable {
        return $this->items;
    }

    /**
     * Make module countable
     */
    public function count(): int {
        return count($this->items);
    }
}

// Usage
$rss = $modules->get('MarkupLoadRSS');
$rss->load('https://example.com/feed.rss');

echo "Found " . count($rss) . " items\n";
foreach($rss as $item) {
    echo "$item->title\n";
}
```

### Companion Data Classes

Create dedicated classes for items:

```php
class MarkupLoadRSSItem extends WireData {
    public function get($key) {
        // Translate aliases
        if($key == 'url') $key = 'link';
        if($key == 'date') $key = 'pubDate';
        if($key == 'body') $key = 'description';
        return parent::get($key);
    }
}
```

---

## Post-Render Operations

Execute file operations after the page has rendered using `__destruct()`.

### Pattern: File Renames After Render

```php
class ProcessWireUpgrade extends Process {

    protected $renames = [];

    /**
     * Schedule a rename for after render
     */
    protected function renameLater($oldPath, $newPath) {
        $this->renames[$oldPath] = $newPath;
        $this->message("Scheduled rename: " . basename($oldPath) . " => " . basename($newPath));
    }

    /**
     * Execute scheduled renames after page render
     */
    public function __destruct() {
        if(!count($this->renames)) return;
        
        foreach($this->renames as $oldPath => $newPath) {
            if(file_exists($newPath)) {
                // Handle existing destination
                $n = 0;
                do {
                    $newPath2 = $newPath . "-" . (++$n);
                } while(file_exists($newPath2));
                rename($newPath, $newPath2);
            }
            
            if(rename($oldPath, $newPath)) {
                $this->message("Renamed: " . basename($oldPath) . " => " . basename($newPath));
            } else {
                $this->error("Failed: " . basename($oldPath));
            }
        }
        $this->renames = [];
    }
}
```

Use this pattern when replacing core files - the response sends before the rename happens.

---

## Building Admin Interfaces

Admin interfaces are built using **Process modules** (`Process implements Module`). They map URL segments to methods.

### Basic Process Module

```php
class ProcessMyTool extends Process implements Module {
    public static function getModuleInfo() {
        return [
            'title' => 'My Tool',
            'page' => [
                'name' => 'my-tool',
                'parent' => 'setup',
                'title' => 'My Tool'
            ]
        ];
    }

    public function execute() {
        return "<h1>Hello Admin</h1>";
    }
}
```

### Building Forms

Use the `InputfieldForm` API to create forms consistent with the admin theme.

```php
public function execute() {
    /** @var InputfieldForm $form */
    $form = $this->modules->get("InputfieldForm");
    
    // Text Input
    $f = $this->modules->get("InputfieldText");
    $f->name = 'username';
    $f->label = 'Username';
    $f->required = true;
    $form->add($f);

    // Submit Button
    $f = $this->modules->get("InputfieldSubmit");
    $f->name = 'submit';
    $form->add($f);

    // Process Input
    if($this->input->post('submit')) {
        $form->processInput($this->input->post);
        if(!$form->getErrors()) {
            $this->message("Saved!");
            // $this->session->redirect('./');
        }
    }

    return $form->render();
}
```

### Data Tables

Use `MarkupAdminDataTable` to display listed data.

```php
/** @var MarkupAdminDataTable $table */
$table = $this->modules->get('MarkupAdminDataTable');
$table->setEncodeEntities(false); // If you want HTML in cells
$table->headerRow(['Title', 'Date', 'Status', 'Actions']);

foreach($items as $item) {
    $table->row([
        $item->title,
        date('Y-m-d', $item->created),
        $item->active ? 'Active' : 'Inactive',
        "<a href='./edit/?id=$item->id'>Edit</a>"
    ]);
}

return $table->render();
```

### Multi-Step Wizards

Use session state to manage multi-step processes (like imports).

```php
public function execute() {
    // Step 1
    if($this->input->post('step1_submit')) {
        $this->session->setFor($this, 'import_data', $data);
        $this->session->redirect('./step2/');
    }
    return $this->buildStep1Form()->render();
}

public function executeStep2() {
    // Step 2
    $data = $this->session->getFor($this, 'import_data');
    if(!$data) $this->session->redirect('./'); // Restart if lost
    
    // ... logic ...
}
```

---

## UI Enhancements & Assets

### Injecting Scripts and Styles

You can inject assets conditionally in your module's `init()` or `ready()` methods.

```php
public function ready() {
    // Only load in admin
    if($this->page->template != 'admin') return;

    // Load assets
    $url = $this->config->urls->{$this->className};
    $this->config->scripts->add($url . "my-script.js");
    $this->config->styles->add($url . "my-style.css");
    
    // Pass PHP config to JS
    $this->config->js($this->className, [
        'ajaxUrl' => $this->page->url . 'ajax/',
        'confirmMsg' => $this->_('Are you sure?')
    ]);
}
```

### Hooking Inputfields for UI Injection

To add custom UI elements to specific fields (like autocomplete or buttons), hook `Inputfield::render`.

```php
public function ready() {
    $this->addHookBefore('InputfieldName::render', function($event) {
        $inputfield = $event->object;
        if($inputfield->name !== 'target_field') return;
        
        $inputfield->appendMarkup = "<script>...</script>";
        // or
        $inputfield->prependMarkup = "<div class='hint'>Hint</div>";
    });
}
```

### Dynamic Asset Generation

For complex configurations, generate a static JS file from PHP config instead of inline JS.

```php
protected function createJsFile($configData) {
    $content = "var myConfig = " . json_encode($configData) . ";";
    $path = $this->config->paths->{$this->className} . "config.js";
    file_put_contents($path, $content);
}
```

---

## Custom Database Tables

For high-volume data or data that doesn't fit the Page model, use custom tables.

### Creating Tables

Create tables in `___install()` and drop them in `___uninstall()`.

```php
public function ___install() {
    $sql = "
        CREATE TABLE " . self::TABLE_NAME . " (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
            data TEXT,
            created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ";
    $this->database->query($sql);
}

public function ___uninstall() {
    $this->database->query("DROP TABLE IF EXISTS " . self::TABLE_NAME);
}
```

### Querying Data

Use `$this->database` (PDO) for queries.

```php
// Select
$stmt = $this->database->prepare("SELECT * FROM " . self::TABLE_NAME . " WHERE id=:id");
$stmt->bindValue(':id', $id, \PDO::PARAM_INT);
$stmt->execute();
$row = $stmt->fetch(\PDO::FETCH_OBJ);

// Insert
$stmt = $this->database->prepare("INSERT INTO " . self::TABLE_NAME . " (data) VALUES (:data)");
$stmt->bindValue(':data', $value);
$stmt->execute();
$id = $this->database->lastInsertId();
```

---

## AJAX Handling

Handle AJAX requests within your module methods.

```php
public function executeAjax() {
    // Check if AJAX
    if(!$this->config->ajax) throw new Wire404Exception();
    
    // Validate CSRF (recommended for POST)
    if($this->input->requestMethod('POST')) {
        $this->session->CSRF->validate();
    }

    // Process
    $data = ['success' => true, 'message' => 'Done'];
    
    // Return JSON
    header('Content-Type: application/json');
    return json_encode($data);
}
```

---

## Secure Configuration Pattern

Allow sensitive credentials (API keys, passwords) to be overridden via `site/config.php` so they aren't stored in the database.

### 1. In `getModuleConfigInputfields`

```php
public static function getModuleConfigInputfields(array $data) {
    $inputfields = new InputfieldWrapper();
    $siteConfig = wire('config')->myModuleSettings; // Check site/config.php

    $f = wire('modules')->get('InputfieldText');
    $f->name = 'apiKey';
    $f->label = 'API Key';
    
    // Check if overridden
    if(isset($siteConfig['apiKey'])) {
        $f->value = '********'; // Mask value
        $f->attr('disabled', 'disabled');
        $f->notes = "Controlled by site/config.php";
    } else {
        $f->value = isset($data['apiKey']) ? $data['apiKey'] : '';
    }
    
    $inputfields->add($f);
    return $inputfields;
}
```

### 2. In Module Logic

Merge configuration:

```php
public function getSettings() {
    // Default settings
    $settings = ['apiKey' => $this->apiKey];
    
    // Merge overrides
    $siteConfig = $this->wire('config')->myModuleSettings;
    if(is_array($siteConfig)) {
        $settings = array_merge($settings, $siteConfig);
    }
    
    return $settings;
}
```

---

## Advanced Fieldtypes: FieldtypeMulti

For fields storing multiple related values (like a table or list), extend `FieldtypeMulti` with custom data classes.

### Custom Database Schema

Define multiple columns beyond the default `data`:

```php
class FieldtypeEvents extends FieldtypeMulti {

    public function getDatabaseSchema(Field $field) {
        $schema = parent::getDatabaseSchema($field);
        
        // 'data' is required - we use it for 'date'
        $schema['data'] = 'DATE NOT NULL';
        $schema['title'] = 'TEXT NOT NULL';
        
        // Add indexes for searchable fields
        $schema['keys']['data'] = 'KEY data(data)';
        $schema['keys']['title'] = 'FULLTEXT title(title)';
        
        return $schema;
    }
}
```

### Custom Data Classes

Create WireData for individual items and WireArray for collections:

```php
// Individual item
class Event extends WireData {
    public function __construct() {
        $this->set('date', '');
        $this->set('title', '');
        $this->set('formatted', false);
        parent::__construct();
    }

    public function set($key, $value) {
        if($key === 'date') {
            $value = $value ? wireDate('Y-m-d', $value) : '';
        } else if($key === 'title') {
            $value = $this->sanitizer->text($value);
        }
        return parent::set($key, $value);
    }

    public function __toString() {
        return "$this->date: $this->title";
    }
}

// Collection
class EventArray extends WireArray {
    public function isValidItem($item) {
        return $item instanceof Event;
    }

    public function __toString() {
        $a = [];
        foreach($this as $item) $a[] = (string) $item;
        return implode("\n", $a);
    }
}
```

### Value Conversion: wakeupValue / sleepValue

Convert between database arrays and PHP objects:

```php
public function getBlankValue(Page $page, Field $field) {
    return new EventArray();
}

public function ___wakeupValue(Page $page, Field $field, $value) {
    $events = $this->getBlankValue($page, $field);
    
    if(empty($value) || !is_array($value)) return $events;
    
    foreach($value as $v) {
        $event = new Event();
        $event->date = $v['data'];  // DB 'data' -> 'date'
        $event->title = $v['title'];
        $event->resetTrackChanges();
        $events->add($event);
    }
    
    $events->resetTrackChanges();
    return $events;
}

public function ___sleepValue(Page $page, Field $field, $value) {
    $sleepValue = [];
    if(!$value instanceof EventArray) return $sleepValue;
    
    $value->sort('date');
    
    foreach($value as $event) {
        if(!$event->date) continue;
        if($event->formatted) {
            throw new WireException('Formatted events cannot be saved');
        }
        $sleepValue[] = [
            'data' => $event->date,  // 'date' -> DB 'data'
            'title' => $event->title
        ];
    }
    
    return $sleepValue;
}
```

### Format Value for Output

```php
public function ___formatValue(Page $page, Field $field, $value) {
    $events = $this->getBlankValue($page, $field);
    
    foreach($value as $event) {
        if(!$event->formatted) {
            $event = clone $event;
            $event->title = $this->sanitizer->entities($event->title);
            $event->formatted = true;
        }
        $events->add($event);
    }
    
    return $events;
}
```

### Custom Selector Queries

Enable finding pages by field subfields:

```php
public function getMatchQuery($query, $table, $subfield, $operator, $value) {
    if($subfield == 'date') {
        $subfield = 'data';  // Map to DB column
    }
    
    if($subfield === 'data') {
        $value = wireDate('Y-m-d', $value);
    } else if($subfield === 'title') {
        $finder = new DatabaseQuerySelectFulltext($query);
        $finder->match($table, $subfield, $operator, $value);
        return $query;
    }
    
    return parent::getMatchQuery($query, $table, $subfield, $operator, $value);
}
```

---

## Advanced Fieldtypes: Virtual Templates

For complex Fieldtypes (like `FieldtypeFieldsetGroup`) that need to define a schema of sub-fields, you can create "Virtual Templates".

### Concept

Create a system template that defines the field structure, but is never used for actual pages accessible to users.

### Implementation

```php
protected function createVirtualTemplate(Field $field) {
    $name = "fieldset_" . $field->id;
    
    // 1. Create Fieldgroup
    $fieldgroup = new Fieldgroup();
    $fieldgroup->name = $name;
    $fieldgroup->save();
    
    // 2. Create Template
    $template = new Template();
    $template->name = $name;
    $template->fieldgroup = $fieldgroup;
    $template->flags = Template::flagSystem; // Protect it
    $template->noChildren = 1;
    $template->noParents = 1; // Prevent creation
    $template->save();
    
    return $template;
}
```

---

## System Operations

### Robust Remote Requests

Use `WireHttp` for external API calls:

```php
$http = new WireHttp();
$http->setTimeout(10);
$http->setHeader('User-Agent', 'MyModule/1.0');

$json = $http->get('https://api.example.com/data');
if($json === false) {
    $this->error("HTTP Error: " . $http->getError());
} else {
    $data = json_decode($json, true);
}
```

### HTTP Requests with Caching

Cache remote data to avoid repeated requests:

```php
class MarkupLoadRSS extends WireData implements Module {
    protected $cachePath;

    public function __construct() {
        $this->cachePath = $this->config->paths->cache . $this->className() . '/';
    }

    protected function loadXmlData($url) {
        $cacheFile = $this->cachePath . md5($url) . '.xml.cache';
        $cacheSeconds = 120; // 2 minutes

        if(!is_file($cacheFile) || time() - filemtime($cacheFile) > $cacheSeconds) {
            // Cache expired or missing - fetch fresh
            $http = new WireHttp();
            $this->wire($http);
            $xmlData = $http->get($url);
            
            if(empty($xmlData)) {
                $this->error("Unable to load: $url");
                return false;
            }
            
            // Save to cache
            @file_put_contents($cacheFile, $xmlData, LOCK_EX);
        } else {
            // Load from cache
            $xmlData = file_get_contents($cacheFile);
        }
        
        return $xmlData;
    }

    public function ___install() {
        if(!is_dir($this->cachePath)) {
            wireMkdir($this->cachePath);
        }
    }

    public function ___uninstall() {
        // Clean up cache files
        $dir = new \DirectoryIterator($this->cachePath);
        foreach($dir as $file) {
            if($file->isFile()) unlink($file->getPathname());
        }
        wireRmdir($this->cachePath);
    }
}
```

### File Operations

Use `WireFileTools` (available as `$files` API variable).

```php
// Unzip
$files = $this->wire('files')->unzip($zipPath, $destinationDir);

// Remove directory recursively
$this->wire('files')->rmdir($dirPath, true);

// Temp directory
$tempDir = $this->wire('files')->tempDir('my-module');
```

### Preflight Checks

Check environment capability before sensitive operations.

```php
public function checkEnvironment() {
    if(version_compare(PHP_VERSION, '7.4.0', '<')) {
        throw new WireException("PHP 7.4+ required");
    }
    
    if(!class_exists('ZipArchive')) {
        throw new WireException("ZipArchive extension missing");
    }
    
    if(!is_writable($this->wire('config')->paths->assets)) {
        throw new WireException("Assets directory must be writable");
    }
}
```

---

## Installer Pattern

For complex suites, use a main `Process` module that installs functionality sub-modules (autoload `WireData` modules) via the `installs` property.

```php
// Main Module (Process)
public static function getModuleInfo() {
    return [
        'title' => 'My Suite',
        'installs' => ['MySuiteWorker', 'MySuiteCron'],
    ];
}

// Sub-module (Worker)
public static function getModuleInfo() {
    return [
        'title' => 'My Suite Worker',
        'autoload' => true,
        'requires' => 'MySuite', // Prevents standalone install
    ];
}
```

---

## Installer Pattern

For complex suites, use a main `Process` module that installs functionality sub-modules.

### Main Module with Sub-Module Installer

```php
// Main Module (Process) - creates admin page and UI
class ProcessWireUpgrade extends Process {
    public static function getModuleInfo() {
        return [
            'title' => 'Upgrades',
            'version' => 11,
            'installs' => 'ProcessWireUpgradeCheck',  // Auto-install helper
            'requires' => 'ProcessWire>=3.0.0',
        ];
    }

    public function init() {
        // Ensure sub-module is available
        $this->checker = $this->modules->getInstall('ProcessWireUpgradeCheck');
        if(!$this->checker) {
            throw new WireException("Please refresh modules");
        }
        parent::init();
    }
}

// Sub-module (Worker) - handles version checking
class ProcessWireUpgradeCheck extends WireData implements Module {
    public static function getModuleInfo() {
        return [
            'title' => 'Upgrade Checker',
            'version' => 1,
            'autoload' => false,
            'requires' => 'ProcessWireUpgrade',  // Prevents standalone install
        ];
    }

    public function getVersions($refresh = false) {
        // Check for updates...
    }
}
```

### Creating Admin Pages on Install

**Manual page creation** (alternative to auto-creation via `page` property):

```php
public function ___install() {
    $page = new Page();
    $page->template = 'admin';
    $page->name = 'my-tool';
    $page->parent = $this->pages->get($this->config->adminRootPageID)->child('name=setup');
    $page->process = $this;
    $page->title = 'My Tool';
    $page->save();
    
    $this->message("Created Page: {$page->path}");
}

public function ___uninstall() {
    $moduleID = $this->modules->getModuleID($this);
    $page = $this->pages->get("template=admin, process=$moduleID, name=my-tool");
    
    if($page->id) {
        $this->message("Deleting Page: {$page->path}");
        $page->delete();
    }
}
```

**When to use manual vs auto-creation:**

| Method | When to Use |
|--------|-------------|
| Auto (`page` property) | Simple admin pages, standard setup |
| Manual (in `___install()`) | Multiple pages, custom parent, conditional creation |

### External Info File with Translations

For translatable module info, use an external `.info.php` file:

```php
// MyModule.info.php
<?php namespace ProcessWire;
$info = [
    'title' => __('My Tool', __FILE__),
    'summary' => __('Description of my tool', __FILE__),
    'version' => 1,
    'permission' => 'my-tool',
    'permissions' => [
        'my-tool' => __('Access My Tool', __FILE__),
    ],
    'page' => [
        'name' => 'my-tool',
        'parent' => 'setup',
        'title' => __('My Tool', __FILE__),
    ],
    'nav' => [
        ['url' => './', 'label' => __('View', __FILE__), 'icon' => 'list'],
        ['url' => 'add/', 'label' => __('Add', __FILE__), 'icon' => 'plus'],
    ],
];
```

```php
// MyModule.module - load the info file
public function init() {
    parent::init();
    include(__DIR__ . '/MyModule.info.php');
    // $info is now available
    $this->labels = [
        'title' => $info['title'],
        // ... other labels
    ];
}
```

---

## Strategy/Factory Pattern

For extensible modules that support multiple drivers or engines (like Template Engines), use a Factory + Strategy pattern.

### Interface (Strategy)

Define a contract for drivers.

```php
interface EngineInterface {
    public function render($template, $data);
}
```

### Factory

Register and retrieve drivers.

```php
class EngineFactory extends WireData implements Module {
    protected $engines = [];

    public function registerEngine($name, EngineInterface $engine) {
        $this->engines[$name] = $engine;
    }

    public function getEngine($name) {
        return isset($this->engines[$name]) ? $this->engines[$name] : null;
    }
}
```

---

## Module Config with Testing

Allow users to test configuration settings before saving.

### Config with Test Interface

```php
class WireMailRouter extends WireMail implements Module, ConfigurableModule {

    public function getModuleConfigInputfields(InputfieldWrapper $inputfields) {
        $modules = $this->wire('modules');
        
        // ... regular config fields ...
        
        // Add testing textarea
        $f = $modules->get('InputfieldTextarea');
        $f->attr('name', '_test_emails');
        $f->label = 'Test Configuration';
        $f->description = 'Enter email addresses to test which mailer would be used.';
        $f->icon = 'flask';
        $f->collapsed = Inputfield::collapsedYes;
        $inputfields->add($f);
        
        // Process tests on submit
        $tests = $this->wire('input')->post('_test_emails');
        if($tests) {
            $tests = explode("\n", $tests);
            $results = $this->runTests($tests);
            
            $table = $modules->get('MarkupAdminDataTable');
            $table->headerRow(['Email', 'Mailer', 'Matched Rule']);
            foreach($results as $result) {
                $table->row(array_values($result));
            }
            
            $this->message('Test Results:' . $table->render(), Notice::allowMarkup);
        }
        
        return $inputfields;
    }

    public function runTests(array $tests) {
        $results = [];
        foreach($tests as $test) {
            $test = trim($test);
            if(empty($test)) continue;
            
            list($mailer, $rule) = $this->chooseMailer($test);
            $results[] = [
                'email' => $test,
                'mailer' => $mailer,
                'rule' => $rule ?: 'None'
            ];
        }
        return $results;
    }
}
```
