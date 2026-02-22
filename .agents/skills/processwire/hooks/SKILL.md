---
name: processwire-hooks
description: Hook types (before/after/replace), defining hooks, URL/path hooks, conditional hooks, hook priority, adding methods/properties, and hookable methods
compatibility: opencode
metadata:
  domain: processwire
  scope: hooks
---

## What I Do

I provide comprehensive guidance for ProcessWire hooks:

- Before, after, and replace hooks
- Hook syntax and HookEvent object
- Adding hooks to modules and template files
- URL/path hooks for custom routing
- Conditional hooks with selectors
- Adding new methods and properties to classes
- Creating hookable methods
- Hook priority and removal

## When to Use Me

Use this skill when:

- Modifying ProcessWire behavior without changing core files
- Adding hooks before or after page save/render
- Creating URL handlers without pages
- Adding methods or properties to existing classes
- Understanding the HookEvent object
- Working with conditional hooks

---

## Hook Basics

### What Are Hooks?

Hooks let you execute code before or after any hookable method in ProcessWire. Any method prefixed with `___` (three underscores) is hookable.

### Hook Types

| Type         | When                   | Use Case                               |
| ------------ | ---------------------- | -------------------------------------- |
| **After**    | After method executes  | Modify return value, log actions       |
| **Before**   | Before method executes | Validate/modify arguments, skip method |
| **Replace**  | Instead of method      | Completely replace behavior            |
| **Method**   | Add new method         | Extend class functionality             |
| **Property** | Add new property       | Add computed properties                |

---

## Adding Hooks

### Basic Syntax

```php
// After hook - most common
$this->addHookAfter('Class::method', function($event) {
    // Runs after method
});

// Before hook
$this->addHookBefore('Class::method', function($event) {
    // Runs before method
});
```

### In Modules

```php
class MyModule extends WireData implements Module {

    public function init() {
        // Hook in init() for early hooks
        $this->addHookBefore('Pages::save', $this, 'beforePageSave');
    }

    public function ready() {
        // Hook in ready() when API is ready
        $this->addHookAfter('Page::render', $this, 'afterPageRender');
    }

    public function beforePageSave($event) {
        $page = $event->arguments(0);
        // Validate before save
    }

    public function afterPageRender($event) {
        $event->return .= '<!-- Rendered -->';
    }
}
```

### In Template Files

```php
// In _init.php or at top of template
wire()->addHookAfter('Page::render', function($event) {
    $event->return .= '<!-- Hook added -->';
});
```

### In /site/ready.php or /site/init.php

```php
// /site/ready.php - API is ready
$wire->addHookAfter('Pages::saved', function($event) {
    $page = $event->arguments(0);
    wire('log')->save('pages', "Saved: {$page->path}");
});
```

### Anonymous Functions vs Named Methods

```php
// Anonymous function (inline)
$this->addHookAfter('Page::render', function($event) {
    // Implementation
});

// Named method
$this->addHookAfter('Page::render', $this, 'myHookMethod');

public function myHookMethod($event) {
    // Implementation
}

// Outside a class
wire()->addHookAfter('Page::render', null, 'myGlobalFunction');

function myGlobalFunction($event) {
    // Implementation
}
```

---

## HookEvent Object

Every hook receives a `HookEvent` object with these properties:

### Key Properties

| Property          | Description                                    |
| ----------------- | ---------------------------------------------- |
| `$event->object`  | Object the hook was called on                  |
| `$event->return`  | Return value (for after hooks)                 |
| `$event->replace` | Set to `true` to replace method (before hooks) |

### Arguments

```php
// Get argument by index (0-based)
$page = $event->arguments(0);
$field = $event->arguments(1);

// Get argument by name
$page = $event->arguments('page');

// Get all arguments as array
$args = $event->arguments();

// Modify argument (before hooks)
$event->arguments(0, $modifiedPage);
$event->arguments('page', $modifiedPage);
```

### Return Value

```php
// Read return value (after hooks)
$value = $event->return;

// Modify return value
$event->return = $modifiedValue;

// Append to return value
$event->return .= '<!-- Added -->';
```

### Object Reference

```php
public function myHook($event) {
    // Get the object the method was called on
    $page = $event->object;  // For Page::render, this is the Page

    // Access API from event
    $pages = $event->wire('pages');
    $user = $event->wire('user');
}
```

---

## After Hooks

Run after the hooked method. Can read/modify return value.

```php
// Modify rendered output
$this->addHookAfter('Page::render', function($event) {
    $page = $event->object;
    $event->return = str_replace(
        '</body>',
        '<p>Page ID: ' . $page->id . '</p></body>',
        $event->return
    );
});

// Log after page save
$pages->addHookAfter('saved', function($event) {
    $page = $event->arguments(0);
    $event->wire('log')->save('pages', "Saved: {$page->path}");
});
```

---

## Before Hooks

Run before the hooked method. Can modify arguments or skip method.

