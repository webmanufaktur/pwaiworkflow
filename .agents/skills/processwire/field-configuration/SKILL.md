---
name: processwire-field-configuration
description: Field configuration access patterns, Field vs Inputfield relationship, configuration storage, and universal patterns for ProcessWire development
compatibility: opencode
metadata:
  domain: processwire
  scope: field-configuration
---

## What I Do

I provide comprehensive guidance for ProcessWire field configuration:

- Field vs Inputfield architecture and relationship
- Where configuration is stored and accessed
- Universal patterns for field configuration access
- Hook-specific configuration access methods
- Field type specific configuration patterns
- Cross-references to related skills (hooks, fields, modules)

## When to Use Me

Use this skill when:

- Adding configuration to Fieldtype or Inputfield modules
- Accessing field configuration values in hooks
- Implementing `getConfigInputfields` hooks
- Creating custom field types with configuration options
- Debugging field configuration issues
- Deciding between `addHookProperty` and `Field->get()` patterns

---

## Field Configuration Architecture

### Field vs Inputfield Relationship

ProcessWire fields have two main components:

1. **Field Object** (`/wire/core/Field.php`)
   - Stores configuration in database (`fields` table)
   - Contains all field properties and settings
   - Persistent across requests
   - Universal source of truth for configuration

2. **Inputfield Class** (`/wire/modules/Inputfield/`)
   - Renders HTML for admin interface
   - Processes form submissions
   - Temporary instance created per request
   - Does NOT store configuration permanently

### Configuration Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│  Admin: Field Settings Page                           │
│                                                         │
│  User configures field (checkboxes, selects, etc)  │
│                      ↓                                    │
│  Inputfield::getConfigInputfields() Hook                │
│  Builds configuration form UI                             │
│                      ↓                                    │
│  User saves field configuration                          │
│                      ↓                                    │
│  Inputfield values submitted → Field::set('prop', val) │
│  Stored in 'fields' table (data column)           │
│                      ↓                                    │
│  Configuration persists across requests                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Accessing Configuration (Various Hooks)               │
│                                                         │
│  Pages::saveReady, Fieldtype::formatValue, etc.   │
│                      ↓                                    │
│  Field::get('propertyName') ← Retrieves stored config   │
│  Works in ALL contexts                                   │
└─────────────────────────────────────────────────────────────┘
```

### Where Configuration Is Stored

| Storage Location           | When Used              | Example Properties                          |
| -------------------------- | ---------------------- | ------------------------------------------- |
| Field object (data column) | Default storage        | textformatters, contentType, extensions     |
| Fieldtype-specific tables  | Special cases          | fieldtype_options (for Options field)       |
| File schema columns        | File/Image fields      | width, height, ratio (stored in page data)  |
| Context-specific           | Per-template overrides | Custom label, required setting per template |

---

## Configuration Access Patterns

### Pattern 1: Field->get() Method

**Status:** UNIVERSAL, RECOMMENDED

This pattern works in ALL contexts and is used throughout ProcessWire core.

#### Syntax

```php
$value = $field->get('propertyName');
```

#### When to Use

- In any hook that receives Field object as parameter
- When accessing configuration from any context
- Default choice - no setup required
- Most common pattern in ProcessWire core

#### Examples from Core

```php
// FieldtypeText - Reading textformatters configuration
$textformatters = $field->get('textformatters');
if(!is_array($textformatters)) $textformatters = array();

// FieldtypeFile - Reading extensions configuration
$extensions = $field->get('extensions');
$maxFiles = (int) $field->get('maxFiles');

// FieldtypePage - Reading template configuration
$templateIDs = $field->get('template_ids');
$derefAsPage = (int) $field->get('derefAsPage');

// FieldtypeTextarea - Reading content type
$contentType = $field->get('contentType');
$htmlOptions = $field->get('htmlOptions');

// FieldtypeOptions - Reading initial value
if($field->get('initValue')) {
    $initValue = $field->get('initValue');
}
```

#### Why This Pattern Works

- Field object is passed to all configuration hooks
- Configuration is loaded from database before hooks execute
- No setup required in module initialization
- Works in hook chains and nested contexts

---

### Pattern 2: addHookProperty

**Status:** RARE, SPECIAL USE CASES

Adds runtime properties to class instances using hooks. Creates convenient `$inputfield->property` access.

#### Syntax

```php
// In module ready() or init()
$this->addHookProperty('ClassName::propertyName', $this, 'defaultMethod');

