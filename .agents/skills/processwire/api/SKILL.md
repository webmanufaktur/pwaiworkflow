---
name: processwire-api
description: Core API variables, functions, classes, and ProcessWire coding conventions for page/data manipulation and development
compatibility: opencode
metadata:
  domain: processwire
  scope: api
---

## What I Do

I provide comprehensive reference for ProcessWire's API, including:

- All API variables (Primary, Input/Output, Users, Utilities, System)
- API functions (common helpers, file operations, translations)
- Core classes (Wire, WireData, WireArray, Page, etc.)
- ProcessWire coding style conventions
- Fluent interfaces and chaining patterns

## When to Use Me

Use this skill when:

- Looking up API variable names and their purposes
- Understanding core ProcessWire classes
- Working with Pages, PageArrays, and WireArrays
- Using helper functions like `wireIncludeFile()`, `wireDate()`
- Following ProcessWire coding conventions
- Understanding the class hierarchy

---

## API Variables

ProcessWire provides API variables accessible in template files and modules.

### Primary Variables

| Variable   | Class   | Description                          |
| ---------- | ------- | ------------------------------------ |
| `$page`    | Page    | Current page being viewed            |
| `$pages`   | Pages   | Load, find, save, delete pages       |
| `$modules` | Modules | Load and manage all modules          |
| `$user`    | User    | Current logged-in user (a Page type) |

### Input & Output Variables

| Variable     | Class     | Description                                  |
| ------------ | --------- | -------------------------------------------- |
| `$input`     | WireInput | GET, POST, COOKIE, URL segments, pagination  |
| `$sanitizer` | Sanitizer | Sanitize and validate user input             |
| `$session`   | Session   | Sessions, authentication, redirects, notices |
| `$log`       | WireLog   | Create and manage log entries                |

### Users & Access Variables

| Variable       | Class       | Description                           |
| -------------- | ----------- | ------------------------------------- |
| `$user`        | User        | Current user (Page representing user) |
| `$users`       | Users       | Manage all User objects               |
| `$permissions` | Permissions | Manage all Permission pages           |
| `$roles`       | Roles       | Manage all Role pages                 |

### Utilities & Helpers Variables

| Variable    | Class         | Description                                      |
| ----------- | ------------- | ------------------------------------------------ |
| `$cache`    | WireCache     | Persistent caching of markup, arrays, PageArrays |
| `$datetime` | WireDatetime  | Date/time helpers and format conversion          |
| `$files`    | WireFileTools | File and directory operations                    |
| `$mail`     | WireMailTools | Email sending interface                          |

### System Variables

| Variable       | Class           | Description                                   |
| -------------- | --------------- | --------------------------------------------- |
| `$config`      | Config          | All configuration settings                    |
| `$database`    | WireDatabasePDO | PDO database operations                       |
| `$fields`      | Fields          | Manage all custom fields                      |
| `$templates`   | Templates       | Manage all templates                          |
| `$languages`   | Languages       | Access to all Language pages (multi-language) |
| `$classLoader` | WireClassLoader | Class autoloading                             |
| `$urls`        | Paths           | URL paths (`$config->urls`)                   |

---

## API Functions

### Functions API Access

Enable in `/site/config.php`:

```php
$config->useFunctionsAPI = true;
```

These mirror API variables with optional shortcuts:

```php
// Equivalent calls
$pages->find("template=product");
pages()->find("template=product");
pages("template=product");  // Shortcut

// Get single page
$pages->get("/about/");
pages()->get("/about/");
pages("/about/");  // Shortcut
```

### Common Functions

| Function                 | Description                                               |
| ------------------------ | --------------------------------------------------------- |
| `wire()`                 | Get ProcessWire instance or API variable: `wire('pages')` |
| `wire404()`              | Throw 404 exception                                       |
| `wireCount($value)`      | Count items (works on strings, arrays, objects)           |
| `wireDate($format, $ts)` | Format a date/time                                        |
| `wireEmpty($value)`      | Check if value is empty                                   |
| `wireLen($value)`        | Get length of string/array                                |
| `wireMail()`             | Get WireMail instance for sending email                   |

