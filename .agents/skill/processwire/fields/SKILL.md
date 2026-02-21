---
name: processwire-fields
description: Field types, inputfields, repeaters, images, file handling, field dependencies, and custom field configuration
compatibility: opencode
metadata:
  domain: processwire
  scope: fields
---

## What I Do

I provide comprehensive guidance for ProcessWire fields:

- Fieldtypes and Inputfields architecture
- Common field types (text, textarea, image, file, page reference)
- Repeater fields for grouped repeatable data
- Image manipulation and resizing
- File handling
- Field dependencies (show-if, require-if)
- Field configuration and customization

## When to Use Me

Use this skill when:

- Creating or configuring fields
- Working with images (resizing, cropping, properties)
- Setting up repeater fields
- Implementing field dependencies
- Accessing field values in templates
- Finding pages by field values

---

## Field Architecture

### Fieldtypes

Every field has a **Fieldtype** that defines what content it stores:

- `FieldtypeText` - Single line text
- `FieldtypeTextarea` - Multi-line text
- `FieldtypeImage` - Images
- `FieldtypeFile` - Files
- `FieldtypePage` - Page references
- `FieldtypeRepeater` - Repeatable groups
- `FieldtypeInteger`, `FieldtypeFloat` - Numbers
- `FieldtypeDatetime` - Date/time
- `FieldtypeCheckbox` - Single checkbox
- `FieldtypeOptions` - Select options

### Inputfields

Every field also has an **Inputfield** that handles the admin UI:

- Renders the HTML input
- Processes form submissions
- Some Fieldtypes allow different Inputfields (e.g., Textarea can use CKEditor)

### Plugin Architecture

Both Fieldtypes and Inputfields are plugin modules - you can install additional ones to extend functionality.

---

## Common Field Types

### Text Fields

```php
// Single line text
echo $page->title;
echo $page->headline;

// Check if has value
if($page->subtitle) {
    echo "<h2>$page->subtitle</h2>";
}
```

### Textarea Fields

```php
// Plain textarea
echo $page->body;

// Rich text (CKEditor) - outputs HTML
echo $page->body;  // Already formatted HTML
```

### Integer/Float Fields

```php
echo $page->price;
echo number_format($page->price, 2);

// Find by numeric value
$pages->find("price>=100, price<=500");
```

### Datetime Fields

```php
// Raw timestamp
$timestamp = $page->getUnformatted('date');

// Formatted output (uses field settings)
echo $page->date;

// Custom format
echo date('F j, Y', $page->getUnformatted('date'));

// Find by date
$pages->find("date>=today");
$pages->find("date>=2024-01-01, date<2024-02-01");
```

### Checkbox Fields

```php
if($page->featured) {
    echo "This is featured!";
}

// Find checked
$pages->find("featured=1");

// Find unchecked
$pages->find("featured=0");
```

### Page Reference Fields

```php
// Single page reference
$category = $page->category;
echo $category->title;

// Multiple page references (PageArray)
foreach($page->categories as $cat) {
    echo "<li>$cat->title</li>";
}

// Find by page reference
$pages->find("category=1234");
$pages->find("category.name=featured");
```

---

## Image Fields

### Basic Usage

```php
// Multiple images (PageImages array)
foreach($page->images as $image) {
    echo "<img src='$image->url' alt='$image->description'>";
}

// Single image field (max 1)
if($page->image) {
    echo "<img src='{$page->image->url}'>";
}

// First image from multi-image field
$image = $page->images->first();
if($image) echo "<img src='$image->url'>";

// Random image
$image = $page->images->getRandom();
```

### Check for Images

```php
// Multiple images
if(count($page->images)) {
    // Has images
}

// Single image
if($page->image) {
    // Has image
}
```

### Image Resizing

ProcessWire creates resized images on-the-fly and caches them:

```php
// Proportional width
$thumb = $image->width(300);
echo "<img src='$thumb->url'>";

// Proportional height
$thumb = $image->height(200);

// Exact size (crops to fit)
$thumb = $image->size(300, 200);
echo "<img src='$thumb->url'>";
```

### Cropping Options

