---
name: processwire-custom-page-classes
description: Custom page classes, class naming, inheritance, interfaces, hookable methods, IDE integration with phpdoc
license: MIT
compatibility: opencode
metadata:
  domain: processwire
  scope: object-oriented-development
---

## What I Do

I provide comprehensive guidance for ProcessWire custom page classes, including:

- Enabling and configuring custom page classes
- Class naming conventions and template mapping
- Adding custom methods and properties
- PHPDoc integration for IDE code completion
- Type enforcement and inheritance patterns
- PHP interfaces for common page types
- Extending Repeater, Fieldset, and Matrix classes
- Hookable methods and custom hooks
- Helper classes and best practices
- Internal vs external access patterns
- Output formatting considerations

## When to Use Me

Use this skill when:

- Creating custom page classes for templates
- Extending Page class with custom methods
- Setting up IDE autocomplete for page fields
- Implementing type-safe functions accepting specific page types
- Creating inheritance hierarchies for page classes
- Extending Repeater/Matrix/Fieldset item classes
- Adding hookable methods to page classes
- Creating helper classes for complex page logic
- Documenting page and field types with PHPDoc

---

## Enabling Custom Page Classes

### Configuration

Enable in `/site/config.php`:

```php
$config->usePageClasses = true;
```

### Directory Setup

Ensure `/site/classes/` directory exists. All custom page class files go here.

### Basic Example

```php
// /site/classes/HomePage.php
<?php namespace ProcessWire;

class HomePage extends Page {}
```

Now `$page` is instance of `HomePage` for homepage.

---

## Class Naming Convention

Template names map to PascalCase + "Page":

| Template     | Class            | File                          |
| ------------ | ---------------- | ----------------------------- |
| home         | HomePage         | HomePage.php                  |
| product      | ProductPage      | ProductPage.php               |
| blog-post    | BlogPostPage     | BlogPostPage.php              |
| article      | ArticlePage      | ArticlePage.php               |
| basic-page   | BasicPagePage    | BasicPagePage.php             |

---

## Adding Custom Methods

### Basic Method

```php
// /site/classes/CategoryPage.php
<?php namespace ProcessWire;

class CategoryPage extends Page {
    // get number of posts using this category
    public function numPosts(): int {
        return $this->wire()->pages->count(
            "template=blog-post, categories=$this"
        );
    }
}
```

Usage:

```php
$categories = $pages->find('template=category');
foreach($categories as $c) {
    $numPosts = $c->numPosts();
    if(!$numPosts) continue;
    echo "<li><a href='$c->url'>$c->title</a> $numPosts";
}
```

### Multiple Methods

```php
// /site/classes/BlogPostPage.php
class BlogPostPage extends Page {

    // get other blog posts related to this one
    public function getRelatedPosts(): PageArray {
        return $this->wire()->pages->find([
            'template' => 'blog-post',
            'categories' => $this->categories,
            'sort' => '-date',
            'id!=' => $this->id
        ]);
    }

    // get the post author's full name
    public function getAuthorName(): string {
        $u = $this->createdUser;
        return "$u->first_name $u->last_name";
    }

    // get a short excerpt paragraph of the post
    public function getExcerpt(): string {
        $excerpt = $this->summary;
        if(empty($excerpt)) {
            $excerpt = $this->wire()->sanitizer->truncate($this->body);
        }
        return $excerpt;
    }

    // return number of words in the post
    public function numWords(): int {
        $body = strip_tags($this->body);
        return str_word_count($body);
    }
}
```

---

## Adding Custom Properties

### Override get() Method

```php
// /site/classes/CategoryPage.php
class CategoryPage extends Page {
    public function get($key) {
        if($key === 'numPosts') return $this->numPosts();
        return parent::get($key);
    }

    public function numPosts(): int {
        return $this->wire()->pages->count(
            "template=blog-post, categories=$this"
        );
    }
}
```

Now works as both method and property:

```php
// Method call
$count = $category->numPosts();

// Property access
echo $post->categories->each(
    "<li><a href='{url}'>{title}</a> {numPosts}"
);
```

### Multiple Properties

```php
// /site/classes/BlogPostPage.php
class BlogPostPage extends Page {
    public function get($key) {
        if($key === 'authorName') return $this->getAuthorName();
        if($key === 'numWords') return $this->numWords();
        return parent::get($key);
    }
    // ... methods from previous example
}
```

---

## PHPDoc for IDE Integration

### Documenting Fields

