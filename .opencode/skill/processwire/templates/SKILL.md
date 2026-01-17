---
name: processwire-templates
description: Output strategies (direct, delayed, markup regions), URL segments, pagination, file includes, and front-end rendering patterns
compatibility: opencode
metadata:
  domain: processwire
  scope: front-end
---

## What I Do

I provide comprehensive guidance for ProcessWire front-end template development:

- Output strategies: direct, delayed, and markup regions
- URL segments for routing within templates
- Pagination with MarkupPagerNav
- File includes and bootstrapping ProcessWire
- Front-end rendering patterns and best practices

## When to Use Me

Use this skill when:

- Choosing an output strategy for a new site
- Setting up template files with \_init.php and \_main.php
- Using markup regions for flexible layouts
- Implementing URL segments for custom routing
- Adding pagination to search results or listings
- Bootstrapping ProcessWire from external scripts

---

## Output Strategies Overview

ProcessWire offers three main output strategies:

| Strategy           | Best For                              | Complexity |
| ------------------ | ------------------------------------- | ---------- |
| **Direct Output**  | Simple sites, single templates        | Low        |
| **Delayed Output** | Complex sites, multiple regions       | Medium     |
| **Markup Regions** | Flexible layouts, HTML-first approach | Low-Medium |

---

## Direct Output

The simplest approach—output markup directly in template files.

### Basic Example

`/site/templates/basic-page.php`:

```php
<html>
<head>
    <title><?=$page->title?></title>
</head>
<body>
    <h1><?=$page->title?></h1>
    <?=$page->body?>
</body>
</html>
```

### Using Include Files

Split common markup into reusable files:

`/site/templates/_head.php`:

```php
<html>
<head>
    <title><?=$page->title?></title>
</head>
<body>
    <h1><?=$page->title?></h1>
```

`/site/templates/_foot.php`:

```php
</body>
</html>
```

`/site/templates/basic-page.php`:

```php
<?php
include("./_head.php");
echo $page->body;
include("./_foot.php");
```

### Automatic File Includes

Configure in `/site/config.php`:

```php
$config->prependTemplateFile = '_head.php';
$config->appendTemplateFile = '_foot.php';
```

Now template files only need the unique content:

```php
<?php
echo $page->body;
```

---

## Delayed Output

Populate variables first, output everything at the end.

### Basic Structure

`/site/templates/_init.php` (prepended):

```php
<?php
$headline = $page->get("headline|title");
$bodycopy = $page->body;
$sidebar = $page->sidebar;
$subnav = $page->children;
```

`/site/templates/basic-page.php`:

```php
<?php
$bodycopy .= $page->comments->render();
```

`/site/templates/_main.php` (appended):

```php
<!DOCTYPE html>
<html>
<head>
    <title><?=$headline?></title>
</head>
<body>
    <div id="bodycopy">
        <h1><?=$headline?></h1>
        <?=$bodycopy?>
    </div>
    <div id="sidebar">
        <?=$sidebar?>
        <?php if(count($subnav)): ?>
        <ul class="nav">
            <?php foreach($subnav as $child): ?>
            <li><a href="<?=$child->url?>"><?=$child->title?></a></li>
            <?php endforeach; ?>
        </ul>
        <?php endif; ?>
    </div>
</body>
</html>
```

### Configuration

```php
// /site/config.php
$config->prependTemplateFile = '_init.php';
$config->appendTemplateFile = '_main.php';
```

### Using region() Function

Alternative to variables—IDE-friendly and always in scope:

```php
// _init.php - define with default
region('bodycopy', $page->body);

// basic-page.php - populate
region('bodycopy', "<h2>$page->headline</h2>" . $page->body);

// _main.php - output
echo region('bodycopy');
```

Enable with:

```php
$config->useFunctionsAPI = true;
```

---

## Markup Regions

HTML-based approach combining direct output simplicity with delayed output power.

### Enable Markup Regions

```php
// /site/config.php
$config->useMarkupRegions = true;
$config->appendTemplateFile = '_main.php';
```

### How It Works

1. **Region definitions**: HTML tags with `id` attributes in `_main.php`
2. **Region actions**: Template files output tags with same IDs to populate/modify regions

### Region Definition Example

`/site/templates/_main.php`:

```html
<!DOCTYPE html>
<html lang="en">
  <head id="html-head">
    <meta charset="utf-8" />
    <title id="html-title"><?=$page->title?></title>
  </head>
  <body id="html-body">
    <div id="masthead">
      <ul id="topnav">
        <?php foreach($pages->get('/')->children as $item): ?>
        <li>
          <a href="<?=$item->url?>"><?=$item->title?></a>
        </li>
        <?php endforeach; ?>
      </ul>
    </div>
    <div id="content">
      <h1 id="headline"><?=$page->title?></h1>
      <div id="bodycopy"><?=$page->body?></div>
      <div id="sidebar" pw-optional></div>
    </div>
    <div id="footer">
      <p>Copyright <?=date('Y')?></p>
    </div>
  </body>
</html>
```