### File Functions

| Function                        | Description                                |
| ------------------------------- | ------------------------------------------ |
| `wireIncludeFile($file, $vars)` | Include file with variable scope isolation |
| `wireRenderFile($file, $vars)`  | Render file and return output as string    |
| `wireChmod($path, $recursive)`  | Set permissions on file/directory          |
| `wireCopy($src, $dst)`          | Copy file or directory                     |
| `wireMkdir($path)`              | Create directory                           |
| `wireRmdir($path, $recursive)`  | Remove directory                           |
| `wireSendFile($file, $options)` | Send file to browser for download          |
| `wireTempDir($name)`            | Get/create temporary directory             |
| `wireZipFile($zipfile, $files)` | Create ZIP file                            |
| `wireUnzipFile($zipfile, $dst)` | Extract ZIP file                           |

### String Functions

| Function                              | Description                              |
| ------------------------------------- | ---------------------------------------- |
| `wireBytesStr($bytes)`                | Convert bytes to human-readable string   |
| `wireDate($format, $value)`           | Format date/time value                   |
| `wirePopulateStringTags($str, $vars)` | Replace `{tags}` in string with values   |
| `wireRelativeTimeStr($ts)`            | Get relative time string ("2 hours ago") |

### Translation Functions

| Function                       | Description                           |
| ------------------------------ | ------------------------------------- |
| `__($text)`                    | Translate text string                 |
| `_n($single, $plural, $count)` | Translate with singular/plural        |
| `_x($text, $context)`          | Translate with context disambiguation |

```php
// Basic translation
echo __("Hello World");

// Plural forms
echo _n("1 item", "%d items", $count);

// Context (same text, different meaning)
echo _x("Post", "verb");     // To post something
echo _x("Post", "noun");     // A blog post
```

### Array Functions

| Function      | Description                |
| ------------- | -------------------------- |
| `PageArray()` | Create new PageArray       |
| `WireArray()` | Create new WireArray       |
| `WireData()`  | Create new WireData object |

---

## Core Classes

### Primary Classes

| Class       | Description                                     |
| ----------- | ----------------------------------------------- |
| `Wire`      | Base class for most ProcessWire classes/modules |
| `WireData`  | Base data-storage class with get/set methods    |
| `WireArray` | Base iterable array type                        |

### Page Classes

| Class        | Description                                           |
| ------------ | ----------------------------------------------------- |
| `Page`       | Represents a page in the system                       |
| `NullPage`   | Returned when page not found (check with `$page->id`) |
| `User`       | User page type                                        |
| `Role`       | Role page type                                        |
| `Permission` | Permission page type                                  |

### Array Classes

| Class            | Description                              |
| ---------------- | ---------------------------------------- |
| `WireArray`      | Base array with find/filter/sort methods |
| `PageArray`      | Paginated array of Page objects          |
| `PaginatedArray` | Array supporting pagination              |

### Module Classes

| Class           | Description                       |
| --------------- | --------------------------------- |
| `Module`        | Primary interface for all modules |
| `Fieldtype`     | Base for field type modules       |
| `Inputfield`    | Base for input field modules      |
| `Process`       | Admin application modules         |
| `Textformatter` | Text formatting modules           |

### File Classes

| Class              | Description                     |
| ------------------ | ------------------------------- |
| `Pagefile`         | Single file attached to a page  |
| `Pagefiles`        | WireArray of Pagefile objects   |
| `Pageimage`        | Single image attached to a page |
| `Pageimages`       | WireArray of Pageimage objects  |
| `PagefilesManager` | Manages page file directories   |

### Field & Template Classes

| Class        | Description                    |
| ------------ | ------------------------------ |
| `Field`      | A custom field definition      |
| `Fieldgroup` | Group of fields for a template |
| `Template`   | Template definition            |

---

## Page Class Reference

### Common Properties

