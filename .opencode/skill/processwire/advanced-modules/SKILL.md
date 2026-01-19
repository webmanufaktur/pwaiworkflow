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
- Creating advanced **Fieldtypes** (Virtual Templates)
- Handling **System Operations** (remote requests, file ops, preflight checks)
- Creating **Installers** and sub-modules
- Managing **Custom Database Tables**
- Implementing **AJAX** and dynamic assets

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

Use `WireHttp` for external API calls.

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