### Region Action Attributes

| Attribute    | Behavior                         |
| ------------ | -------------------------------- |
| `pw-replace` | Replace region content (default) |
| `pw-append`  | Append to region                 |
| `pw-prepend` | Prepend to region                |
| `pw-before`  | Insert before region             |
| `pw-after`   | Insert after region              |

### Populating Regions

`/site/templates/basic-page.php`:

**Replace content:**

```html
<div id="bodycopy">
  <p>This replaces the default bodycopy content.</p>
</div>
```

**Append to region (outer HTML):**

```html
<ul class="subnav" pw-append="sidebar">
  <?=$page->children->each("
  <li><a href="{url}">{title}</a></li>
  ")?>
</ul>
```

**Prepend to region (inner HTML only):**

```html
<div id="sidebar" pw-prepend>
  <h3>Sidebar Title</h3>
</div>
```

**Insert after element:**

```html
<h2 pw-after="headline"><?=$page->summary?></h2>
```

**Add to head:**

```html
<link rel="stylesheet" href="/custom.css" pw-append="html-head" />
```

### Optional Regions

Use `pw-optional` for regions that should be removed if empty:

```html
<div id="sidebar" pw-optional></div>
```

### Adding/Removing Classes

Classes merge automatically:

```html
<!-- Definition -->
<ul id="mylist" class="foo">
  ...
</ul>

<!-- Action - adds "bar" class -->
<ul id="mylist" class="bar" pw-append>
  <li>New item</li>
</ul>

<!-- Result -->
<ul id="mylist" class="foo bar">
  ...
</ul>
```

Remove class with minus prefix:

```html
<ul id="mylist" class="-foo bar" pw-append>
  ...
</ul>
```

### Debugging Regions

Add this comment to see region debug info:

```html
<!--PW-REGION-DEBUG-->
```

---

## URL Segments

Enable template files to act as URL routers.

### Enable URL Segments

1. Go to Setup > Templates > [template] > URLs
2. Check "Allow URL Segments"

Or configure max segments in `/site/config.php`:

```php
$config->maxUrlSegments = 4;  // default
```

### Accessing URL Segments

For URL `/products/hammer/photos/gallery/`:

```php
$input->urlSegment1;      // "photos"
$input->urlSegment2;      // "gallery"
$input->urlSegment(1);    // "photos"
$input->urlSegmentStr;    // "photos/gallery"
$input->urlSegmentStr();  // "photos/gallery"
```

### Routing Example

```php
// Throw 404 if more than 1 segment
if(strlen($input->urlSegment2)) throw new Wire404Exception();

switch($input->urlSegment1) {
    case '':
        // Main content (no segment)
        echo $page->body;
        break;

    case 'photos':
        // Photo gallery
        include('./_photos.php');
        break;

    case 'map':
        // Location map
        include('./_map.php');
        break;

    default:
        // Unknown segment - 404
        throw new Wire404Exception();
}
```

### Using urlSegmentStr

Check multiple segments at once:

```php
if($input->urlSegmentStr === 'photos/primary') {
    // Primary photo
} else if($input->urlSegmentStr === 'photos/secondary') {
    // Secondary photo
} else if(strlen($input->urlSegmentStr)) {
    throw new Wire404Exception();
}
```

### URL Segment Whitelist

Define allowed segments in template settings (Setup > Templates > URLs) to automatically 404 on unknown segments.

---

## Pagination

Display large result sets across multiple pages.

### Enable Pagination

1. Install MarkupPagerNav module (Modules > Core > Markup)
2. Enable for template: Setup > Templates > [template] > URLs > "Allow Page Numbers"

### Basic Usage

```php
$results = $pages->find("template=product, limit=10, sort=title");

// Render results with automatic pagination
echo $results->render();

// Or render just pagination links
echo $results->renderPager();
```

### Custom Pagination

```php
$results = $pages->find("template=blog-post, limit=10, sort=-date");
$pagination = $results->renderPager();

echo $pagination;  // Top pagination

echo "<ul class='posts'>";
foreach($results as $post) {
    echo "<li>";
    echo "<h2><a href='{$post->url}'>{$post->title}</a></h2>";
    echo "<p>{$post->summary}</p>";
    echo "</li>";
}
echo "</ul>";

echo $pagination;  // Bottom pagination
```

### Current Page Number