```php
$page->id           // Page ID (int)
$page->name         // Page name (URL segment)
$page->title        // Page title
$page->path         // Full path: /parent/child/
$page->url          // URL with domain handling
$page->httpUrl      // Full URL with scheme
$page->parent       // Parent Page object
$page->parents      // PageArray of all ancestors
$page->children     // PageArray of child pages
$page->template     // Template object
$page->created      // Unix timestamp created
$page->modified     // Unix timestamp last modified
$page->createdUser  // User who created
$page->modifiedUser // User who last modified
```

### Common Methods

```php
// Traversal
$page->child("selector");     // First matching child
$page->children("selector");  // All matching children
$page->find("selector");      // Find in descendants
$page->parent("selector");    // First matching parent
$page->parents("selector");   // All matching parents
$page->siblings("selector");  // Sibling pages
$page->next("selector");      // Next sibling
$page->prev("selector");      // Previous sibling
$page->rootParent;            // Top-level parent

// Field access
$page->get("fieldname");          // Get field value
$page->get("field1|field2");      // First non-empty
$page->getFormatted("fieldname"); // Get formatted value
$page->getUnformatted("field");   // Get raw value
$page->set("fieldname", $value);  // Set field value

// Status checks
$page->viewable();      // Can current user view?
$page->editable();      // Can current user edit?
$page->publishable();   // Can current user publish?
$page->deleteable();    // Can current user delete?
$page->addable();       // Can add children?
$page->moveable();      // Can move?
$page->sortable();      // Can sort?

// Saving
$page->save();              // Save all changes
$page->save("fieldname");   // Save specific field
$page->setAndSave("f", $v); // Set and save in one call

// Status
$page->isHidden();      // Is hidden?
$page->isUnpublished(); // Is unpublished?
$page->isTrash();       // Is in trash?
$page->is("selector");  // Matches selector?
$page->matches("sel");  // Alias for is()
```

---

## Pages Class Reference

```php
// Get single page
$pages->get($id);           // By ID
$pages->get("/path/");      // By path
$pages->get("name=foo");    // By selector (first match)

// Find multiple pages
$pages->find("selector");   // Find matching pages
$pages->findOne("sel");     // Find first match (alias for get)
$pages->findMany("sel");    // Find large result sets efficiently

// Count
$pages->count("selector");  // Count matching pages

// Create/Save/Delete
$p = new Page();
$p->template = "basic-page";
$p->parent = $pages->get("/");
$p->title = "New Page";
$pages->save($p);

$pages->delete($page);       // Delete page
$pages->trash($page);        // Move to trash
$pages->restore($page);      // Restore from trash
$pages->clone($page);        // Clone page

// Special finds
$pages->findIDs("selector"); // Get just IDs (faster)
$pages->findRaw("sel", ["title", "path"]); // Raw data
```

---

## WireArray Methods

Both PageArray and WireArray support these methods:

```php
// Filtering
$items->find("selector");     // Find within array
$items->filter("selector");   // Filter in place
$items->not("selector");      // Exclude matching
$items->has("selector");      // Contains match?

// Access
$items->first();              // First item
$items->last();               // Last item
$items->eq(3);                // Item at index
$items->getRandom();          // Random item
$items->slice(0, 5);          // Subset

// Iteration
$items->each(function($item) { });
$items->each("<li>{title}</li>");  // Template string

// Aggregation
$items->count();              // Number of items
$items->implode(", ", "title"); // Join field values
$items->explode("title");     // Get array of field values

// Sorting
$items->sort("title");        // Sort ascending
$items->sort("-date");        // Sort descending
$items->shuffle();            // Random order
$items->reverse();            // Reverse order

// Adding/Removing
$items->add($item);           // Add item
$items->prepend($item);       // Add to beginning
$items->append($item);        // Add to end
$items->remove($item);        // Remove item
$items->removeAll();          // Clear all

// Combining
$items->and($otherItems);     // Merge arrays
$items->import($array);       // Import from array
```

---

## Coding Style Conventions

ProcessWire follows a modified PSR-1/PSR-2 style guide.

### Key Differences from PSR