```php
// Crop to specific region
$thumb = $image->size(300, 200, 'north');     // Top center
$thumb = $image->size(300, 200, 'southeast'); // Bottom right
$thumb = $image->size(300, 200, 'center');    // Center (default)

// Short versions: nw, n, ne, w, c, e, sw, s, se

// Crop to percentage position
$thumb = $image->size(300, 200, '50%,30%');

// Crop to pixel position
$thumb = $image->size(300, 200, '100,200');
```

### Resize Options

```php
$options = [
    'quality' => 90,           // 1-100
    'upscaling' => false,      // Don't upscale smaller images
    'cropping' => 'center',    // Crop direction
];

$thumb = $image->size(300, 200, $options);
```

### Image Properties

| Property              | Description               |
| --------------------- | ------------------------- |
| `$image->url`         | Full URL                  |
| `$image->filename`    | Server path               |
| `$image->basename`    | Filename only             |
| `$image->description` | Description text          |
| `$image->width`       | Width in pixels           |
| `$image->height`      | Height in pixels          |
| `$image->ext`         | Extension (jpg, png, gif) |
| `$image->filesize`    | Size in bytes             |
| `$image->filesizeStr` | Formatted size            |
| `$image->modified`    | Modified timestamp        |
| `$image->created`     | Created timestamp         |
| `$image->original`    | Original image reference  |
| `$image->tags`        | Space-separated tags      |

### Image Tags

Enable tags in field settings, then:

```php
// Get first image with tag
$image = $page->images->getTag('featured');

// Get all images with tag
$images = $page->images->findTag('gallery');

// Find pages by image tag
$pages->find("images.tags~=sport");
```

---

## File Fields

### Basic Usage

```php
// Multiple files
foreach($page->files as $file) {
    echo "<a href='$file->url'>$file->description</a>";
}

// Single file
if($page->document) {
    echo "<a href='{$page->document->url}'>Download</a>";
}

// First file
$file = $page->files->first();
```

### File Properties

| Property             | Description      |
| -------------------- | ---------------- |
| `$file->url`         | Full URL         |
| `$file->filename`    | Server path      |
| `$file->basename`    | Filename only    |
| `$file->description` | Description text |
| `$file->ext`         | Extension        |
| `$file->filesize`    | Size in bytes    |
| `$file->filesizeStr` | Formatted size   |

### Find by File Properties

```php
// Pages with PDF files
$pages->find("files.ext=pdf");

// Pages with files over 1MB
$pages->find("files.filesize>1000000");
```

---

## Repeater Fields

Repeaters group fields into repeatable items.

### When to Use Repeaters

**Good for:**

- Rate tables, locations, product variations
- Staff directories, galleries with metadata
- Known/manageable quantities

**Not ideal for:**

- Hundreds of items (use child pages instead)
- Items needing their own URLs

### Setup

1. Install Repeater fieldtype (Modules > Fieldtype > Repeater)
2. Create fields to use in repeater
3. Create Repeater field, add subfields in Details tab
4. Add Repeater field to template

### Accessing Repeater Items

```php
// Repeater returns a PageArray
foreach($page->buildings as $building) {
    echo "<h2>$building->title</h2>";
    echo "<p>Height: $building->feet_high feet</p>";
    echo "<p>Floors: $building->num_floors</p>";
}

// Check for items
if(count($page->buildings)) {
    echo "Has " . count($page->buildings) . " buildings";
}

// First item
$first = $page->buildings->first();
```

### Finding Pages by Repeater Values

```php
// Pages with buildings over 500 feet
$pages->find("buildings.height>500");

// Multiple conditions
$pages->find("buildings.year_built=1940, buildings.num_floors>=20");

// Pages with at least one repeater item
$pages->find("buildings.count>0");
```

### Adding Repeater Items via API

```php
// Create new item
$building = $page->buildings->getNew();
$building->title = 'Empire State Building';
$building->feet_high = 1454;
$building->num_floors = 102;
$building->save();
$page->buildings->add($building);
$page->save();
```

### Removing Repeater Items

```php
$building = $page->buildings->first();
$page->buildings->remove($building);
$page->save();
```

### Repeater Template Files

Create `/site/templates/repeater_[fieldname].php`:

```php
// /site/templates/repeater_buildings.php
echo "<h2>$page->title</h2>";
echo "<p>$page->floors floors, $page->height feet</p>";
```

Then render:

```php
foreach($page->buildings as $building) {
    echo $building->render();
}
```