```php
/**
 * Blog Post Page: /site/classes/BlogPostPage.php
 *
 * @property string $title
 * @property string $summary
 * @property string $body
 * @property string $date
 * @property User|NullPage $author
 * @property PageArray|CategoryPage[] $categories
 * @property-read string $authorName
 * @property-read int $numWords
 *
 */
class BlogPostPage extends Page {
    // ... class implementation
}
```

### Minimal Documentation

Even without custom methods, use phpdoc for field awareness:

```php
/**
 * Home Page: /site/classes/HomePage.php
 *
 * @property string $title
 * @property string $browser_title
 * @property string $meta_description
 * @property string $body
 * @property PageArray $featured_pages
 *
 */
class HomePage extends Page {}
```

### Type Hinting in Templates

```php
// In /site/templates/blog-post.php
/** @var BlogPostPage $page */
```

```php
// For PageArrays
/** @var BlogPostPage[] $posts */
$posts = $pages->get('/blog/posts/')->children();

// Or for PageArray type
/** @var PageArray|BlogPostPage[] $posts */
```

---

## Type Enforcement

### Function Type Hints

```php
function blogPostByline(BlogPostPage $post): string {
    return "Written by $post->authorName on $post->date";
}
```

Only accepts `BlogPostPage`, not generic `Page`.

### Comparison Without Custom Classes

```php
// Without custom classes
function blogPostByline(Page $post): string {
    if($post->template->name != 'blog-post') {
        throw new WireException("That's not a blog-post!");
    }
    return "Written by $post->authorName on $post->date";
}
```

---

## Inheritance Patterns

### Extending Other Custom Page Classes

```php
/**
 * Article Page: /site/classes/ArticlePage.php
 *
 * @property string $title
 * @property string $summary
 * @property string $body
 * @property PageArray|CategoryPage[] $categories
 *
 */
class ArticlePage extends Page {
    public function getExcerpt(): string {
        $excerpt = $this->get('summary|body');
        return $this->wire()->sanitizer->truncate($excerpt);
    }
}
```

```php
/**
 * /site/classes/BlogPostPage.php
 *
 * @property string $date
 * @property AuthorPage|NullPage $author
 *
 */
class BlogPostPage extends ArticlePage {}
```

`BlogPostPage` inherits `getExcerpt()` from `ArticlePage`.

### Type Hierarchy Benefit

```php
// Function accepts ArticlePage or BlogPostPage
function renderArticleSummary(ArticlePage $p) {
    return
        "<h3><a href='$p->url'>$p->title</a></h3>" .
        "<p>" . $p->getExcerpt() . "</p>" .
        "<ul>" . $p->categories->each("<li>{title}") . "</ul>";
}
```

### Using DefaultPage

```php
/**
 * Default Page: /site/classes/DefaultPage.php
 *
 */
class DefaultPage extends Page {
    public function getLastModified(): string {
        return wireRelativeTimeStr($this->modified) .
            ' by ' . $this->modifiedUser->name;
    }
}
```

Use `DefaultPage` instead of `Page` for extension:

```php
class ProductPage extends DefaultPage {
    // inherits getLastModified()
}
```

---

## Extending Base Classes

### User, Permission, Role, Language

```php
// /site/classes/UserPage.php
class UserPage extends User {}

// /site/classes/PermissionPage.php
class PermissionPage extends Permission {}

// /site/classes/RolePage.php
class RolePage extends Role {}

// /site/classes/LanguagePage.php
class LanguagePage extends Language {}
```

---

## PHP Interfaces

### Define Interface

```php
/**
 * TourPage interface: /site/classes/TourPage.php
 *
 * Required interface for [Type]TourPage classes
 *
 */
interface TourPage {
    public function getDepartures(int $month, int $year): array;
    public function getTourType(): string;
}
```

### Implement Interface

```php
/**
 * Boat Tour Page: /site/classes/BoatTourPage.php
 *
 */
class BoatTourPage extends Page implements TourPage {
    public function getDepartures(int $month, int $year): array {
        $departures = [ /* get from ACME web service */ ];
        return $departures;
    }

    public function getTourType(): string {
        return "Tour by boat";
    }
}
```

```php
/**
 * Bike Tour Page: /site/classes/BikeTourPage.php
 *
 */
class BikeTourPage extends Page implements TourPage {
    public function getDepartures(int $month, int $year): array {
        $departures = [ /* get from XYZ Inc. web service */ ];
        return $departures;
    }

    public function getTourType(): string {
        return "Biking tour";
    }
}
```

### Using Interface