- **Tabs for indentation** (not spaces)
- **Opening braces on same line** for classes and methods
- **No space after control keywords**: `if($x)` not `if ($x)`
- **Constants in camelCase** (in core): `const maxItems = 100;`
- **Use `else if`** not `elseif`

### Example Class

```php
<?php namespace ProcessWire;

/**
 * Class SampleModule
 *
 * Description of the module
 *
 * @method int calculate(int $a, int $b)
 *
 */
class SampleModule extends WireData implements Module {

    /**
     * Maximum allowed items
     *
     */
    const maxItems = 100;

    /**
     * Sample property
     *
     * @var bool
     *
     */
    protected $enabled = true;

    /**
     * Calculate sum of two numbers
     *
     * @param int $a First number
     * @param int $b Second number
     * @return int
     *
     */
    public function ___calculate($a, $b) {
        if($a > self::maxItems) {
            $a = self::maxItems;
        }
        return $a + $b;
    }
}
```

### Hookable Methods

Methods with `___` prefix are hookable:

```php
// Hookable method declaration
public function ___myMethod($arg) {
    return $arg * 2;
}

// Document with @method in class PHPDoc
/**
 * @method int myMethod(int $arg)
 */
```

### Control Structures

```php
// if/else
if($expr1) {
    // body
} else if($expr2) {
    // body
} else {
    // body
}

// foreach
foreach($items as $item) {
    echo $item->title;
}

// switch
switch($value) {
    case 1:
        // body
        break;
    case 2:
        // fall through intentional
    case 3:
        // body
        break;
    default:
        // body
}
```

### Strings and Translations

```php
// Single quotes for non-translatable
$name = 'fieldname';

// Translation functions for user-facing text
$label = $this->_('Save');
$message = sprintf($this->_('Saved %d items'), $count);

// Plural forms
$text = $this->_n('1 page', '%d pages', $count);
```

### PHPDoc Recommendations

```php
/**
 * Short description
 *
 * Longer description if needed.
 *
 * @param string $name Name parameter
 * @param int|null $value Optional value
 * @return bool Success status
 * @throws WireException On failure
 *
 */
public function doSomething($name, $value = null) {
    // ...
}
```

---

## Common Patterns

### Accessing API in Classes

```php
class MyModule extends WireData implements Module {

    public function init() {
        // Preferred: use $this->wire()
        $page = $this->wire('page');
        $pages = $this->wire('pages');

        // Also works
        $page = $this->page;
        $pages = $this->pages;
    }
}
```

### Accessing API in Hooks

```php
$pages->addHookAfter('saved', function(HookEvent $e) {
    // Access API from HookEvent
    $page = $e->arguments(0);
    $log = $e->wire('log');
    $log->save('my-log', "Page saved: {$page->path}");
});
```

### Multi-Instance Support

```php
// Boot ProcessWire externally
$wire = new ProcessWire('/path/to/site/');

// Access API from instance
$pages = $wire->pages;
$items = $pages->find("template=product");

// Set current instance for functions API
ProcessWire::setCurrentInstance($wire);
```

---

## Pitfalls / Gotchas

1. **NullPage checks**: Always check if page exists

   ```php
   $p = $pages->get("/maybe-missing/");
   if($p->id) {
       // Page exists
   }
   ```

2. **Formatted vs Unformatted**: Some fields need unformatted access for manipulation

   ```php
   $page->of(false);  // Turn off output formatting
   $page->body = $newValue;
   $page->save();
   $page->of(true);   // Turn back on
   ```

3. **API variable scope in functions**:

   ```php
   function myFunction() {
       // $pages is not in scope!
       $pages = wire('pages');  // Use wire() instead
   }
   ```

4. **Modifying PageArrays**: Use `->add()` not array syntax

   ```php
   // Wrong
   $items[] = $newPage;

   // Correct
   $items->add($newPage);
   ```

5. **Save before accessing ID**: New pages need saving first
   ```php
   $p = new Page();
   $p->template = "basic-page";
   // $p->id is 0 here
   $pages->save($p);
   // Now $p->id has a value
   ```
