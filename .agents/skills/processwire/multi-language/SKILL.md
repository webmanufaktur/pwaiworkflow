---
name: processwire-multi-language
description: Multi-language fields, URLs, translation functions, language switching, code i18n, and language packs
compatibility: opencode
metadata:
  domain: processwire
  scope: multi-language
---

## What I Do

I provide comprehensive guidance for ProcessWire multi-language support:

- Multi-language fields (text, textarea, title)
- Language-alternate fields
- Multi-language URLs and page names
- Code internationalization (i18n)
- Translation functions (`__()`, `_n()`, `_x()`)
- Language switching
- Language packs for admin

## When to Use Me

Use this skill when:

- Building multi-language websites
- Setting up multi-language fields
- Creating language switchers
- Translating template code strings
- Working with language-specific URLs
- Accessing field values in specific languages

---

## Getting Started

### Required Modules

Install from Modules > Language:

| Module                     | Purpose               |
| -------------------------- | --------------------- |
| `LanguageSupport`          | Base language support |
| `LanguageSupportFields`    | Multi-language fields |
| `LanguageSupportPageNames` | Multi-language URLs   |

### Adding Languages

1. Go to Setup > Languages
2. Click "Add New"
3. Enter language name (e.g., "spanish", "german")
4. Save

---

## Multi-Language Fields

### Available Field Types

| Field Type          | Description               |
| ------------------- | ------------------------- |
| `TextLanguage`      | Single line text          |
| `TextareaLanguage`  | Multi-line text/rich text |
| `PageTitleLanguage` | Page titles               |

### Converting Existing Fields

1. Go to Setup > Fields > [your field]
2. Change Type to multi-language version (e.g., Textarea → TextareaLanguage)
3. Confirm schema change
4. Save

### Using Multi-Language Fields

```php
// Output uses current user's language automatically
echo $page->title;  // Shows title in user's language
echo $page->body;   // Shows body in user's language

// If language version is empty, default language is used
```

### Getting Specific Language Values

```php
// Save current language
$savedLanguage = $user->language;

// Switch to French
$user->language = $languages->get('french');
echo $page->body;  // French version

// Restore language
$user->language = $savedLanguage;
```

### Alternative: Using getLanguageValue()

```php
$page->of(false);  // Turn off output formatting
$french = $languages->get('french');
$frenchBody = $page->body->getLanguageValue($french);
```

### Setting Language Values

```php
$page->of(false);

// Set for current user's language
$page->body = "Welcome friends";

// Set for specific language
$dutch = $languages->get('dutch');
$spanish = $languages->get('spanish');
$page->body->setLanguageValue($dutch, "Welkom vrienden");
$page->body->setLanguageValue($spanish, "Bienvenidos amigos");

$page->save();
```

---

## Language-Alternate Fields

Separate fields that substitute for each other based on language.

### Naming Convention

`{fieldname}_{languagename}`

Examples:

- `body_dutch` - Dutch version of body
- `summary_spanish` - Spanish version of summary

### How It Works

```php
// If user language is Dutch and body_dutch exists:
echo $page->body;  // Returns body_dutch value

// If body_dutch is empty:
echo $page->body;  // Returns default body value

// Direct access always works:
echo $page->body_dutch;  // Always returns Dutch version
```

### Setting Values

```php
$page->of(false);
$page->body = "Welcome friends";           // Default language
$page->body_dutch = "Welkom vrienden";     // Dutch
$page->body_spanish = "Bienvenidos amigos"; // Spanish
$page->save();
```

---

## Multi-Language URLs

### Setup

1. Install `LanguageSupportPageNames` module
2. Edit homepage > Settings tab
3. Set URL Name for each language (e.g., "en", "es", "de")
4. Check "Active" for each language
5. Save

### How It Works

| Language | Homepage URL | Page URL        |
| -------- | ------------ | --------------- |
| Default  | `/`          | `/about/`       |
| Spanish  | `/es/`       | `/es/acerca/`   |
| German   | `/de/`       | `/de/uber-uns/` |

### Page Name Translation

Edit any page > Settings tab:

- Set alternative names for each language
- If left blank, default name is used
- Check "Active" to enable language

### API Methods

```php
// Get URL in specific language
$url = $page->localUrl($language);

// Get page name in specific language
$name = $page->localName($language);

// Get path in specific language
$path = $page->localPath($language);

// Check if page is viewable in language
if($page->viewable($language)) {
    // Page is active in this language
}
```

---

## Language Switching

### Language Switcher (Links)

```php
<?php
$savedLanguage = $user->language;

foreach($languages as $language) {
    // Skip current language
    if($language->id == $savedLanguage->id) continue;

    // Skip if page not active in this language
    if(!$page->viewable($language)) continue;

    // Switch to get language-specific URL
    $user->language = $language;

    echo "<a href='$page->url'>$language->title</a>";
}

// Restore language
$user->language = $savedLanguage;
?>
```

### Language Switcher (Select)

```php
<select onchange="window.location=this.value">
<?php foreach($languages as $language): ?>
    <?php if(!$page->viewable($language)) continue; ?>
    <option
        value="<?=$page->localUrl($language)?>"
        <?=$user->language->id == $language->id ? 'selected' : ''?>
    >
        <?=$language->title?>
    </option>
<?php endforeach; ?>
</select>
```

### Setting Language Manually

```php
// In _init.php or template
if($input->get->lang) {
    $lang = $sanitizer->pageName($input->get->lang);
    $language = $languages->get($lang);
    if($language->id) {
        $user->language = $language;
    }
}
```