```php
$pageNum = $input->pageNum;  // Current page number (1-based)

echo "<h1>Results (Page $pageNum)</h1>";
```

### Pagination Options

```php
echo $results->renderPager([
    'numPageLinks' => 10,
    'nextItemLabel' => 'Next &raquo;',
    'previousItemLabel' => '&laquo; Prev',
    'listMarkup' => "<ul class='pagination'>{out}</ul>",
    'itemMarkup' => "<li class='{class}'>{out}</li>",
    'linkMarkup' => "<a href='{url}'>{out}</a>",
    'currentItemClass' => 'active',
    'separatorItemLabel' => '...',
]);
```

### Prevent Auto-Pagination

Use `start=0` to prevent automatic pagination adjustment:

```php
// Always get first 10 results, regardless of page number
$featured = $pages->find("featured=1, start=0, limit=10");
```

### Pagination CSS

```css
.MarkupPagerNav {
  margin: 1em 0;
  padding: 0;
}
.MarkupPagerNav li {
  display: inline-block;
  margin: 0 2px;
}
.MarkupPagerNav li a {
  display: block;
  padding: 5px 10px;
  background: #eee;
  text-decoration: none;
}
.MarkupPagerNav li.MarkupPagerNavOn a,
.MarkupPagerNav li a:hover {
  background: #333;
  color: #fff;
}
```

---

## Bootstrapping ProcessWire

Use ProcessWire's API from external PHP scripts.

### Basic Bootstrap

```php
<?php
include("/path/to/processwire/index.php");

// API is now available
$products = $pages->find("template=product");
foreach($products as $product) {
    echo $product->title . "\n";
}
```

### With Namespace (PW 3.x)

```php
<?php namespace ProcessWire;

include("/path/to/processwire/index.php");

$contact = $pages->get("/about/contact/");
echo $contact->address;
```

### Command-Line Script

```php
#!/usr/bin/php
<?php namespace ProcessWire;

include("/var/www/site/index.php");

// Generate sitemap
function listPage($page, $level = 0) {
    echo str_repeat("  ", $level) . $page->title . "\n";
    foreach($page->children as $child) {
        listPage($child, $level + 1);
    }
}

listPage($pages->get("/"));
```

### Alternative API Access

```php
// All equivalent after bootstrap
$page = $pages->get("/about/");
$page = pages("/about/");
$page = wire('pages')->get("/about/");
$page = $wire->pages->get("/about/");
```

---

## File Include Functions

### wireIncludeFile()

Include file with variable isolation:

```php
wireIncludeFile('./_header.php', [
    'title' => $page->title,
    'showNav' => true
]);
```

### wireRenderFile()

Render file and return as string:

```php
$header = wireRenderFile('./_header.php', [
    'title' => $page->title
]);

echo $header;
```

---

## Common Patterns

### Conditional Layouts

```php
// _init.php
$layout = '_main.php';

if($page->template == 'admin-page') {
    $layout = '_admin.php';
} else if($page->template == 'ajax-handler') {
    $layout = '';  // No layout wrapper
}

// basic-page.php
if($layout) include($layout);
```

### Template-Specific Includes

```php
// Include template-specific file if it exists
$customFile = "./_custom/{$page->template}.php";
if(file_exists($config->paths->templates . ltrim($customFile, './'))) {
    include($customFile);
}
```

### JSON API Response

```php
// api-endpoint.php
header('Content-Type: application/json');

$data = [
    'title' => $page->title,
    'body' => $page->body,
    'children' => []
];

foreach($page->children as $child) {
    $data['children'][] = [
        'title' => $child->title,
        'url' => $child->url
    ];
}

echo json_encode($data);
exit;  // Skip _main.php
```

---

## Pitfalls / Gotchas

1. **Prepend/append order matters:**
   - `prependTemplateFile` runs before your template
   - `appendTemplateFile` runs after your template
   - Variables set in prepend are available in template and append

2. **Markup regions require `<html>` tag:**
   - Region actions must be output before `<html>`
   - Region definitions must be inside `<html>...</html>`

3. **URL segments vs page names:**
   - Real child pages take precedence over URL segments
   - Avoid segment names that might conflict with page names

4. **Pagination and template caching:**
   - Works with caching (up to 999 pages cached)
   - GET/POST vars are not cached—don't use template cache for search results

5. **Exit to skip appended files:**

   ```php
   // For JSON/AJAX responses
   echo json_encode($data);
   exit;  // Prevents _main.php from loading
   ```

6. **Debug mode for regions:**
   - Add `<!--PW-REGION-DEBUG-->` to see what's happening
   - Use `<!--#regionid-->` after closing tags to help PW find region ends
