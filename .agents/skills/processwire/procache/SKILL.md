---
name: processwire-procache
description: ProCache module for ProcessWire - page caching, CDN integration, CSS/JS minification, HTML minification, file merging, SCSS/LESS compilation
compatibility: opencode
metadata:
  domain: processwire
  scope: procache
---

## What I Do

I provide comprehensive guidance for ProCache - the ultimate caching and optimization module for ProcessWire:

- Page caching configuration and management
- CDN setup and integration
- CSS/JS merging and minification
- HTML output minification
- SCSS/LESS compilation
- Cache clearing strategies
- Custom cache rules via hooks

## When to Use Me

Use this skill when:

- Setting up ProCache for the first time
- Configuring page caching for templates
- Setting up CDN integration
- Merging and minifying CSS/JS assets
- Compiling SCSS/LESS files
- Hooking into cache behavior
- Troubleshooting cache issues

---

## Getting Started

### Accessing ProCache

ProCache is available via the `$procache` API variable:

```php
$procache = $this->procache; // in modules
$procache = $procache; // in templates
```

---

## Page Caching

### Enabling Cache for Templates

Configure cache time per template in ProCache settings:

```php
// Get cache time for a template
$cacheTime = $procache->getCacheTime($template);

// Get cache time for all templates
$allCacheTimes = $procache->getCacheTime();

// Check if page is cacheable
if ($procache->isPageCacheable($page)) {
    // Page is configured for caching
}
```

### Manual Cache Control

```php
// Turn cache on/off at runtime
$procache->cacheOn(true);  // Enable caching
$procache->cacheOn(false); // Disable caching

// Check cache status
$isOn = $procache->cacheOn;
```

### Cache File Operations

```php
// Check if page has cached file
$hasCache = $procache->hasCacheFile($page);

// Get page cache info
$info = $procache->pageInfo($page);
// Returns: [
//   'file' => '/path/to/cache/file.html',
//   'time' => 1234567890,
//   'expires' => 1234571490
// ]

// Get number of cached pages
$numCached = $procache->numCachedPages();

// Get cache path
$cachePath = $procache->getCachePath($page);
```

---

## Cache Clearing

### Clear Single Page

```php
// Clear cache for specific page
$procache->clearPage($page);

// Clear with options
$procache->clearPage($page, [
    'num' => true,    // Also clear pageNum versions
    'segment' => true // Also clear urlSegment versions
]);
```

### Clear Multiple Pages

```php
// Clear cache for multiple pages
$items = $pages->find("template=blog-post");
$procache->clearPages($items);
```

### Clear All Cache

```php
// Clear entire cache
$procache->clearAll();
```

### Cache Clear Behaviors

Configure automatic cache clearing:

```php
// Get current cache clear behaviors
$behaviors = $procache->getCacheClearBehaviors();

// Cache clear constants:
// CACHE_CLEAR_ALL - Clear all
// CACHE_CLEAR_PAGES - Clear pages
// CACHE_CLEAR_UPLOADS - Clear uploads
// CACHE_CLEAR_LAZY - Use lazy clearing
```

---

## CDN Integration

### Basic CDN Setup

```php
// Check if CDN is allowed for current request
if ($procache->allowCDN()) {
    // CDN is active
}

// Get CDN instance
$cdn = $procache->getCDN();

// Check CDN status
$status = $procache->cdnStatus;
// 0 = Off
// 1 = On for guests only
// 2 = On for logged-in users only
// 3 = On for everyone
```

### CDN URL Conversion

```php
// Convert local URL to CDN URL
$cdnUrl = $procache->cdnUrl('/site/assets/files/1/image.jpg');

// Force CDN population in content
$procache->populateCDN($htmlContent);
$procache->populateCDN($htmlContent, 'html');
```

---

## CSS/JS Merging and Minification

### Merging Files

```php
// Merge CSS files
$css = $procache->css([
    '/site/templates/css/reset.css',
    '/site/templates/css/base.css',
    '/site/templates/css/layout.css'
]);

// Output: <link rel="stylesheet" href="/path/to/merged.css">

// Merge without minification
$css = $procache->css($files, false);

// Merge JS files
$js = $procache->js([
    '/site/templates/js/jquery.js',
    '/site/templates/js/plugins.js',
    '/site/templates/js/main.js'
]);

// Merge any files (CSS/JS mixed)
$merged = $procache->merge($files);
```

### Using link() and script() Helpers

```php
// Generate <link> tag for merged CSS
echo $procache->link($cssFiles);

// Generate <script> tag for merged JS
echo $procache->script($jsFiles);

// With minify disabled
echo $procache->link($cssFiles, false);
echo $procache->script($jsFiles, false);
```

---

## SCSS/LESS Compilation

### SCSS Compilation

```php
// Get SCSS compiler instance
$scss = $procache->getSCSS();

// Compile SCSS string
$css = $scss->compileString($scssCode);

// Compile SCSS file
$css = $scss->compileFile($scssFilePath);
```

### LESS Compilation

```php
// Get LESS compiler instance
$less = $procache->getLESS();

// Compile LESS string
$css = $less->compile($lessCode);
```

---

## HTML Minification

### Minify Output