```php
function renderTourInfo(TourPage $tour) {
    $month = date('n');
    $year = date('Y');
    echo "<h2>$tour->title</h2>";
    echo "<h3>" . $tour->getTourType() . "</h3>";
    $departures = $tour->getDepartures($month, $year);
    foreach($departures as $departure) {
        echo "<li>$departure->date $departure->time";
    }
}
```

Works with any class implementing `TourPage`.

---

## Extending Repeater Classes

### Repeater Field

```php
/**
 * /site/classes/QuotesRepeaterPage.php
 *
 * Custom page class for items in repeater field named 'quotes'
 *
 * @property string $quote
 * @property string $cite
 *
 */
class QuotesRepeaterPage extends RepeaterPage {}
```

### Repeater Matrix Field

```php
/**
 * /site/classes/FooBarRepeaterMatrixPage.php
 *
 * Used for items in repeater matrix field named 'foo_bar'
 *
 * @property string $foo
 * @property string $bar
 *
 */
class FooBarRepeaterMatrixPage extends RepeaterMatrixPage {}
```

### Fieldset Page Field

```php
/**
 * /site/classes/SeoFieldsetPage.php
 *
 * Used for FieldsetPage field named 'seo'
 *
 * @property string $browser_title
 * @property string $meta_description
 * @property bool $noIndex
 *
 */
class SeoFieldsetPage extends FieldsetPage {}
```

---

## Hookable Methods

### Target Specific Page Types

```php
// /site/ready.php
$wire->addHookBefore('ProductPage::saveReady', function($e) {
    $product = $e->object; /** @var ProductPage $product */
    if($product->num_available > 0) {
        if($product->isHidden()) $product->removeStatus('hidden');
    } else if(!$product->isHidden()) {
        $product->addStatus('hidden');
    }
});
```

Hook receives only `ProductPage` instances.

### More Hook Examples

```php
// when blog post is deleted check if any categories should be hidden
$wire->addHook('BlogPostPage::deleteReady', function($e) {
    $p = $e->object; /** @var BlogPostPage $p */
    foreach($p->categories as $c) {
        $n = pages()->count("template=blog-post, categories=$c, id!=$p");
        if(!$n && !$c->isHidden()) {
            $c->addStatus('hidden');
            $c->save('status');
        }
    }
});

// when blog post is saved unhide hidden categories
$wire->addHook('BlogPostPage::saved', function($e) {
    $p = $e->object; /** @var BlogPostPage $p */
    foreach($p->categories as $c) {
        if($c->isHidden()) {
            $c->removeStatus('hidden');
            $c->save('status');
        }
    }
});
```

---

## Adding Custom Hookable Methods

### Define Hookable Method

```php
/**
 * @method string hello()
 *
 */
class HelloPage extends Page {
    public function ___hello() {
        return 'hello';
    }
}
```

### Hook the Method

```php
$wire->addHookAfter('HelloPage::hello', function($e) {
    $e->return .= " world"; // i.e. "hello world"
});
```

### Add Method Via Hook

```php
$wire->addHook('HelloPage::world', function($e) {
    $e->return = "it's a small world";
});
```

Usage:

```php
$p = $pages->findOne('template=hello');
if($p->id) echo $p->world(); // it's a small world
```

---

## Avoid Repeating Methods

### Use Inheritance

```php
// /site/classes/ContentPage.php
abstract class ContentPage extends Page {
    public function getExcerpt(): string {
        $excerpt = $this->get('summary|body');
        return $this->wire()->sanitizer->truncate($excerpt);
    }
}

// /site/classes/ArticlePage.php
class ArticlePage extends ContentPage {}

// /site/classes/BlogPostPage.php
class BlogPostPage extends ContentPage {}
```

### Use Traits

```php
// /site/classes/ExcerptPage.php
trait ExcerptPage {
    public function getExcerpt(): string {
        $excerpt = $this->get('summary|body');
        return $this->wire()->sanitizer->truncate($excerpt);
    }
}

// /site/classes/ArticlePage.php
class ArticlePage extends Page {
    use ExcerptPage;
}

// /site/classes/BlogPostPage.php
class BlogPostPage extends Page {
    use ExcerptPage;
}
```

### Add Methods Via Hook

```php
$wire->addHookMethod('ArticlePage::getExcerpt, BlogPostPage::getExcerpt', function($e) {
    $excerpt = $this->get('summary|body');
    return $this->wire()->sanitizer->truncate($excerpt);
});
```

Note: Not self-documenting, add phpdoc for IDE awareness.

---

## Helper Classes

### Basic Helper Pattern