---

## Code Internationalization (i18n)

Translate static text in template files.

### Translation Functions

| Function                         | Usage             |
| -------------------------------- | ----------------- |
| `__('text')`                     | Basic translation |
| `_n('single', 'plural', $count)` | Plurals           |
| `_x('text', 'context')`          | Context-specific  |

### Basic Translation

```php
// Outside class (template files)
echo __('Welcome to our site');

// Inside class (modules)
echo $this->_('Welcome to our site');
```

### With Placeholders

```php
// WRONG - variable not translatable
echo __("Created $count pages");

// RIGHT - use sprintf
echo sprintf(__('Created %d pages'), $count);

// Multiple placeholders with argument swapping
echo sprintf(
    __('Your city is %1$s, and your zip is %2$s.'),
    $city,
    $zipcode
);
```

### Plurals

```php
echo sprintf(
    _n('Created %d page', 'Created %d pages', $count),
    $count
);

// In class
echo sprintf(
    $this->_n('Created %d page', 'Created %d pages', $count),
    $count
);
```

### Context

When same word has different meanings:

```php
// As a noun
echo _x('Comment', 'noun');

// As a verb
echo _x('Comment', 'verb');

// In class
echo $this->_x('Post', 'noun');
echo $this->_x('Post', 'verb');
```

### Comments for Translators

```php
// Comment appears to translator
echo __('g:i:s a'); // Date format in PHP date() format

// With notes (secondary comment)
echo __('Welcome Guest'); // Headline // Keep it short
```

### Translation Rules

1. **One line**: Function call must be on single line
2. **One pair of quotes**: No string concatenation inside function
3. **One call per line**: Only one translation function per line

```php
// WRONG
echo __('Hello ' . 'World');  // Concatenation
echo __('Hello') . __('World');  // Two calls per line

// RIGHT
echo __('Hello World');
echo __('Hello') . ' ' .
     __('World');  // Separate lines OK
```

---

## Translating Template Files

### Setup Translation

1. Go to Setup > Languages > [language]
2. Click "Translate File"
3. Select your template file
4. Enter translations for each string
5. Save

### Finding Translatable Files

ProcessWire scans for `__()` calls in:

- `/site/templates/*.php`
- Module files
- Core files

---

## Common Patterns

### Multi-Language Navigation

```php
<?php foreach($pages->get('/')->children as $item): ?>
    <a href="<?=$item->url?>"><?=$item->title?></a>
<?php endforeach; ?>
```

Title and URL automatically use current language.

### Multi-Language Search

```php
$q = $sanitizer->selectorValue($input->get->q);
$results = $pages->find("title|body~=$q");
```

Searches current language AND default language.

### Check Language Availability

```php
// Check if content exists in current language
$french = $languages->get('french');
$page->of(false);
$frenchTitle = $page->title->getLanguageValue($french);

if($frenchTitle) {
    echo "French version available";
}
```

### Redirect to User's Browser Language

```php
// In _init.php (only for homepage)
if($page->id == 1 && !$session->get('lang_set')) {
    $browserLang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
    $language = $languages->get($browserLang);

    if($language->id && $language->id != $languages->getDefault()->id) {
        $session->set('lang_set', 1);
        $session->redirect($page->localUrl($language));
    }
    $session->set('lang_set', 1);
}
```

### Hreflang Tags for SEO

```php
<head>
<?php foreach($languages as $language): ?>
    <?php if(!$page->viewable($language)) continue; ?>
    <link rel="alternate"
          hreflang="<?=$language->name?>"
          href="<?=$page->localHttpUrl($language)?>">
<?php endforeach; ?>
</head>
```

---

## Language Permissions

Control who can edit which languages.

### Available Permissions

| Permission               | Description              |
| ------------------------ | ------------------------ |
| `page-edit-lang-default` | Edit default language    |
| `page-edit-lang-[name]`  | Edit specific language   |
| `page-edit-lang-none`    | Edit non-language fields |
| `lang-edit`              | Access language tools    |

### Setup Translator Role

1. Create permission `page-edit-lang-spanish`
2. Create role "translator-spanish"
3. Assign permissions:
   - `page-edit`
   - `page-edit-lang-spanish`
4. Assign role to templates user should translate

---

## Admin Language Packs

### Installing Language Packs

1. Download language pack from ProcessWire site
2. Go to Setup > Languages > [language]
3. Upload pack files
4. Save

### Finding Language Packs

Community language packs available at:

- ProcessWire modules directory
- ProcessWire forums

---

## Pitfalls / Gotchas

1. **Output formatting matters**: Language substitution only works with output formatting ON. Use `getLanguageValue()` when OFF.

2. **Empty values fallback**: If language value is empty, default language is returned automatically.

3. **URL language detection**: With `LanguageSupportPageNames`, language is auto-detected from URL - no manual setting needed.

4. **Translation function rules**:
   - One call per line
   - No string concatenation inside `__()`
   - Use sprintf for variables

5. **Page active in language**: Pages must have "Active" checked for each language in Settings tab.

6. **Searching multi-language fields**: Searches match current language OR default language.

7. **Homepage URL**: Default language homepage is always `/`, regardless of name setting.

8. **Module translations**: Use `$this->_()` inside classes for better performance.

9. **Context translations**: Use `_x()` when same text appears multiple times with different meanings.

10. **Language names**: Use simple names like "spanish", "german" - they become field suffixes.