```php
// Validate before save
$this->addHookBefore('Pages::save', function($event) {
    $page = $event->arguments(0);

    if($page->template == 'product' && !$page->price) {
        throw new WireException("Products must have a price");
    }
});

// Modify arguments
$this->addHookBefore('Pages::find', function($event) {
    $selector = $event->arguments(0);
    // Add default sorting
    if(strpos($selector, 'sort=') === false) {
        $event->arguments(0, $selector . ', sort=-created');
    }
});
```

---

## Replace Hooks

Completely replace a method's behavior.

```php
$this->addHookBefore('Page::render', function($event) {
    $page = $event->object;

    if($page->template == 'maintenance') {
        // Replace the render entirely
        $event->replace = true;
        $event->return = "<h1>Site Under Maintenance</h1>";
    }
});
```

---

## Adding New Methods

Add methods to existing classes.

```php
// Add summarize() method to Page
$this->addHook('Page::summarize', function($event) {
    $page = $event->object;
    $maxLen = $event->arguments(0) ?: 200;
    $event->return = wire('sanitizer')->truncate($page->body, $maxLen);
});

// Usage
echo $page->summarize(150);
```

### Method with Multiple Arguments

```php
$this->addHook('Page::formatDate', function($event) {
    $page = $event->object;
    $field = $event->arguments(0);
    $format = $event->arguments(1) ?: 'Y-m-d';

    $timestamp = $page->getUnformatted($field);
    $event->return = date($format, $timestamp);
});

// Usage
echo $page->formatDate('created', 'F j, Y');
```

---

## Adding New Properties

Add properties to classes using `addHookProperty()`.

```php
// Add 'intro' property to Page
$this->addHookProperty('Page::intro', function($event) {
    $page = $event->object;
    $intro = strip_tags($page->body);
    $intro = substr($intro, 0, 255);
    $event->return = $intro;
});

// Usage
echo $page->intro;
```

```php
// Add 'hello' property to User
$this->addHookProperty('User::hello', function($event) {
    $user = $event->object;
    $event->return = "Hello, {$user->name}!";
});

// Usage
echo $user->hello;  // "Hello, admin!"
```

---

## URL/Path Hooks

Handle URLs without creating pages.

### Enable in /site/init.php or /site/ready.php

```php
// Simple URL handler
$wire->addHook('/hello/world', function($event) {
    return 'Hello World';
});

// Output directly
$wire->addHook('/hello/world', function($event) {
    echo 'Hello World';
    return true;  // Indicates you handled output
});
```

### URL Parameters

```php
// Named parameter
$wire->addHook('/hello/{name}', function($event) {
    return "Hello " . $event->name;
});

// Pattern matching
$wire->addHook('/hello/(earth|mars|jupiter)', function($event) {
    return "Hello " . $event->arguments(1);
});

// Named with pattern
$wire->addHook('/product/(id:\d+)', function($event) {
    $id = $event->id;
    $product = $event->pages->get("template=product, id=$id");
    if($product->id) return $product;  // Render this page
});
```

### Return Values

| Return         | Result             |
| -------------- | ------------------ |
| `string`       | Output the string  |
| `Page`         | Render that page   |
| `array`        | Convert to JSON    |
| `true`         | You handled output |
| `false` / none | 404 response       |

### JSON API Example

```php
$wire->addHook('(/.*)/json', function($event) {
    $page = $event->pages->findOne($event->arguments(1));
    if($page->viewable()) {
        return [
            'id' => $page->id,
            'title' => $page->title,
            'url' => $page->url,
        ];
    }
});
```

### Pagination in URL Hooks

```php
$wire->addHook('/blog/{pageNum}', function($event) {
    $pageNum = $event->pageNum;  // Integer
    return "You are on page $pageNum";
});
```

### Conditional URL Hooks

```php
// Only for POST requests
if($input->is('POST')) {
    $wire->addHook('/api/submit', function($event) {
        // Handle POST
    });
}

// Only for AJAX
if($config->ajax) {
    $wire->addHook('/api/data', function($event) {
        // Handle AJAX
    });
}
```

---

## Conditional Hooks

Specify conditions in the hook definition.

### Object Conditions

```php
// Only for 'order' template pages
$wire->addHookAfter('Page(template=order)::changed', function($event) {
    // Only executes for order pages
});

// Multiple conditions
$wire->addHookAfter('Page(template=product, price>0)::render', function($event) {
    // Only for products with price
});
```

### Argument Conditions

```php
// Only when 'status' field changes
$wire->addHookAfter('Page::changed(status)', function($event) {
    $oldValue = $event->arguments(1);
    $newValue = $event->arguments(2);
});

// Multiple argument conditions
$wire->addHookAfter('Page(template=order)::changed(0:order_status, 1:name=pending, 2:name=delivered)',
    function($event) {
        // Only when order_status changes from pending to delivered
    }
);
```

### Type Conditions

