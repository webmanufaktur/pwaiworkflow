---
name: processwire-selectors
description: Selector syntax, operators, OR/AND groups, sub-selectors, sorting, limiting, access control, and input sanitization for querying pages
compatibility: opencode
metadata:
  domain: processwire
  scope: selectors
---

## What I Do

I provide comprehensive guidance for ProcessWire selectors:

- Selector syntax and components (field, operator, value)
- All operators (comparison, text, phrase, word matching)
- OR/AND selectors and OR-groups
- Sub-selectors for complex queries
- Sorting and limiting results
- Access control in selectors
- Sanitizing user input for selectors

## When to Use Me

Use this skill when:

- Building selectors for `$pages->find()` or `$page->children()`
- Choosing the right operator for text searching
- Creating complex queries with OR-groups or sub-selectors
- Implementing search functionality
- Sanitizing user-provided selector values
- Controlling access in page queries

---

## Selector Basics

A selector consists of three parts: **field**, **operator**, and **value**.

```
field=value
title*=Hello World
template=product, price>=100
```

### Where Selectors Are Used

```php
$pages->find("selector");
$pages->get("selector");
$page->children("selector");
$page->siblings("selector");
$page->find("selector");
$page->parent("selector");

// Also works on arrays and other types
$templates->find("selector");
$users->find("selector");
$fields->find("selector");
$page->images->find("selector");
```

---

## Operators Reference

### Comparison Operators

| Operator | Name                  | Description             |
| -------- | --------------------- | ----------------------- |
| `=`      | Equals                | Exact match             |
| `!=`     | Not equals            | Does not match          |
| `>`      | Greater than          | Numeric/date comparison |
| `<`      | Less than             | Numeric/date comparison |
| `>=`     | Greater than or equal | Numeric/date comparison |
| `<=`     | Less than or equal    | Numeric/date comparison |

```php
$pages->find("template=product");
$pages->find("id!=1");
$pages->find("price>100");
$pages->find("price<=50");
$pages->find("created>=today");
```

### Phrase Matching Operators

Match phrases (words in order).

| Operator | Name            | Description                        |
| -------- | --------------- | ---------------------------------- |
| `*=`     | Contains phrase | Phrase appears in value (fulltext) |
| `%=`     | Contains like   | Phrase appears using LIKE          |
| `^=`     | Starts with     | Value starts with phrase           |
| `$=`     | Ends with       | Value ends with phrase             |
| `%^=`    | Starts like     | Starts with using LIKE             |
| `%$=`    | Ends like       | Ends with using LIKE               |
| `*+=`    | Contains expand | Contains with query expansion      |

```php
// Contains exact phrase "wire tool"
$pages->find("title*=wire tool");

// Contains phrase using LIKE (matches short words/stopwords)
$pages->find("title%=wire tool");

// Starts with "Hello"
$pages->find("body^=Hello");

// Ends with "goodbye"
$pages->find("body$=goodbye");
```

### Word Matching Operators

Match words in any order.

| Operator | Name                  | Description                               |
| -------- | --------------------- | ----------------------------------------- |
| `~=`     | Contains all words    | All words appear (any order)              |
| `~*=`    | Contains all partial  | All words partially match                 |
| `~~=`    | Contains words live   | All words, last partial (for live search) |
| `~%=`    | Contains words like   | All words using LIKE                      |
| `~+=`    | Contains words expand | All words with query expansion            |
| `~\|=`   | Contains any words    | Any word appears                          |
| `~\|*=`  | Contains any partial  | Any word partially matches                |
| `~\|%=`  | Contains any like     | Any word using LIKE                       |
| `~\|+=`  | Contains any expand   | Any word with expansion                   |

```php
// All words must appear (any order)
$pages->find("body~=sushi tobiko");

// Any word can appear
$pages->find("title~|=red blue green");

// Partial word matching (for autocomplete)
$pages->find("title~~=proc");  // Matches "ProcessWire"
```

### Advanced Text Search

| Operator | Name            | Description                        |
| -------- | --------------- | ---------------------------------- |
| `#=`     | Advanced search | Boolean-style search with commands |
| `**=`    | Contains match  | Traditional fulltext MATCH/AGAINST |