```php
// /site/classes/ProductPageOrders.php
class ProductPageOrders extends Wire {
    function getOrders(ProductPage $product) {
        // retrieve orders for product
    }

    function addOrder(ProductPage $product, array $info) {
        // add order to product
    }
}
```

### Use in Page Class

```php
// /site/classes/ProductPage.php
class ProductPage extends Page {
    static protected $orders = null;

    protected function orders() {
        if(!self::$orders) self::$orders = new ProductPageOrders();
        return self::$orders;
    }

    public function getOrders() {
        return $this->orders()->getOrders($this);
    }

    public function addOrder(array $info) {
        return $this->orders()->addOrder($this, $info);
    }
}
```

---

## Internal vs External Access

### Internal vs External Differences

```php
// Inside custom page class
$this->something;    // Direct property access, may skip get()
$this->get('something'); // Use get() for proper lazy loading

// Outside class
$page->something;    // Goes through get() method
```

### Template Property Example

```php
// Inside class - may return null
$this->template;

// Inside class - always returns Template object
$this->get('template');
```

### API Variable Access

```php
// Inside class - WRONG
$this->pages;

// Inside class - CORRECT
$this->wire()->pages;
$this->wire('pages');
```

---

## Output Formatting

### Check Output Formatting State

```php
if($this->of()) {
    // Page is ready for output
    // Text should be HTML entity encoded
    return 'This &amp; That';
} else {
    // Page is ready for manipulation
    // Text should not be HTML entity encoded
    return 'This & That';
}
```

### Toggle Output Formatting

```php
// Save state
$of = $this->of();

// Turn off
$this->of(false);

// Make changes
$this->body = $newContent;

// Restore state
$this->of($of);
```

---

## Customizing Admin Page List

### Override getPageListLabel()

```php
class ProductPage extends Page {
    public function getPageListLabel() {
        $title = $this->getFormatted('title');
        $qty = $this->num_available;

        if($qty > 0) {
            $label = "<span class='uk-label uk-label-success'>$qty available</span>";
        } else {
            $label = "<span class='uk-label uk-label-danger'>Out of Stock</span>";
        }

        return "$title $label";
    }
}
```

Must return HTML with inline styles only. All text must be HTML entity encoded.

---

## Custom Field Classes

### Define Custom Field Class

```php
/**
 * /site/classes/fields/SeoValue.php
 *
 * @property string $browser_title
 * @property string $meta_description
 * @property string $canonical_url
 * @property bool|int $noindex
 *
 */
class SeoValue extends ComboValue {}
```

### Reference in Page Class

```php
/**
 * /site/classes/DestinationPage.php
 *
 * @property SeoValue $seo
 *
 */
class DestinationPage extends Page {}
```

### Table Field Rows

```php
/**
 * /site/classes/fields/QuotesTableRow.php
 *
 * @property string $quote
 * @property string $cite
 * @property string $date
 *
 */
class QuotesTableRow extends TableRow {}
```

### Reference in Page Class

```php
/**
 * /site/classes/DestinationPage.php
 *
 * @property QuotesTableRow[] $quotes
 * @property SeoValue $seo
 *
 */
class DestinationPage extends Page {}
```

---

## Pitfalls / Gotchas

1. **Don't treat page class as single "thing"**
   - Hundreds/thousands of instances may load at once
   - Avoid adding hooks within page classes
   - Avoid using as general function libraries
   - Be wary of front-end only or admin-only logic

2. **Internal vs external access differences**
   - `$this->template` may return null, `$page->template` returns Template
   - Use `$this->get('field')` for proper lazy loading internally
   - Cannot use `$this->pages`, must use `$this->wire()->pages`

3. **Avoid repeating method implementations**
   - Use inheritance, abstract base classes, or traits
   - Traits don't enforce types (can't use with instanceof)
   - Hooks for methods lack self-documentation

4. **Don't generate markup in page classes**
   - Keep markup generation in /site/templates/
   - Design changes should only require template changes
   - Page classes are not a "view" layer

5. **Output formatting state varies**
   - May be enabled on front-end, disabled in admin
   - Don't assume one or the other
   - Check with `$page->of()` and restore state

6. **DefaultPage catches all pages**
   - Used for pages without specific custom class
   - Good place for methods needed on all pages
   - Make custom classes extend DefaultPage when appropriate

7. **Hooks in page classes**
   - Don't add hooks within page class constructors/methods
   - Hooks should be in /site/ready.php
   - Use custom page class types in hook definitions for targeting

8. **PHPDoc is optional but valuable**
   - Even empty custom classes benefit from field documentation
   - IDE autocomplete saves development time
   - Custom field classes enable deep type awareness