// Then access as property
$value = $inputfield->propertyName;
```

#### When to Use

- Adding computed properties to core classes (Page, User, Field, etc.)
- Creating convenient shortcuts for frequently accessed data
- Extending core classes without modifying source files
- **NOT for basic field configuration** (use Pattern 1 instead)

#### Example from ProcessWire

```php
// ProcessRecentPages - Adding computed property to Page
$this->addHookProperty('Page::recentTimeStr', $this, 'hookPageRecentTimeStr');

// Now accessible on all Page instances
echo $page->recentTimeStr; // Computed value
```

#### Why This Pattern is Rare for Field Config

- Only ONE usage found across entire ProcessWire core for `addHookProperty` on fields
- All core Fieldtypes use `$field->get('property')` pattern exclusively
- Adds complexity without benefit for basic configuration storage
- Requires hook setup before property is available

---

### Pattern 3: Hybrid Approach

**Status:** CONTEXT-DEPENDENT

Uses different patterns in different contexts based on what's available.

#### When to Use

- Module already established using Inputfield properties
- Need to maintain backward compatibility
- Performance-critical sections where direct property access is faster
- Migrating from old code to new patterns

#### Example Scenario

```php
// In render hook - may use Inputfield property (if addHookProperty exists)
public function renderHook(HookEvent $event) {
    $inputfield = $event->object;

    // Option 1: Use hooked property if available
    if(isset($inputfield->mySetting)) {
        $value = $inputfield->mySetting;
    }
    // Option 2: Fall back to Field->get()
    else {
        $field = $this->fields->get($inputfield->name);
        $value = $field->get('mySetting');
    }
}

// In save hook - always use Field->get()
public function saveHook(HookEvent $event) {
    $page = $event->arguments(0);

    foreach($page->template->fieldgroup as $field) {
        // Always use Field->get() in save context
        $value = $field->get('mySetting');
    }
}
```

#### Why This Pattern is Problematic

- Mixing patterns causes maintenance issues
- Difficult to predict which pattern is used where
- Changes to one pattern may break the other
- Harder to debug when things go wrong

**Recommendation:** Choose Pattern 1 (Field->get()) and use it consistently.

---

## Hook Type Reference Table

Understanding what object type each hook provides is critical for correct configuration access.

| Hook Method                            | `$event->object` Type      | Configuration Access                                              | Example                         |
| -------------------------------------- | -------------------------- | ----------------------------------------------------------------- | ------------------------------- |
| `InputfieldText::getConfigInputfields` | InputfieldText (temporary) | `$field->get('property')`                                         | `$field->get('textformatters')` |
| `Pages::saveReady`                     | Page                       | Get field from `$page->template->fieldgroup` then `$field->get()` | `$field->get('guidFormat')`     |
| `Pages::saved`                         | Page                       | Same as saveReady                                                 | `$field->get('extensions')`     |
| `InputfieldText::render`               | InputfieldText             | `$this->fields->get($name)->get()`                                | See below                       |
| `Fieldtype::getConfigInputfields`      | Field                      | `$this->get('property')` or `$field->get('property')`             | `$this->inputfieldClass`        |
| `Fieldtype::saveFieldReady`            | Field                      | `$this->get('property')`                                          | `$this->get('textformatters')`  |
| `Fieldtype::formatValue`               | Field parameter            | `$field->get('property')`                                         | `$field->get('contentType')`    |
| `Fieldtype::markupValue`               | Field parameter            | `$field->get('property')`                                         | `$field->get('labelFieldName')` |

### Inputfield::render Hook Pattern

In render hooks, you have an Inputfield instance but not the Field object directly. Access configuration by getting the Field:

```php
public function renderHook(HookEvent $event) {
    $inputfield = $event->object;  // InputfieldText instance

    // WRONG: Inputfield doesn't have config directly
    // $value = $inputfield->mySetting; // Won't work

    // CORRECT: Get Field object
    $field = $this->fields->get($inputfield->name);
    $value = $field->get('mySetting'); // Works
}
```

### Pages Hooks Pattern

In Page-related hooks, access Field through the page's template:

```php
public function saveReadyHook(HookEvent $event) {
    $page = $event->arguments(0);  // Page object

    foreach($page->template->fieldgroup as $field) {
        // Field object is directly available
        $value = $field->get('mySetting');
    }
}
```

---

## Field Type Specific Patterns

### Text/Textarea Fields

**Configuration Properties:**

- `textformatters` - Array of Textformatter module names
- `inputfieldClass` - Which Inputfield widget to use
- `contentType` (Textarea only) - HTML vs plain text
- `htmlOptions` (Textarea only) - HTML option flags

**Pattern:**

```php
// getConfigInputfields - Build UI
$f = $modules->get('InputfieldCheckboxes');
$f->attr('name', 'textformatters');
$f->label = $this->_('Text Formatters');