```php
// Only for User objects
$wire->addHook('Pages::saveReady(<User>)', function($event) {
    $user = $event->arguments(0);
    // Only executes when saving User pages
});

// Multiple types
$wire->addHook('Pages::saveReady(<User|Role|Permission>)', function($event) {
    // Executes for User, Role, or Permission
});
```

### Return Value Conditions

```php
// Match by return value property
$wire->addHookAfter('Field::getInputfield:(label*=Currency)', function($event) {
    $inputfield = $event->return;
    // Only when returned inputfield label contains "Currency"
});

// Match by return type
$wire->addHookAfter('Field::getInputfield:<InputfieldText>', function($event) {
    // Only when return is InputfieldText or extends it
});
```

---

## Hook Priority

Control execution order when multiple hooks exist.

```php
// Default priority is 100
$this->addHookAfter('Page::render', function($event) { }, ['priority' => 100]);

// Run earlier (lower number)
$this->addHookAfter('Page::render', function($event) { }, ['priority' => 50]);

// Run later (higher number)
$this->addHookAfter('Page::render', function($event) { }, ['priority' => 200]);
```

---

## Removing Hooks

```php
// Remove from within hook
$this->addHookAfter('Pages::saved', function($event) {
    // Do something once
    $event->removeHook(null);  // Remove this hook
});

// Store hook ID for later removal
$hookId = $this->addHookAfter('Page::render', function($event) { });
// Later...
$this->removeHook($hookId);
```

---

## Creating Hookable Methods

Make your own methods hookable with `___` prefix.

```php
class MyModule extends WireData implements Module {

    /**
     * This method is hookable
     * Call it as $module->processItem($item)
     */
    public function ___processItem($item) {
        // Default implementation
        return $item->title;
    }

    /**
     * This method is NOT hookable
     */
    public function helperMethod($value) {
        return strtoupper($value);
    }
}
```

### PHPDoc for Hookable Methods

```php
/**
 * MyModule
 *
 * @method string processItem($item) Process an item
 */
class MyModule extends WireData implements Module {

    public function ___processItem($item) {
        return $item->title;
    }
}
```

---

## Common Hook Targets

### Page Hooks

```php
Page::render          // After page renders
Page::loaded          // After page loads from DB
Page::changed         // When field value changes
Page::added           // After page created
Page::moved           // After page moved
Page::renamed         // After page renamed
Page::deleted         // After page deleted
Page::trashed         // After page trashed
Page::restored        // After page restored from trash
```

### Pages Hooks

```php
Pages::save           // Save a page
Pages::saveReady      // Before save
Pages::saved          // After save
Pages::saveFieldReady // Before field save
Pages::savedField     // After field save
Pages::add            // Add new page
Pages::added          // After page added
Pages::delete         // Delete page
Pages::deleted        // After page deleted
Pages::trash          // Trash page
Pages::trashed        // After page trashed
Pages::find           // Find pages
Pages::found          // After find
```

### Session Hooks

```php
Session::login        // User login
Session::loginSuccess // Successful login
Session::loginFailed  // Failed login
Session::logout       // User logout
```

---

## Common Patterns

### Validate Before Save

```php
$pages->addHookBefore('saveReady', function($event) {
    $page = $event->arguments(0);

    if($page->template == 'event') {
        if($page->end_date < $page->start_date) {
            throw new WireException("End date must be after start date");
        }
    }
});
```

### Auto-Generate Field Value

```php
$pages->addHookBefore('saveReady', function($event) {
    $page = $event->arguments(0);

    if($page->template == 'product' && !$page->sku) {
        $page->sku = 'PRD-' . str_pad($page->id, 6, '0', STR_PAD_LEFT);
    }
});
```

### Log All Page Saves

```php
$pages->addHookAfter('saved', function($event) {
    $page = $event->arguments(0);
    $user = wire('user');
    wire('log')->save('page-saves', "{$user->name} saved {$page->path}");
});
```

### Modify Admin Page List

```php
$this->addHookAfter('ProcessPageListRender::getPageLabel', function($event) {
    $page = $event->arguments(0);
    if($page->template == 'product') {
        $event->return .= " <small>(\${$page->price})</small>";
    }
});
```

---

## Pitfalls / Gotchas

1. **Hook location matters**: Hooks must be defined before the hooked method is called.

2. **init() vs ready()**: Use `init()` for early hooks, `ready()` when you need `$page`.

3. **Instance vs class hooks**:

   ```php
   // All Page instances
   $this->addHookAfter('Page::render', ...);

   // Single instance only
   $page->addHookAfter('render', ...);
   ```

4. **Hookable method calls**: Always call without underscores:

   ```php
   $this->processItem($item);  // Correct - allows hooks
   $this->___processItem($item);  // Bypasses hooks
   ```

5. **Return value availability**: `$event->return` only available in after hooks.

6. **Modifying arguments**: Only works in before hooks.

7. **Infinite loops**: Be careful hooking methods you call within the hook.

8. **Performance**: Avoid heavy operations in hooks called frequently (like `Page::render`).

9. **Hook removal**: Use `$event->removeHook(null)` to remove the current hook from within itself.