```php
// Advanced search with commands
$pages->find('title#="+image* -file*"');

// + means MUST appear
// - means MUST NOT appear
// * means partial match
// (phrase) or "phrase" for phrase matching
```

**Advanced search commands:**

- `+word` - MUST appear
- `-word` - MUST NOT appear
- `word` - MAY appear (increases rank)
- `word*` - Partial match (bar\* matches barn, barge)
- `+(foo bar)` - Phrase MUST appear
- `-(foo bar)` - Phrase MUST NOT appear

### Bitwise Operator

| Operator | Name        | Description                |
| -------- | ----------- | -------------------------- |
| `&`      | Bitwise AND | Integer bitwise comparison |

```php
$pages->find("status&1024");  // Check status bit
```

---

## Negating Selectors

Prefix field name with `!` to negate any operator:

```php
// Pages NOT containing phrase
$pages->find("!body*=sushi tobiko");

// Pages NOT starting with
$pages->find("!title^=Draft");
```

---

## Multiple Fields (OR)

Use pipe `|` to match any of multiple fields:

```php
// Match in title OR body OR sidebar
$pages->find("title|body|sidebar*=search term");
```

---

## Multiple Values (OR)

Use pipe `|` to match any of multiple values:

```php
// Match any of these names
$pages->find("name=about|contact|services");

// Match any of these IDs
$pages->find("id=123|456|789");

// Match any color
$pages->find("color=red|blue|green");
```

---

## Multiple Selectors (AND)

Separate selectors with commas for AND logic:

```php
// Template AND price range
$pages->find("template=product, price>=100, price<=500");

// Multiple conditions
$pages->find("template=blog-post, featured=1, date>=today-30");
```

---

## OR-Groups

Match one group of selectors OR another using parentheses:

```php
// Either featured date range OR highlighted
$pages->find("
    template=product,
    stock>0,
    (featured_from<=today, featured_to>=today),
    (highlighted=1)
");
```

**Named OR-groups** for complex logic:

```php
// Must match one "a" group AND one "b" group
$pages->find("
    a=(color=red),
    b=(size=large),
    a=(color=blue),
    b=(size=medium)
");
```

---

## Sub-Selectors

Query related pages within a selector using `[brackets]`:

```php
// Products from companies with 5+ locations in Finland
$pages->find("
    template=product,
    company=[locations>5, locations.title%=Finland]
");

// Nested sub-selectors (PW 3.x)
$pages->find("
    template=member,
    invoice=[status=paid, invoice_row!=[product.color=Red]]
");
```

---

## Sorting Results

Use the `sort` keyword:

```php
// Sort by title A-Z
$pages->find("template=product, sort=title");

// Sort by date descending (newest first)
$pages->find("template=blog-post, sort=-date");

// Multiple sort levels
$pages->find("template=product, sort=-date, sort=title");

// Alternative syntax
$pages->find("template=product, sort=date|title");

// Sort by admin drag order
$pages->find("parent=/products/, sort=sort");
```

---

## Limiting Results

```php
// Limit to 10 results
$pages->find("template=product, limit=10");

// Skip first 20, get next 10 (for pagination)
$pages->find("template=product, start=20, limit=10");

// Note: start is auto-set based on page number when pagination enabled
```

---

## Count Selectors

Match based on number of items in multi-value fields:

```php
// Pages with children
$pages->find("children.count>0");

// Pages with 3-5 images
$pages->find("images.count>=3, images.count<=5");

// Pages with no categories selected
$pages->find("categories.count=0");
```

---

## Subfield Selectors

Access properties of complex fields:

```php
// Image dimensions
$pages->find("images.width>=800");
$pages->find("images.height>=600");

// File properties
$pages->find("files.ext=pdf");
$pages->find("files.filesize>1000000");

// Page reference properties
$pages->find("category.name=featured");
$pages->find("author.roles.name=editor");

// Parent/ancestor properties
$pages->find("parent.template=blog");
$pages->find("parents.name=products");
```

---

## Finding by Template