---

## Field Dependencies

Show or require fields based on other field values.

### Show-If Dependencies

Show field only when condition is met:

```php
// In field settings: Setup > Fields > [field] > Input > Visibility
// Or via API:
$inputfield->showIf = "category=1234";
$inputfield->showIf = "featured=1";
$inputfield->showIf = "title!=''";
```

### Require-If Dependencies

Require field only when condition is met:

```php
// Must check "required" first
$inputfield->required = 1;
$inputfield->requiredIf = "publish_date!=''";
```

### Dependency Operators

| Operator | Meaning          |
| -------- | ---------------- |
| `=`      | Equal            |
| `!=`     | Not equal        |
| `>`      | Greater than     |
| `<`      | Less than        |
| `>=`     | Greater or equal |
| `<=`     | Less or equal    |
| `%=`     | Contains         |

### Dependency Examples

```php
// Show if checkbox is checked
showIf = "featured=1"

// Show if text field is not empty
showIf = "title!=''"

// Show if page reference is selected
showIf = "category=1234"

// Multiple conditions (AND)
showIf = "first_name!='', last_name!=''"

// Count-based
showIf = "categories.count>0"
showIf = "categories.count=0"

// Single selection only
showIf = "category=1234, categories.count=1"
```

---

## Options Fields

For select/radio/checkbox options.

### Setup

Create field with FieldtypeOptions, then define options in field settings.

### Accessing Values

```php
// Single select
echo $page->color->title;  // "Red"
echo $page->color->value;  // "red" (option value)
echo $page->color->id;     // Option ID

// Multiple select (OptionsArray)
foreach($page->colors as $color) {
    echo $color->title;
}

// Check if option selected
if($page->color->value == 'red') {
    // Red is selected
}
```

### Finding by Options

```php
$pages->find("color=red");           // By value
$pages->find("color=1234");          // By ID
$pages->find("color.title=Red");     // By title
```

---

## Field Configuration via API

### Creating Fields

```php
$field = new Field();
$field->type = $modules->get('FieldtypeText');
$field->name = 'subtitle';
$field->label = 'Subtitle';
$field->description = 'Optional subtitle';
$field->save();
```

### Adding Fields to Templates

```php
$template = $templates->get('basic-page');
$field = $fields->get('subtitle');
$template->fieldgroup->add($field);
$template->fieldgroup->save();
```

### Field Context Settings

Override field settings per template:

```php
$template = $templates->get('product');
$field = $fields->get('title');
$context = $template->fieldgroup->getFieldContext($field);
$context->label = 'Product Name';
$context->required = 1;
$fields->saveFieldgroupContext($field, $template->fieldgroup);
```

---

## Common Patterns

### Fallback Values

```php
// Use headline, fall back to title
$headline = $page->headline ?: $page->title;

// Or with get()
$headline = $page->get('headline|title');
```

### Formatted vs Unformatted

```php
// Formatted (for output)
echo $page->body;  // Processed through text formatters

// Unformatted (for manipulation)
$page->of(false);  // Turn off output formatting
$raw = $page->body;
$page->body = $modified;
$page->save();
$page->of(true);   // Turn back on
```

### Checking Field Existence

```php
// Check if template has field
if($page->template->hasField('sidebar')) {
    echo $page->sidebar;
}

// Check if field has value
if($page->sidebar) {
    echo $page->sidebar;
}
```

---

## Pitfalls / Gotchas

1. **Single vs multi-image behavior**: Single-image fields return Pageimage directly; multi-image fields return Pageimages array. Only applies when output formatting is ON.

2. **Output formatting**: Some field operations require output formatting OFF:

   ```php
   $page->of(false);
   $page->body = 'new value';
   $page->save();
   ```

3. **Repeater item creation**: Use `getNew()`, not `new Page()`:

   ```php
   $item = $page->repeater_field->getNew();
   ```

4. **Field names are case-sensitive**: `$page->Title` won't match `title` field.

5. **Dependency limitations**:
   - No commas in values
   - No `~=` operator
   - No subfields except `.count`
   - OR-groups not supported

6. **Image resizing caches**: Resized images are cached. Clear cache if originals change or resize options change.

7. **Repeater scalability**: Don't use repeaters for hundreds of items - use child pages instead.
