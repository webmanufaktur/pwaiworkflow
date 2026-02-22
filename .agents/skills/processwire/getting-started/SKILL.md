---
name: processwire-getting-started
description: Installation, upgrade, directory structure, pages/templates/fields concepts, API access patterns, and foundational ProcessWire development guidance
compatibility: opencode
metadata:
  domain: processwire
  scope: getting-started
---

## What I Do

I provide comprehensive guidance for getting started with ProcessWire CMS/CMF, including:

- Installing ProcessWire (ZIP, Git, Composer)
- Upgrading between versions
- Understanding the directory structure
- Core concepts: Pages, Templates, Fields
- API access patterns and template file development
- Basic tutorials and patterns

## When to Use Me

Use this skill when:

- Setting up a new ProcessWire installation
- Upgrading an existing ProcessWire site
- Learning ProcessWire fundamentals
- Understanding the page/template/field architecture
- Writing your first template files
- Accessing the API from templates or external scripts

---

## Installation

### Requirements

- Unix or Windows-based web server running Apache (or 100% compatible)
- PHP 8.x recommended (PHP 7.1+ supported)
- PDO database support in PHP
- MySQL 5.6+ or MariaDB equivalent
- Apache `mod_rewrite` enabled with `.htaccess` support
- PHP's GD 2 library or ImageMagick

### Installation from ZIP

1. Download the latest ProcessWire ZIP from the official site
2. Unzip to your web server location
3. Load the URL in your browser to initiate the installer
4. Follow the installer prompts

### Installation from GitHub

```bash
git clone https://github.com/processwire/processwire.git
```

Then load the location in your browser to run the installer.

### Installation with Composer

```bash
# New project
composer create-project processwire/processwire

# Into existing project (places in /vendor/)
composer require processwire/processwire
```

---

## Upgrading ProcessWire

### Best Practices Before Upgrading

1. Backup your database and all site files
2. Test upgrades on staging before production
3. Login as superuser before upgrading
4. Temporarily enable debug mode during upgrade
5. Verify 3rd party module compatibility

### General Upgrade Process

Replace these files/directories from the new version:

- `/wire/` (required) - delete old, add new
- `/index.php` (if changed between versions)
- `/.htaccess` (if changed - check for security updates)

After replacing, reload the admin in your browser. You may see update messages - keep reloading (up to 5 times) until they disappear.

**Tip:** Rename old directories instead of deleting (e.g., `/.wire-2.7.2/`) for quick rollback. Ensure renamed dirs are not HTTP accessible.

### Troubleshooting Upgrades

- Hit reload multiple times after upgrade (up to 5)
- If errors persist, remove and re-upload `/wire/` completely
- Check `/site/assets/logs/errors.txt` for details
- Enable debug mode for verbose error messages

### Enabling Debug Mode

Edit `/site/config.php`:

```php
$config->debug = true;
```

**Warning:** Never leave debug mode on in production.

### 2.x to 3.x Upgrade Notes

ProcessWire 3.x uses the `ProcessWire` namespace. If you see namespace-related errors:

1. Add namespace to affected files:

```php
<?php namespace ProcessWire;
```

2. To skip file compilation, add `FileCompiler=0` anywhere in the file

3. To disable compilation entirely (not recommended):

```php
$config->moduleCompile = false;
$config->templateCompile = false;
```

---

## Directory Structure

ProcessWire keeps your site files separate from core files for easy upgrades.

### Root Directory

| File           | Purpose                          |
| -------------- | -------------------------------- |
| `/.htaccess`   | Apache directives                |
| `/index.php`   | Bootstrap file                   |
| `/install.php` | Installer (delete after install) |

### Core Directory (`/wire/`)

| Directory                | Purpose                      |
| ------------------------ | ---------------------------- |
| `/wire/core/`            | ProcessWire core             |
| `/wire/modules/`         | Default plugin modules       |
| `/wire/templates-admin/` | Admin panel templates/assets |

**Note:** To upgrade, replace the entire `/wire/` directory.

### Site Directory (`/site/`)