// Set value from Field configuration
$value = $field->get('textformatters');
if(!is_array($value)) $value = array();
$f->val($value);

// formatValue - Apply configuration
$textformatters = $field->get('textformatters');
if(is_array($textformatters)) {
    foreach($textformatters as $name) {
        $formatter = $modules->get($name);
        $value = $formatter->formatValue($page, $field, $value);
    }
}
```

---

### File/Image Fields

**Configuration Properties:**

- `extensions` - Space-separated allowed file extensions
- `maxFiles` - Maximum number of files (0=unlimited)
- `maxFilesize` - Maximum file size in bytes
- `useTags` - Tag mode (0=off, 1=normal, 8=predefined)
- `tagsList` - Predefined tags
- `entityEncode` - Auto HTML entity encoding
- `descriptionRows` - Number of rows for description textarea
- `fileSchema` (Image) - Bitmask for additional data

**Special Consideration:**

- Uses helper class for complex configuration: `FieldtypeFile/config.php`
- Schema-driven storage for dimensions (width, height, ratio)

**Pattern:**

```php
// getConfigInputfields - Uses helper class
include_once(dirname(__FILE__) . '/FieldtypeFile/config.php');
$cfg = $this->wire(new FieldtypeFileConfig($field, $inputfields));
$inputfields = $cfg->getConfigInputfields();

// Direct access in Fieldtype methods
$extensions = $field->get('extensions');
if(!$field->get('extensions')) {
    // Warning about missing configuration
}

// formatValue - Apply textformatters
$textformatters = $field->get('textformatters');
$useTags = (int) $field->get('useTags');
```

---

### Page Fields

**Configuration Properties:**

- `template_id` - Single template ID for selectable pages
- `template_ids` - Array of template IDs
- `parent_id` - Parent page ID for selectable pages
- `findPagesCode` - PHP eval code (deprecated)
- `findPagesSelector` - ProcessWire selector string
- `findPagesSelect` - Interactive selector configuration
- `derefAsPage` - Return type (0=PageArray, 1=PageOrFalse, 2=PageOrNullPage)
- `labelFieldName` - Field to use for labels
- `labelFieldFormat` - Custom label format string
- `addable` - Allow adding new pages
- `allowUnpub` - Allow selecting unpublished pages

**Special Consideration:**

- Cross-field references (template configuration from same or different field)
- Inputfield delegation (InputfieldPage instantiates other Inputfields)
- Context support (different config per template)

**Pattern:**

```php
// getConfigInputfields - Cross-field reference
$f = $modules->get('InputfieldSelect');
$f->attr('name', 'parent_id');
$f->val((int) $this->parent_id);  // From Field property

$templateIDs = $this->getTemplateIDs();
$f->attr('value', $templateIDs);

$derefAsPage = $this->get('derefAsPage');
$f->val($derefAsPage);

// markupValue - Use label configuration
$labelFieldName = $field->get('labelFieldName');
$labelFieldFormat = $field->get('labelFieldFormat');

if($labelFieldName == '.') {
    $property = strlen($labelFieldFormat) ? $labelFieldFormat : 'title';
} else {
    $property = $labelFieldName;
}
```

---

### Options Fields

**Configuration Properties:**

- `inputfieldClass` - Which Inputfield widget to use (Select, Radios, etc.)
- `initValue` - Default value to set
- `optionsBlankValue` - What blank value means

**Special Consideration:**

- Options stored in separate `fieldtype_options` database table
- Uses `SelectableOptionManager` class for all CRUD operations
- Each option has ID, title, value, sort

**Pattern:**

```php
// getConfigInputfields - Delegates to option config class
include_once(dirname(__FILE__) . '/SelectableOptionConfig.php');
$cfg = $this->wire(new SelectableOptionConfig($field, $inputfields));
$inputfields = $cfg->getConfigInputfields();

// getInputfield - Load options via manager
foreach($this->manager->getOptions($field) as $option) {
    $value = $option->value;
    $attrs = [];
    if($value) $attrs['data-if-value'] = $value;
    $inputfield->addOption((int) $option->id, $option->getTitle(), $attrs);
}