```php
// Single template
$pages->find("template=product");

// Multiple templates
$pages->find("template=product|service|category");

// Exclude template
$pages->find("template!=admin");
```

---

## Finding by Parent/Ancestor

```php
// Direct children of a parent
$pages->find("parent=/products/");
$pages->find("parent=1234");

// Has ancestor (any level)
$pages->find("has_parent=/products/");

// Parent properties
$pages->find("parent.template=category");
```

---

## Access Control in Selectors

By default, `find()` respects access control. Override with:

```php
// Include hidden pages
$pages->find("template=product, include=hidden");

// Include unpublished pages
$pages->find("template=product, include=unpublished");

// Include ALL pages (hidden, unpublished, trash)
$pages->find("template=product, include=all");

// Disable access checks
$pages->find("template=product, check_access=0");
```

---

## Sanitizing User Input

Always sanitize user input before using in selectors:

### selectorValue()

```php
$q = $sanitizer->selectorValue($input->get->q);
$results = $pages->find("title|body*=$q");
```

### For Advanced Search

```php
$q = $sanitizer->selectorValueAdvanced($input->get->q);
$results = $pages->find("title#=$q");
```

### Escaping Special Characters

Selector values may contain:

- Commas (use quotes): `body*="hello, world"`
- Double quotes (escape): `body*="say \"hello\""`

```php
// Sanitizer handles this automatically
$value = $sanitizer->selectorValue('hello, "world"');
// Result: "hello, \"world\""
```

---

## Stacking Operators (PW 3.0.161+)

Fallback through multiple operators:

```php
// Try phrase match, then all words, then any words
$pages->find("title*=~=~|=hello world");
```

**Order of operations:**

1. `*=` Contains phrase (strictest)
2. `~=` Contains all words
3. `~|=` Contains any words (loosest)

---

## Common Patterns

### Search Implementation

```php
$q = $sanitizer->selectorValue($input->get->q);
if($q) {
    $results = $pages->find("title|body|summary~=$q, limit=20");
} else {
    $results = new PageArray();
}
```

### Date Queries

```php
// Today
$pages->find("created>=today");

// Last 7 days
$pages->find("created>=today-7");

// Date range
$pages->find("date>=2024-01-01, date<2024-02-01");

// This year
$pages->find("created>='" . date('Y-01-01') . "'");
```

### Empty/Non-Empty Fields

```php
// Has value
$pages->find("summary!=''");
$pages->find("summary!=\"\"");

// Empty value (be careful with field types)
$pages->find("summary=''");

// Has images
$pages->find("images.count>0");

// No images
$pages->find("images.count=0");
```

### Random Order

```php
$pages->find("template=product, sort=random, limit=5");
```

### Finding by ID

```php
$pages->find("id=123|456|789");
$pages->find("id>1000");
$pages->find("id!=1");  // Exclude homepage
```

---

## Performance Tips

1. **Use specific templates**: `template=product` narrows the search
2. **Use indexed fields**: `*=` and `~=` use fulltext indexes
3. **Limit results**: Always use `limit=` for large datasets
4. **Avoid `%=` on large datasets**: LIKE can be slower than fulltext
5. **Use `findIDs()` when you only need IDs**:
   ```php
   $ids = $pages->findIDs("template=product");
   ```
6. **Use `findRaw()` for specific fields only**:
   ```php
   $data = $pages->findRaw("template=product", ["title", "price"]);
   ```

---

## Pitfalls / Gotchas

1. **Stopwords and short words**: `*=` and `~=` may not match words under 4 characters or common words. Use `%=` instead.

2. **Case sensitivity**: Selectors are case-insensitive by default (depends on MySQL collation).

3. **OR-groups don't work in-memory**: Only for database `find()` operations.

4. **children.count limitation**: Can only use one count comparison per query.

5. **Quotes in values**: Use `$sanitizer->selectorValue()` to properly escape.

6. **Empty string matching**: Be careful with `field=''` - behavior varies by field type.

7. **Selector reserved words**: `sort`, `limit`, `start`, `include`, `check_access` are reserved.

8. **Trailing slashes in paths**: Include them: `parent=/about/` not `parent=/about`