| Path                       | Purpose                                      |
| -------------------------- | -------------------------------------------- |
| `/site/config.php`         | Site configuration                           |
| `/site/assets/`            | Writable assets (files, images, cache, logs) |
| `/site/modules/`           | Site-specific modules                        |
| `/site/templates/`         | Your template files                          |
| `/site/templates/styles/`  | CSS files                                    |
| `/site/templates/scripts/` | JavaScript files                             |

---

## Core Concepts

### Pages

Almost everything in ProcessWire is a Page. A Page is:

- A storage container with a unique URL
- Defined by a template (which determines its fields)
- Part of a hierarchical family tree structure

**Key Points:**

- Every Page has a parent (except homepage)
- Every Page can have children
- URL structure mirrors the page hierarchy: `/about/staff/` is a child of `/about/`
- Pages can be queried by any property, not just location
- Pages can reference each other (one-to-many, many-to-many)
- Users, roles, permissions, and languages are also Pages

**Page Types:**

- Regular content pages
- Users (`template=user`)
- Roles (`template=role`)
- Permissions (`template=permission`)
- Languages (`template=language`)

### Templates

A Template defines:

- What fields are available on pages using it
- The page's "type" (e.g., "product", "blog-post")
- Access control rules
- URL behavior (pagination, URL segments, HTTPS)
- Caching settings
- Family rules (allowed children/parents)

**Template Files:**

- Located in `/site/templates/`
- Named after the template (e.g., `product.php` for "product" template)
- Receive API variables and output page content
- Not required for pages that don't need front-end output

### Fields

Fields store content on pages:

- Each field has a **Fieldtype** (Text, Textarea, Image, Page, etc.)
- Each field has an **Inputfield** (how it's edited in admin)
- Fields are reusable across multiple templates
- Fieldtypes and Inputfields are plugin modules (extensible)

**Common Fields:**

- `title` - Page title (on almost every template)
- `body` - Multi-line body copy
- Custom fields you create

---

## API Access

ProcessWire provides several ways to access the API. All methods access the same thing:

```php
// In template files (most common)
$page                    // Direct variable
page()                   // Function API
wire('page')             // Works anywhere
wire()->page             // IDE-friendly

// In Wire-derived classes (modules)
$this->page              // From class context
$this->wire('page')      // Preferred in modules
$this->wire()->page      // IDE-friendly

// From any API variable
$pages->wire()->page     // Access other API vars
```

### Enabling the Functions API

Add to `/site/config.php`:

```php
$config->useFunctionsAPI = true;
```

**Benefits of Functions API:**

- Always in scope (works inside functions)
- Cannot be accidentally overwritten
- Self-documenting for IDEs
- Provides shortcuts (e.g., `pages('/path/')` equals `$pages->get('/path/')`)

### Common API Variables

| Variable     | Purpose                          |
| ------------ | -------------------------------- |
| `$page`      | Current page being viewed        |
| `$pages`     | Find/get/save all pages          |
| `$user`      | Current logged-in user           |
| `$users`     | All users                        |
| `$input`     | GET, POST, COOKIE, URL segments  |
| `$sanitizer` | Data sanitization                |
| `$session`   | Session management, login/logout |
| `$config`    | Site configuration               |
| `$fields`    | All custom fields                |
| `$templates` | All templates                    |
| `$modules`   | All modules                      |
| `$log`       | Logging                          |

---

## Template Files

Template files are PHP scripts that output page content.

### Basic Usage

```php
<html>
<head>
    <title><?=$page->title?></title>
</head>
<body>
    <h1><?=$page->title?></h1>
    <div><?=$page->body?></div>
</body>
</html>
```

### Outputting Child Pages

```php
<ul>
<?php foreach($page->children as $child): ?>
    <li><a href="<?=$child->url?>"><?=$child->title?></a></li>
<?php endforeach; ?>
</ul>

// Or shorter syntax:
<ul><?=$page->children->each("<li><a href='{url}'>{title}</a></li>")?></ul>
```

### Finding Other Pages

```php
// Get a specific page by path
$contact = $pages->get("/about/contact/");
echo $contact->address;

// Find multiple pages
$features = $pages->find("featured=1");

// Find with multiple conditions
$items = $pages->find("template=product, featured=1, limit=3, sort=-date");

// Find children of a specific page
$posts = $pages->get("/blog/")->children("limit=10, sort=-created");

// Find descendants (all levels)
$allPosts = $pages->get("/blog/")->find("template=blog-post");
```

### Selectors in Templates

```php
// Featured press releases, newest first, limit 3
$features = $pages->find("template=press_release, featured=1, limit=3, sort=-date");

foreach($features as $feature) {
    echo "<h3><a href='$feature->url'>$feature->title</a></h3>";
    echo "<span class='date'>$feature->date</span>";
    echo "<p>$feature->summary</p>";
}
```

---

## Tutorial: Hello Worlds

### Step 1: Create Template File

Create `/site/templates/planet.php`:

```php
<html>
<head>
    <title><?=$page->title?></title>
</head>
<body>
    <h1><?=$page->title?></h1>
    <h2>Type: <?=$page->planet_type?>, Age: <?=$page->planet_age?> years</h2>
    <p><?=$page->planet_summary?></p>
</body>
</html>
```

### Step 2: Add Template in Admin

1. Go to Setup > Templates
2. Click "Add New Template"
3. Select your "planet" template file
4. Click "Add Template"

### Step 3: Create Fields

1. Go to Setup > Fields
2. Create `planet_type` (Text)
3. Create `planet_age` (Text)
4. Create `planet_summary` (Textarea)

### Step 4: Add Fields to Template

1. Go to Setup > Templates > planet
2. Add the three fields
3. Save

### Step 5: Create Pages

1. Go to Pages
2. Create new page under Home
3. Select "planet" template
4. Fill in content and publish

---

## Multi-Site Support

ProcessWire supports multiple sites from one installation.

### Option 1: Multiple Databases (Recommended)

Each site has its own `/site-name/` directory and database.

**Setup:**

1. Install ProcessWire to a temp directory with a new database
2. Move `/tmp/site/` to `/site-yoursite/` in main installation
3. Copy `/wire/index.config.php` to `/index.config.php`
4. Edit `/index.config.php` to map domains to site directories

**Advantages:**

- Sites are independent and organized
- Built into core (no modules needed)
- Easy to move/backup individual sites

### Option 2: Single Database (Module Required)

Use the Multisite module for shared database/templates.

**Advantages:**

- Sites can share data
- Shared user accounts
- Shared templates and fields

---

## Common Patterns

### Accessing Fields

```php
// Simple field access
echo $page->title;
echo $page->body;

// Check if field has value
if($page->headline) {
    echo $page->headline;
} else {
    echo $page->title;
}

// Shorthand with pipe (first non-empty)
echo $page->get('headline|title');
```

### Navigation

```php
// Breadcrumbs
foreach($page->parents as $parent) {
    echo "<a href='$parent->url'>$parent->title</a> / ";
}
echo $page->title;

// Main navigation
foreach($pages->get("/")->children as $item) {
    $class = $item->id == $page->rootParent->id ? 'current' : '';
    echo "<a class='$class' href='$item->url'>$item->title</a>";
}

// Subnav
if($page->numChildren) {
    foreach($page->children as $child) {
        echo "<a href='$child->url'>$child->title</a>";
    }
}
```

### Checking Page Context

```php
// Is this the homepage?
if($page->id == 1) { }

// Is this page editable?
if($page->editable()) { }

// Is user logged in?
if($user->isLoggedin()) { }

// Does user have role?
if($user->hasRole('editor')) { }
```

---

## Pitfalls / Gotchas

1. **Don't overwrite API variables:**

   ```php
   // BAD - overwrites $page
   foreach($pages->find("...") as $page) { }

   // GOOD
   foreach($pages->find("...") as $p) { }
   ```

2. **Delete install files after installation:**
   - Remove `/install.php`
   - Remove `/site/install/` directory

3. **Debug mode in production:**
   - Never leave `$config->debug = true` on production sites

4. **Template file required for output:**
   - Pages without a corresponding template file return 404

5. **Field names are case-sensitive:**
   - `$page->Title` won't work if the field is `title`

6. **Namespace in PW 3.x:**
   - Add `<?php namespace ProcessWire;` at the top of custom PHP files