// wakeupValue - Apply initValue
if($field->required && $field->get('initValue')) {
    $initValue = $field->get('initValue');
    if(empty($value) || !wireCount($value)) {
        $page->set($field->name, $initValue);
    }
}
```

---

## Decision Tree

When to choose which configuration access pattern:

```
Need to access field configuration?
│
├─ Do you have Field object available?
│  │
│  ├─ YES → Use Pattern 1: $field->get('property')
│  │           ↑ UNIVERSAL, always works, no setup
│  │
│  └─ What object do you have?
│     │
│     ├─ Inputfield instance (e.g., in render hook)
│     │  └─ Get Field: $this->fields->get($inputfield->name)
│     │         → Then: $field->get('property')
│     │
│     ├─ Page instance (e.g., in save hook)
│     │  └─ Get Field: $page->template->fieldgroup[$fieldName]
│     │         → Then: $field->get('property')
│     │
│     └─ Can't get Field object
│        └─ REARCHITECT - need to refactor to get Field object
│
└─ Need computed property on core class (Page, User)?
   └─ Use Pattern 2: addHookProperty
       ↑ Special use case, rarely needed
```

---

## Common Pitfalls

### Pitfall 1: Pattern Mixing

Using different configuration access patterns in the same module causes inconsistent behavior and hard-to-debug errors.

**Example from GuidGenerator Session:**

```php
// WRONG: Mixed patterns
$this->addHookProperty('InputfieldText::generateGuid', ...);

// In getConfigInputfields hook:
$inputfield->generateGuid  // Works via hook

// In addInputfield hook:
$data->generateGuid      // Works via hook

// BUT in saveReady hook:
$inputfield->generateGuid  // DOESN'T WORK - no Inputfield available
```

**Fix:**

```php
// CORRECT: Universal pattern
// In getConfigInputfields hook:
$field->get('generateGuid')

// In saveReady hook:
$field->get('generateGuid')

// Works EVERYWHERE consistently
```

**Warning:** If you use `addHookProperty`, ensure ALL references use the hooked property. OR better yet, use `Field->get()` everywhere for consistency.

---

### Pitfall 2: Wrong Object Context

Not understanding what object type each hook provides leads to accessing properties on wrong object.

**Example:**

```php
// WRONG: Inputfield doesn't store configuration
public function renderHook(HookEvent $event) {
    $inputfield = $event->object;

    // This won't work - config is in Field, not Inputfield
    if($inputfield->generateGuid) {  // Undefined property
        // ...
    }
}
```

**Fix:**

```php
// CORRECT: Get Field object
public function renderHook(HookEvent $event) {
    $inputfield = $event->object;

    // Get the Field object which stores configuration
    $field = $this->fields->get($inputfield->name);
    if(!$field) return;

    if($field->get('generateGuid')) {  // Works
        // ...
    }
}
```

**Warning:** Always check hook documentation or source code to see what type `$event->object` is. Don't assume.

---

### Pitfall 3: Unnecessary addHookProperty

Using `addHookProperty` for basic field configuration adds complexity without benefit.

**Example:**

```php
// AVOID: Using addHookProperty just for field config
$this->addHookProperty('InputfieldText::mySetting', ...);

public function renderHook(HookEvent $event) {
    $inputfield = $event->object;
    if($inputfield->mySetting) {  // Only works if hook exists
        // ...
    }
}
```

**Fix:**

```php
// BETTER: Use Field->get() - simpler, no setup
public function renderHook(HookEvent $event) {
    $inputfield = $event->object;
    $field = $this->fields->get($inputfield->name);

    if($field->get('mySetting')) {  // Always works
        // ...
    }
}
```

**Finding:** Only ONE usage of `addHookProperty` found across entire ProcessWire core - for adding a property to `Page` class, NOT for field configuration.

---

### Pitfall 4: Removing Code Without Full Context

Removing working code without understanding its purpose leads to broken functionality.

**Example from GuidGenerator Session:**

```php
// Original working code:
$this->addHookProperty('InputfieldText::generateGuid', $this, 'addProperty');
$this->addHookProperty('InputfieldText::guidFormat', $this, 'addGuidFormatProperty');

// DANGEROUS: Removing without checking references
// Deleted these lines because "they're not needed"

// Result: getConfigInputfields hook broke
// Because it was using $data->generateGuid and $data->guidFormat
```

**Fix - Investigation Protocol:**

```php
// 1. Read entire file to understand context
// 2. Search all usages:
grep -rn "generateGuid\|guidFormat" GuidGenerator.module

