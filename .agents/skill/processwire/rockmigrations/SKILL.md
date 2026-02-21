---
name: rockmigrations
description: Generate ProcessWire field definitions and migration code using RockMigrations
license: MIT
compatibility: opencode
metadata:
  audience: processwire-developers
  language: php
  scope: fields-templates
  pw-version: "3.0.254+"
---

## Overview

Generate ProcessWire field definitions, templates, and migrations.
**Access**: `$rm = rockmigrations();`

## Core Migration Patterns

### Basic Migration

```php
$rm->migrate([
  'fields' => [],    // Define fields here (Top-Level preferred)
  'templates' => [], // Assign fields to templates
]);
```

### Critical: `fields` vs `fields-`

- **`fields`**: **ADDS** all fields. Use for incremental updates.
- **`fields-`**: **ADDS** listed fields; **REMOVES** unlisted fields.Any field not listed is removed from the template. Use for initial template setup.
  - _Rule_: Always list ALL fields you want to keep in the template when using `fields-`.

### Project Defaults (`rm-defaults`)

Sets German defaults, AdminThemeUikit tweaks, and installs language modules.

```php
$rm->setPagenameReplacements('de');
$rm->setModuleConfig('AdminThemeUikit', ['toggleBehavior' => 1]); // Consistent clicks
$rm->setModuleConfig('ProcessPageList', ['useTrash' => true]);
$rm->setLanguageTranslations('DE');
$rm->installModule('LanguageSupportFields'); // ... plus PageNames, Tabs
$rm->setFieldData('title', ['type' => 'textLanguage']);
```

### Common Mistakes

```php
// DON'T - watch() is for file/module watching only
$rm->watch($rm->createRole('editor', ['page-edit']));

// DO - direct API call
$rm->createRole('editor', ['page-edit']);
```

## Field Definitions

### Standard Properties

All fields support these keys. Omitted from examples for brevity.

```php
'label' => 'My Label',
'description' => 'Help text',
'notes' => 'Notes below input',
'icon' => 'cube',
'columnWidth' => 50,      // 0-100%
'required' => 1,
'showIf' => 'field=1',    // Conditional visibility
'tags' => 'groupname',    // Field grouping
```

### Basic Types

```php
// Text / TextLanguage
'my_text' => ['type' => 'text', 'label' => 'Title'],

// Textarea / TextareaLanguage
'my_textarea' => ['type' => 'textarea', 'rows' => 5],

// Integer
'my_int' => ['type' => 'integer'],

// URL
'my_url' => ['type' => 'URL', 'textformatters' => ['TextformatterEntities']],

// Checkbox (1/0)
'my_check' => ['type' => 'checkbox', 'label' => 'Active?'],

// Toggle (Yes/No)
'my_toggle' => [
  'type' => 'toggle',
  'formatType' => 0,       // 0=Int
  'labelType' => 0,        // 0=Yes/No
  'defaultOption' => 'yes'
],

// RockMoney
'my_price' => ['type' => 'RockMoney'],

// RockIcons
'my_icon' => ['type' => 'text', 'inputfieldClass' => 'InputfieldRockIcons'],
```

### Date \& Time

```php
'my_date' => [
  'type' => 'datetime',
  'dateOutputFormat' => 'd.m.Y H:i',
  'dateInputFormat' => 'j.n.y',
  'timeInputFormat' => 'H:i',
  'datepicker' => 1, // Focus
  'defaultToday' => 1,
],
```

### Rich Text (WYSWYG)

```php
// CKEditor
'my_body' => [
  'type' => 'textarea',
  'inputfieldClass' => 'InputfieldCKEditor',
  'contentType' => 2,  // 2=HTML content type
  'formatTags' => 'p;h2;h3;h4',
  'toggles' => [3],    // 3=CleanNBSP toggle
  'toolbar' => 'Format, Bold, Italic, BulletedList, PWLink, Source', // Simplified
],

// TinyMCE
'my_tiny' => [
  'type' => 'textarea',
  'inputfieldClass' => 'InputfieldTinyMCE',
  'contentType' => 2,  // 2=HTML content type
  'settingsFile' => '/site/modules/RockMigrations/TinyMCE/simple.json',
],
```

### Selection \& Relations

```php
// Options
'my_options' => [
  'type' => 'options',
  'options' => [
    1 => 'Option A',
    2 => 'Option B|With Description',
  ],
],

// Page Reference
'my_page_ref' => [
  'type' => 'page',
  'derefAsPage' => 1, // 0=PageArray, 1=Page, 2=PageOrFalse
  'inputfield' => 'InputfieldPageListSelect', // or Select, Radios, AsmSelect
  'findPagesSelector' => 'template=basic-page',
  'labelFieldName' => 'title',
],
```

### Files \& Media

```php
// Image
'my_image' => [
  'type' => 'image',
  'maxFiles' => 1,
  'extensions' => 'jpg jpeg png svg',
  'maxSize' => 3, // MP
  'okExtensions' => ['svg'],
  'gridMode' => 'grid',
],

// Generic File
'my_file' => [
  'type' => 'file',
  'extensions' => 'pdf xlsx',
  'maxFiles' => 10,
],

// RockImagePicker
'my_picker' => [
  'type' => 'RockImagePicker',
  'sourcepage' => 1,          // Source Page ID
  'sourcefield' => 'images',  // Source Field Name
],
```

### Containers \& Complex Types

```php
// Repeater (Auto-creates 'repeater_my_rep' template)
'my_rep' => [
  'type' => 'FieldtypeRepeater',
  'fields' => ['title', 'sub_field'],
  'repeaterTitle' => '#n: {title}',
  'familyFriendly' => 1,
],

// FieldsetPage (Virtual page in field)
'my_fieldset' => [
  'type' => 'FieldtypeFieldsetPage',
  'fields' => [
    'title' => ['required' => 0],
    'nested_field',
  ],
],

// Fieldset (Open/Close pair)
'grp_open' => ['type' => 'FieldsetOpen'],
'grp_close' => ['type' => 'FieldsetClose'],

// RockGrid
'my_grid' => [
  'type' => 'RockGrid',
  'grid' => 'col-12', // Class definition
],

// RockPageBuilder
'my_builder' => ['type' => 'RockPageBuilder'],
```

## Access Control \& Logic

### Roles \& Permissions

Apply to fields or templates.

```php
'editRoles' => ['editor', 'admin'],
'viewRoles' => ['guest', 'editor'],
'createRoles' => ['admin'], // Templates only
'addRoles' => ['admin'],    // Templates only (add children)
```

Creating roles:

```php
$rm->createRole('editor', ['page-edit', 'page-view']);
$rm->createRole('admin', ['page-edit', 'page-view', 'page-create']);
```

### Template Family \& Sort

```php
'product' => [
  'fields' => ['title', 'price'],
  'family' => 'ecommerce',        // Group templates
  'sortfield' => '-created',      // Descending date
  'noChildren' => 1,
  'parentTemplates' => ['home'],
],
```

### Conditional Visibility (showIf)

- **Syntax**: `field=value`, `field!=value`, `field>5`
- **Logic**: Comma `,` = AND; Pipe `|` = OR.

```php
// Show if 'has_url' is checked AND 'type' is NOT 'internal'
'showIf' => 'has_url=1, type!=internal',
```

## Best Practices

1. **Top-Level Definitions**: Define ALL fields in the `fields` array first.
2. **Reference Names**: Only use field names strings in `templates` array.
3. **Naming**: `snake_case` for fields, `kebab-case` for templates.
4. **Repeaters**: Always include `title` in `fields`.
5. **Clean Migrations**: Avoid inline field definitions in template arrays.