```php
// Minify HTML output
$procache->minifyHtml($out);

// Minify with options
$procache->minifyHtml($out, [
    'comments' => true,    // Remove HTML comments
    'whitespace' => true,  // Remove unnecessary whitespace
    'attributes' => [],    // Attributes to minimize
]);
```

### Minification Options

```php
// Configure minification options
$procache->minifyOptions = [
    'removeComments' => true,
    'removeWhitespace' => true,
    'minifyJS' => true,
    'minifyCSS' => true,
];
```

---

## Hooks for Custom Cache Behavior

### Custom Cache Rules

```php
// Hook into allowCacheForPage for custom rules
$procache->addHookAfter('allowCacheForPage', function(HookEvent $e) {
    $page = $e->arguments[0];
    $allow = $e->return;
    
    // Custom rule: don't cache if has flash message
    if ($this->session->getFlash()) {
        $e->return = false;
    }
});
```

### Custom Cache Rendering

```php
// Hook before renderCache
$procache->addHookBefore('renderCache', function(HookEvent $e) {
    $page = $e->arguments[0];
    $out = $e->arguments[1];
    
    // Modify content before caching
    $e->arguments[1] = $this->minifyHtml($out);
});
```

---

## Configuration Properties

### Cache Settings

| Property | Type | Description |
|----------|------|-------------|
| `$procache->cacheTime` | int | Default cache time in seconds |
| `$procache->cacheDir` | string | Cache directory path |
| `$procache->cacheOn` | bool | Cache on/off status |
| `$procache->cacheTemplates` | array | Templates enabled for caching |

### CDN Settings

| Property | Type | Description |
|----------|------|-------------|
| `$procache->cdnStatus` | int | CDN status (0-3) |
| `$procache->cdnHosts` | string | CDN hostnames |
| `$procache->cdnExts` | string | File extensions for CDN |
| `$procache->cdnAttrs` | string | HTML attributes to update |

### Minification Settings

| Property | Type | Description |
|----------|------|-------------|
| `$procache->minify` | bool | Enable minification |
| `$procache->minifyBlocks` | string | Blocks to exclude |
| `$procache->minifyIgnoreTags` | string | Tags to ignore |

---

## Debug Mode

### Enable Debug

```php
// Check if debug mode is on
$debugMode = $procache->debugMode();

// Enable debug
$procache->debug = true;

// Add debug info
$procache->debugInfo('Custom debug message');
$procache->debugInfo('Message', true); // Prepend
```

---

## Best Practices

### 1. Template-Specific Caching

```php
// Only cache certain templates
if (in_array($page->template->name, ['home', 'blog', 'sitemap'])) {
    // Cache is handled automatically if enabled in settings
}
```

### 2. Vary Cache by GET/POST

```php
// Don't cache pages with GET variables
if ($input->get->id) {
    $procache->cacheOn(false);
}

// Specify GET vars that should trigger unique cache
$procache->noCacheGetVars = 'page,sort';
```

### 3. User-Specific Cache

```php
// Don't cache for logged-in users (if using role-based cache)
if ($user->isLoggedin()) {
    $procache->cacheOn(false);
}
```

### 4. Clear Cache on Publish

```php
// In a page save hook
$pages->addHookAfter('save', function(HookEvent $e) {
    $page = $e->arguments[0];
    if ($page->isChanged('published') || $page->isChanged('content')) {
        $procache->clearPage($page);
    }
});
```

---

## Troubleshooting

### Cache Not Working

1. Check `$procache->cacheOn` is true
2. Verify template is in `$procache->cacheTemplates`
3. Check page passes `allowCacheForPage` hook
4. Verify `.htaccess` is configured

### CDN Not Serving Files

1. Verify CDN is enabled (`$procache->cdnStatus > 0`)
2. Check file extensions in `$procache->cdnExts`
3. Verify CDN hostnames are configured

### Minification Issues

1. Enable debug mode to see what's happening
2. Check for syntax errors in CSS/JS
3. Exclude problematic code with `$procache->minifyIgnoreTags`

---

## API Summary

### Key Methods

| Method | Description |
|--------|-------------|
| `cacheOn($set)` | Get/set cache status |
| `clearPage($page)` | Clear single page cache |
| `clearAll()` | Clear all cache |
| `css($files, $minify)` | Merge/minify CSS |
| `js($files, $minify)` | Merge/minify JS |
| `minifyHtml($out)` | Minify HTML |
| `allowCDN()` | Check if CDN allowed |
| `cdnUrl($url)` | Convert to CDN URL |
| `isPageCacheable($page)` | Check if page can be cached |
| `getCacheTime($template)` | Get cache time |
| `renderCache($page, $out)` | Save cache file |
| `pageInfo($page)` | Get page cache info |
| `numCachedPages()` | Count cached pages |

### Sub-Objects

| Object | Description |
|--------|-------------|
| `$procache->minify` | Minification controller |
| `$procache->cdn` | CDN controller |
| `$procache->files` | File management |
| `$procache->static` | Static cache |
| `$procache->tweaks` | Performance tweaks |
| `$procache->buster` | Cache busting |
| `$procache->htaccess` | .htaccess management |