// 3. Understand WHY before removing
//    Was this for backward compatibility?
//    Is this used in other hooks?
//    Does removing it break anything?

// 4. Test pattern change in isolation
//    If removing addHookProperty, test that Field->get() works everywhere

// 5. Update ALL references consistently
//    Don't leave mixed patterns
```

**Warning:** Never remove code without:

- Reading the entire file first
- Searching for all usages
- Understanding the purpose
- Testing the change thoroughly

---

## Best Practices

### DO:

1. **Always use `$field->get('property')`** for reading configuration
   - Universal pattern that works in all contexts
   - No setup required
   - Used throughout ProcessWire core

2. **Use `$field->set('property', $value)`** for writing configuration
   - Saves configuration to database
   - Persists across requests
   - Triggers save hooks

3. **Implement `___getConfigInputfields()`** in Fieldtype when adding configuration
   - Builds configuration UI
   - Receives Field object with existing config
   - Append to parent's inputfields

4. **Access field configuration in hooks** using `$field` parameter
   - Field is available in most hook contexts
   - Don't try to get Field from Inputfield unnecessarily
   - Use `$this->fields->get()` only when Field not directly available

5. **Use helper classes for complex configuration**
   - Like `FieldtypeTextareaHelper`, `SelectableOptionConfig`
   - Separates concerns
   - Follows ProcessWire patterns

6. **Document configuration options**
   - In PHPDoc comments
   - In README files
   - With clear descriptions in admin UI

7. **Test configuration persistence**
   - Verify values save to database
   - Verify values load correctly
   - Test with different page templates

### DON'T:

1. **Don't use `addHookProperty` for field config**
   - Use `Field->get()` instead
   - Only use for computed properties on core classes
   - Adds unnecessary complexity

2. **Don't mix access patterns**
   - Choose one pattern and use it consistently
   - Pattern mixing causes bugs and maintenance issues
   - Makes code harder to understand

3. **Don't store configuration in unrelated places**
   - Always use the Field object
   - Don't create separate storage mechanisms
   - Field->set() saves to correct place

4. **Don't assume Inputfield has config**
   - Inputfield is a temporary render instance
   - Configuration is in Field object
   - Get Field via `$this->fields->get($name)`

5. **Don't bypass hooks unnecessarily**
   - Avoid `setQuietly()` unless explicitly needed
   - Let normal save flow execute
   - Bypassing can cause unexpected behavior

6. **Don't remove code without verification**
   - Search for all usages first: `grep -rn "propertyName"`
   - Understand the purpose before modifying
   - Test changes thoroughly

### Configuration Property Naming

- Properties are typically `lowerCamelCase` for custom properties
- Core properties follow same pattern (e.g., `textformatters`, `contentType`, `parent_id`)
- Boolean flags often use names like `allowXxx` (e.g., `allowUnpub`, `entityEncode`)

---

## Cross-References

### Related Skills

- **processwire-hooks** - Hook types (before/after/replace), HookEvent object, hookable methods
- **processwire-fields** - Field types (text, textarea, file, page), Inputfields, values, dependencies
- **processwire-modules** - Module structure, API access patterns, ready() vs init()
- **processwire-selectors** - Selector syntax for finding pages by field values

### When to Use Each

| Question                           | Use This Skill When              | Use Other Skills For            |
| ---------------------------------- | -------------------------------- | ------------------------------- |
| How do I add configuration UI?     | This skill (Pattern 1)           | processwire-hooks (hook types)  |
| How do I read config in save hook? | This skill (Hook Type Reference) | processwire-hooks (Pages hooks) |
| What field types exist?            | processwire-fields skill         | N/A                             |
| How do I create a hook?            | processwire-hooks skill          | N/A                             |
| How do I build a module?           | processwire-modules skill        | N/A                             |

---

## Summary

The universal and recommended pattern for field configuration in ProcessWire is:

```php
// Read configuration
$value = $field->get('propertyName');

// Set configuration
$field->set('propertyName', $value);
```

This pattern:

- Works in ALL contexts
- Requires NO setup
- Used throughout ProcessWire core
- Is simple and predictable
- Avoids the complexity of `addHookProperty`

Only use `addHookProperty` when:

- Adding computed properties to core classes (Page, User, etc.)
- Creating convenient shortcuts for frequently accessed data
- You understand the full implications and maintenance burden
