# ProcessWire Module Development Checklist

Comprehensive checklist covering the entire ProcessWire module development lifecycle to prevent common mistakes and ensure code quality.

---

## 1. Pre-Development Phase

### Requirements Gathering

**Success Criteria Definition:**
- [ ] Define what "done" looks like
- [ ] List all features to implement
- [ ] Identify affected templates/fields
- [ ] List edge cases to handle
- [ ] Define performance requirements
- [ ] Document backward compatibility needs

**Feature Requirements:**
- [ ] Document user-facing behavior
- [ ] Document admin interface requirements
- [ ] Document data persistence requirements
- [ ] Document hook integration points
- [ ] Document API methods (if any)

**Research:**
- [ ] Research existing patterns in core modules
- [ ] Check for similar modules in `/site/modules/`
- [ ] Review ProcessWire documentation
- [ ] Identify required hook types
- [ ] Identify field types involved

---

## 2. Hook Setup Phase

### Hook Placement

**Module Lifecycle Methods:**
- [ ] Use `init()` for early hooks (before page load, URL routing)
- [ ] Use `ready()` for API-ready hooks (most common)
- [ ] Understand when API is ready (after `ready()` called)
- [ ] Avoid putting hooks in constructor

**init() vs ready() Decision Tree:**
```
Need to access $page, $user, $pages?
├─ YES → Use ready()
└─ NO → Use init()
    (for very early hooks like URL routing)
```

### Module Configuration

**getModuleInfo() Array:**
- [ ] Include all required keys: `title`, `summary`, `version`, `href`
- [ ] Set `singular` to true for single-instance modules
- [ ] Set `autoload` to true if module needs to run always
- [ ] Use semantic versioning (MAJOR.MINOR.PATCH)
- [ ] Include `requires` or `requiresVersion` if needed

**Example:**
```php
public static function getModuleInfo() {
    return array(
        'title' => 'My Module',
        'summary' => 'Brief description',
        'version' => 001,  // or '1.0.0'
        'href' => 'https://example.com',
        'singular' => true,
        'autoload' => true,
    );
}
```

### Hook Type Selection

**Choose Correct Hook Type:**
- [ ] `before` - for validation/argument modification
- [ ] `after` - for modifying return values/logging
- [ ] `replace` - for completely replacing behavior
- [ ] `Method` - for adding new class methods
- [ ] `Property` - for adding class properties (rare)

**Decision Guide:**
| Need | Use Hook Type | Example |
|------|----------------|----------|
| Validate data before save | `before` | `Pages::saveReady` |
| Log after action completes | `after` | `Pages::saved` |
| Replace core behavior | `replace` | Custom Page::render |
| Add method to existing class | `Method` | `Page::calculate()` |
| Add property to existing class | `Property` | `Page::computedValue` |

### Hook Configuration

**Priority Settings:**
- [ ] Set appropriate priority (default is 100)
- [ ] Lower numbers (50) = run earlier
- [ ] Higher numbers (200) = run later
- [ ] Document reason for custom priority

**Conditional Hooks:**
- [ ] Use selector conditions when appropriate
- [ ] Limit hooks to specific templates: `Page(template=my-template)`
- [ ] Limit hooks to specific field values
- [ ] Use `input` conditions for AJAX/form submissions

**Example:**
```php
// Only for product pages
$this->addHookAfter('Page(template=product)::render', ...);

// Only on POST requests
if($input->is('POST')) {
    $this->addHookBefore('Pages::save', ...);
}
```

### Hook Removal Strategy

**Temporary Hooks:**
- [ ] Store hook ID for later removal: `$id = $this->addHookAfter(...)`
- [ ] Remove hook when done: `$this->removeHook($id)`
- [ ] Remove hook from within itself: `$event->removeHook(null)`

**Cleanup:**
- [ ] Remove hooks in `___uninstall()` method
- [ ] Check if module was fully installed before removing hooks
- [ ] Document which hooks need cleanup

---

## 3. Field Configuration Phase

### Configuration Hook

**Implementation:**
- [ ] Implement `getConfigInputfields()` hook (if adding field config)
- [ ] Call parent's `getConfigInputfields()` first
- [ ] Create inputfields for all configuration options
- [ ] Set proper labels (translatable with `$this->_()`)
- [ ] Provide helpful descriptions
- [ ] Set default values where appropriate

**Example Pattern:**
```php
public function addConfigHook(HookEvent $event) {
    if (!$event->object instanceof InputfieldText) return;

    $inputfields = $event->return;

    /** @var InputfieldCheckbox $field */
    $field = $this->modules->get('InputfieldCheckbox');
    $field->attr('name', 'generateGuid');
    $field->label = $this->_('Generate GUID');

    // Get existing value from Field
    $fieldObj = $this->fields->get($event->object->name);
    if($fieldObj && $fieldObj->get('generateGuid')) {
        $field->attr('checked', 'checked');
    }

    $inputfields->append($field);
}
```

### Pattern Selection

**Choose Single Access Pattern:**
- [ ] Use `$field->get('property')` consistently (RECOMMENDED)
- [ ] OR set up `addHookProperty` if needed for specific use case
- [ ] Document pattern choice in comments
- [ ] Don't mix patterns in same module

**Warning:** Pattern mixing causes configuration not saving bugs. See `processwire-field-configuration` skill.

### Helper Classes

**Complex Configuration:**
- [ ] Create helper class for complex config (if needed)
- [ ] Follow naming: `Fieldtype[Name]Helper` or `SelectableOptionConfig`
- [ ] Place in same directory as module
- [ ] Include helper class in module dependencies

**Example:**
```php
// Complex configuration in separate class
class MyFieldtypeHelper {
    public function getConfigInputfields(Field $field, InputfieldWrapper $inputfields) {
        // Build complex configuration UI
    }
}

// In main module
include_once(dirname(__FILE__) . '/MyFieldtypeHelper.php');
$helper = $this->wire(new MyFieldtypeHelper());
$inputfields = $helper->getConfigInputfields($field, $inputfields);
```

### Configuration Testing

**UI Testing:**
- [ ] Test configuration fields appear in field settings
- [ ] Verify values persist after field save
- [ ] Test default values load for new fields
- [ ] Test with existing fields
- [ ] Verify field dependencies work (collapse/expand)

**Value Persistence:**
- [ ] Test configuration saves to database
- [ ] Test configuration loads from database
- [ ] Test with different templates
- [ ] Test with context-specific settings
- [ ] Test after module reinstall

---

## 4. Code Quality Phase

### Documentation

**PHPDoc Comments:**
- [ ] Add PHPDoc for all public methods
- [ ] Include parameter types: `@param type $name Description`
- [ ] Include return types: `@return type Description`
- [ ] Document hookable methods: `/** Hookable */`
- [ ] Document special behavior

**Example:**
```php
/**
 * Generate GUID on page save
 *
 * Hookable method called before page is saved.
 *
 * @param HookEvent $event Hook event object
 * @return void
 * @see Pages::saveReady
 */
public function ___generateGuidOnSave(HookEvent $event) {
    $page = $event->arguments(0);

    if ($page->isNew()) {
        $guid = $this->generateGUID();
        $page->set('guid', $guid);
    }
}
```

### Code Style

**Indentation:**
- [ ] Use TABS for indentation (ProcessWire standard, NOT spaces)
- [ ] Use K&R brace style (opening brace on same line)
- [ ] Use unix line endings (\n)
- [ ] Keep lines under 120 characters when possible
- [ ] Align similar code for readability

**Naming Conventions:**
- [ ] Classes: PascalCase: `MyModule`, `MyHelper`
- [ ] Methods: camelCase: `myMethod()`, `savePage()`
- [ ] Variables: camelCase: `$myVariable`, `$page`
- [ ] Constants: UPPER_CASE: `MAX_RETRIES`
- [ ] Private methods: prefix with underscore: `_helper()`
- [ ] Hookable methods: prefix with `___`: `___hookableMethod()`

**Method Design:**
- [ ] Keep methods focused and single-purpose
- [ ] Don't mix concerns in one method
- [ ] Extract complex logic to helper methods
- [ ] Use early returns to reduce nesting
- [ ] Limit parameter count (ideally ≤ 4)

### Validation

**Input Sanitization:**
- [ ] Sanitize all user input from GET/POST
- [ ] Use `$sanitizer->selectorValue()` for selectors
- [ ] Use `$sanitizer->text()` for text input
- [ ] Use `$sanitizer->int()` for numbers
- [ ] Use `$sanitizer->pageName()` for page names

**Selector Sanitization:**
```php
// WRONG: Direct use of user input in selector
$selector = "title=$input->get->search";

// CORRECT: Sanitize for selector use
$search = $sanitizer->selectorValue($input->get->search);
$selector = "title=$search";
```

**Configuration Validation:**
- [ ] Validate configuration values before saving
- [ ] Check for required values
- [ ] Validate numeric ranges
- [ ] Validate option lists
- [ ] Provide helpful error messages

**Security:**
- [ ] Check for SQL injection risks
- [ ] Use prepared statements or ProcessWire selector API
- [ ] Check permissions before operations
- [ ] Use `$user->hasPermission()` for admin operations
- [ ] No sensitive data logged
- [ ] CSRF protection where needed (form submissions)

**Example Security Check:**
```php
public function sensitiveOperation(HookEvent $event) {
    if (!$this->user->hasPermission('module-name', 'permission')) {
        throw new WirePermissionException("You don't have permission");
    }

    // Proceed with sensitive operation
}
```

### Error Handling

**Exception Types:**
- [ ] Use `WireException` for ProcessWire-specific errors
- [ ] Use `WirePermissionException` for permission errors
- [ ] Use `Wire404Exception` for not found errors
- [ ] Use `WireValidationException` for validation errors
- [ ] Use PHP standard exceptions for general errors

**Error Handling:**
```php
try {
    $page = $this->pages->get($id);

    if (!$page->id) {
        throw new Wire404Exception("Page not found");
    }

    // Perform operation
    $page->set('field', $value);
    $page->save();

} catch (WireException $e) {
    $this->error("Operation failed: " . $e->getMessage());
    throw $e;  // Re-throw or handle gracefully
} catch (Exception $e) {
    $this->error("Unexpected error: " . $e->getMessage());
}
```

**Logging:**
- [ ] Log important events: `$this->log->save('my-log', $message)`
- [ ] Log errors for debugging
- [ ] Use appropriate log levels (info, warning, error)
- [ ] Don't log sensitive data (passwords, tokens)
- [ ] Check log file location: `/site/assets/logs/`

### Magic Methods

**Hookable Methods:**
- [ ] Use `___` prefix for hookable methods
- [ ] Call without `___` for normal usage
- [ ] Document which methods are hookable in PHPDoc
- [ ] Don't make everything hookable - only what needs it

**Magic Properties:**
- [ ] Check for magic property conflicts
- [ ] Don't override core magic properties
- [ ] Use `__get()` sparingly
- [ ] Document magic behavior

**Example:**
```php
// Hookable - other modules can hook this
public function ___savePage(HookEvent $event) {
    // Default implementation
}

// Call this (with hooks applied)
$this->savePage($event);
```

---

## 5. Testing Phase

### Manual Testing

**Module Installation:**
- [ ] Module installs without errors
- [ ] Module uninstall works cleanly
- [ ] Module reinstall preserves configuration (if desired)
- [ ] Module appears in Modules list
- [ ] Module configuration page loads
- [ ] No PHP warnings in logs

**Functionality Testing:**
- [ ] Hooks fire at expected times
- [ ] New pages work correctly
- [ ] Existing pages not broken
- [ ] Admin interface functions properly
- [ ] Front-end functionality works
- [ ] No performance degradation

### Field Configuration Testing

**UI Testing:**
- [ ] Configuration fields appear in field settings
- [ ] Values persist after save
- [ ] Default values work for new fields
- [ ] Field dependencies function correctly (collapse/expand)
- [ ] Required fields enforce properly
- [ ] Show-if conditions work

**Value Persistence:**
- [ ] Test configuration saves to database
- [ ] Test configuration loads from database
- [ ] Test with multiple templates
- [ ] Test after module reinstall
- [ ] Test migration from old versions

### Hook Testing

**Hook Execution:**
- [ ] Before hooks execute before action
- [ ] After hooks execute after action
- [ ] Hooks receive correct arguments
- [ ] Hooks can modify return values correctly
- [ ] Hooks don't cause infinite loops
- [ ] Multiple hooks on same method work in correct order

**Conditional Hooks:**
- [ ] Hooks match expected templates
- [ ] Hooks match expected page conditions
- [ ] Hooks match expected field values
- [ ] Hooks don't fire when they shouldn't
- [ ] Hooks fire for all matching conditions

### Edge Cases

**Empty/Null Values:**
- [ ] Empty strings handled correctly
- [ ] Null values handled correctly
- [ ] Arrays/objects handle empty state
- [ ] Default values applied when empty
- [ ] No errors on missing data

**Boundary Values:**
- [ ] Maximum values enforced correctly
- [ ] Minimum values enforced correctly
- [ ] Zero values handled correctly
- [ ] Negative values handled appropriately
- [ ] Very large values don't cause overflow

**Special Characters:**
- [ ] Quotes handled correctly
- [ ] HTML entities handled appropriately
- [ ] Unicode characters supported
- [ ] Line breaks handled correctly
- [ ] SQL injection attempts blocked

**Concurrent Operations:**
- [ ] Multiple simultaneous saves don't conflict
- [ ] Race conditions handled
- [ ] Transactions used when needed
- [ ] Cache invalidation works correctly
- [ ] Locking used for critical operations

### Automated Testing

**Framework Selection - Choose One:**

**Option A: Using Pest (Recommended for modern PHP)**

**Setup:**
```bash
composer require pestphp/pest --dev
```

**Example Test File:**
```php
// tests/MyModuleTest.php
use PHPUnit\Framework\TestCase;
use ProcessWire\Wire;
use ProcessWire\Pages;
use ProcessWire\Page;

it('generates GUID on new page save', function() {
    // Create test page
    $page = $this->wire->pages->new();
    $page->template = $this->wire->templates->get('basic-page');
    $page->title = 'Test Page';
    $page->save();

    // Check GUID was generated
    expect($page->my_guid_field)->not()->toBeEmpty();
    expect(strlen($page->my_guid_field))->toBe(36);
});

it('does not regenerate GUID on subsequent saves', function() {
    // Create page
    $page = $this->wire->pages->new();
    $page->template = $this->wire->templates->get('basic-page');
    $page->title = 'Test Page';
    $page->save();

    $firstGuid = $page->my_guid_field;

    // Save again
    $page->save();

    // GUID should not change
    expect($page->my_guid_field)->toBe($firstGuid);
});
```

**Run Tests:**
```bash
vendor/bin/pest
```

**Checklist:**
- [ ] Unit tests for critical functions
- [ ] Tests for hook execution
- [ ] Tests for edge cases
- [ ] Tests pass in isolation
- [ ] Tests cover >80% of code

---

**Option B: Using PHPUnit (Traditional)**

**Setup:**
```bash
composer require phpunit/phpunit --dev
```

**Example Test File:**
```php
// tests/MyModuleTest.php
class MyModuleTest extends TestCase {

    public function testGuidGenerationOnSave() {
        // Create test page
        $page = $this->wire->pages->new();
        $page->template = $this->wire->templates->get('basic-page');
        $page->title = 'Test Page';
        $page->save();

        // Check GUID was generated
        $this->assertNotEmpty($page->my_guid_field);
        $this->assertEquals(36, strlen($page->my_guid_field));
    }

    public function testGuidRegeneration() {
        // Create page
        $page = $this->wire->pages->new();
        $page->template = $this->wire->templates->get('basic-page');
        $page->title = 'Test Page';
        $page->save();

        $firstGuid = $page->my_guid_field;

        // Save again
        $page->save();

        // GUID should not change
        $this->assertEquals($firstGuid, $page->my_guid_field);
    }
}
```

**Run Tests:**
```bash
vendor/bin/phpunit
```

**Checklist:**
- [ ] Unit tests for critical functions
- [ ] Tests for hook execution
- [ ] Tests for edge cases
- [ ] Tests pass in isolation
- [ ] Tests cover >80% of code

### Performance Testing

**Response Time:**
- [ ] Page load time < 200ms (typical pages)
- [ ] Admin page load time < 500ms
- [ ] Hook execution time measured
- [ ] No N+1 database queries
- [ ] Database queries optimized

**Profiling:**
```php
// Measure execution time
$timer = \Debug::timer();

// Your code here
$result = $this->doSomething();

$elapsed = $timer->total();
if($elapsed > 0.2) {  // 200ms
    $this->log->save('performance', "Slow operation: {$elapsed}s");
}
```

**Memory Usage:**
- [ ] Memory usage is reasonable
- [ ] No memory leaks in loops
- [ ] Large datasets handled efficiently
- [ ] Caching used for expensive operations
- [ ] Array size limits considered

---

## 6. Code Review Phase

### Pattern Consistency

**Access Patterns:**
- [ ] All field config uses single pattern (e.g., $field->get())
- [ ] No mixed `$field->get()` vs `$inputfield->property`
- [ ] Hook property uses verified against event object type
- [ ] No addHookProperty usage without clear need
- [ ] Consistent use of `$this->wire()` vs direct property access

**Code Style:**
- [ ] All code follows PSR-12 with TABS
- [ ] All methods follow naming conventions
- [ ] All classes follow naming conventions
- [ ] No trailing whitespace
- [ ] No commented-out code
- [ ] No debug code left in

### Security Review

**Input Validation:**
- [ ] All user input is sanitized
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities
- [ ] No path traversal vulnerabilities
- [ ] No CSRF vulnerabilities

**Permissions:**
- [ ] Permission checks in place for sensitive operations
- [ ] Superuser checks where appropriate
- [ ] Role-based access control
- [ ] Access denied errors are informative

**Data Exposure:**
- [ ] No sensitive data in error messages
- [ ] No sensitive data in logs
- [ ] No sensitive data in URLs
- [ ] No debug information in production

### Dependency Review

**Module Dependencies:**
- [ ] All modules exist (or optional)
- [ ] Module versions specified if needed
- [ ] No circular dependencies
- [ ] Appropriate fallbacks for optional modules
- [ ] Check for conflicts with other modules

**ProcessWire Version:**
- [ ] Compatible with target ProcessWire version
- [ ] Version constraints documented
- [ ] Tests pass on minimum supported version
- [ ] Graceful degradation on older versions

### Performance Review

**Database Queries:**
- [ ] No N+1 queries in loops
- [ ] Indexes used where appropriate
- [ ] No unnecessary queries
- [ ] Efficient selectors used
- [ ] Large result sets limited

**Caching Strategy:**
- [ ] Caching used for expensive operations
- [ ] Cache invalidated when data changes
- [ ] Cache keys are appropriate
- [ ] Cache timeouts are reasonable
- [ ] No stale cache issues

**Hook Optimization:**
- [ ] Early returns used to skip processing
- [ ] No heavy operations in render hooks
- [ ] No heavy operations in frequently called hooks
- [ ] Hook priorities set appropriately
- [ ] Conditional hooks used to limit execution

---

## 7. Deployment Phase

### Version Management

**Semantic Versioning (MAJOR.MINOR.PATCH):**
- [ ] MAJOR: Increment for breaking changes (1.0.0 → 2.0.0)
- [ ] MINOR: Increment for new features, backward compatible (1.0.0 → 1.1.0)
- [ ] PATCH: Increment for bug fixes (1.0.0 → 1.0.1)

**getModuleInfo() Update:**
```php
public static function getModuleInfo() {
    return array(
        'title' => 'My Module',
        'summary' => 'Brief description',
        'version' => 102,  // Incremented appropriately
        'href' => 'https://example.com',
    );
}
```

**Breaking Changes:**
- [ ] Document breaking changes clearly
- [ ] Provide migration path
- [ ] Update version to MAJOR
- [ ] Test migration on sample data
- [ ] Rollback plan documented

### Changelog

**CHANGELOG.md Structure:**
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- New feature 1 description
- New feature 2 description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

## [1.2.3] - 2024-01-15

### Added
- Feature added in this version

### Fixed
- Bug fixed in this version
```

**Changelog Checklist:**
- [ ] Add entry to CHANGELOG.md
- [ ] Document breaking changes
- [ ] List new features
- [ ] Note bug fixes
- [ ] Include migration notes if needed
- [ ] Use ISO date format (YYYY-MM-DD)

### Testing

**Pre-Deployment:**
- [ ] Run full test suite
- [ ] Manual smoke test on staging
- [ ] Test upgrade from previous version
- [ ] Test downgrade capability (if supported)
- [ ] Test on multiple ProcessWire versions
- [ ] Test on multiple PHP versions

**Smoke Test Checklist:**
- [ ] Module installs without errors
- [ ] Core functionality works
- [ ] Admin interface loads
- [ ] No PHP warnings in logs
- [ ] Database migrations successful
- [ ] Performance is acceptable

### Rollback Plan

**Pre-Deployment:**
- [ ] Document rollback procedure
- [ ] Backup current database
- [ ] Backup installed files
- [ ] Test rollback on staging
- [ ] Prepare hotfix branch if needed

**Rollback Procedure:**
```bash
# Database rollback
mysql < backup.sql

# File rollback
git revert <commit-hash>

# Module reinstall
# Admin -> Modules -> Uninstall -> Reinstall specific version
```

### Documentation

**README.md:**
- [ ] Module description is clear
- [ ] Installation instructions provided
- [ ] Configuration instructions provided
- [ ] Usage examples included
- [ ] API methods documented (if any)
- [ ] Screenshots included (if applicable)

**Example README:**
```markdown
# My Module

## Description
Brief description of what this module does.

## Installation

1. Install via Modules → Add New → My Module
2. Configure module settings as needed
3. Add module hooks (if needed)

## Usage

```php
// Example usage
$result = $modules->get('MyModule')->doSomething();
```

## Configuration

Explain configuration options and their effects.

## API Methods

Document any public API methods.

## Troubleshooting

Common issues and solutions.
```

**In-Code Documentation:**
- [ ] PHPDoc comments complete
- [ ] Complex logic explained in comments
- [ ] Hookable methods documented
- [ ] Known issues documented in code
- [ ] Performance notes included

---

## 8. Git Workflow Best Practices

### Branch Naming

**Feature Branches:**
```bash
git checkout -b feature/guid-prefix-support
git checkout -b feature/uuid-alphanumeric-formats
```

**Fix Branches:**
```bash
git checkout -b fix/field-config-not-saving
git checkout -b fix/guid-generation-fails
```

**Refactor Branches:**
```bash
git checkout -b refactor/field-config-patterns
git checkout -b refactor/hook-optimization
```

**Documentation Branches:**
```bash
git checkout -b docs/readme-updates
git checkout -b docs/changelog
```

### Commit Messages

**Conventional Commits Format:**
```
type(scope): description

# Optional body

# Optional footer
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring
- `docs` - Documentation changes
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `style` - Code style changes
- `perf` - Performance improvements
- `revert` - Revert previous commit

**Examples:**
```
feat(guid): add prefix support for GUID generation

- Added guidPrefix configuration option
- Updated generation logic to include prefix
- Added prefix field to admin UI

Closes #123
```

```
fix(field): configuration not persisting in admin

- Fixed Field->get() pattern usage
- Updated getConfigInputfields hook
- Tested on ProcessWire 3.0.x

Fixes #456
```

```
docs(readme): add troubleshooting section

- Added common issues and solutions
- Updated installation instructions
- Added API documentation
```

### Tagging Releases

**Tag Format:**
```bash
git tag v1.2.3
git push --tags
```

**Annotated Tags:**
```bash
git tag -a v1.2.3 -m "Release 1.2.3: Add prefix support"

# Annotated message format
# Release X.Y.Z: Brief description

## Added
- New feature 1

## Fixed
- Bug fix 1
```

**GitHub Release:**
- [ ] Create GitHub release for tag
- [ ] Attach CHANGELOG.md or release notes
- [ ] Link to related issues
- [ ] Mark pre-release versions if needed

### Hotfix Handling

**Hotfix Branch Creation:**
```bash
# From main/master
git checkout -b hotfix/urgent-fix
```

**Hotfix Merge Process:**
```bash
# 1. Make fix
git add .
git commit -m "fix(urgent): critical bug fix"

# 2. Merge to main/master
git checkout main
git merge hotfix/urgent-fix

# 3. Tag as patch version
git tag v1.2.4

# 4. Merge back to develop (if using git-flow)
git checkout develop
git merge hotfix/urgent-fix

# 5. Push all
git push origin main
git push origin develop
git push --tags
```

**Hotfix Checklist:**
- [ ] Hotfix branch created from stable branch
- [ ] Fix is minimal and focused
- [ ] Hotfix tested thoroughly
- [ ] Backported to stable branch
- [ ] Patch version created
- [ ] All branches pushed
- [ ] Release created for hotfix

### Version File

**VERSION File (Optional):**
```bash
# .version
1.2.3
```

**Read in Module:**
```php
public static function getModuleInfo() {
    $version = file_get_contents(__DIR__ . '/.version');
    return array(
        'title' => 'My Module',
        'version' => $version,
        // ...
    );
}
```

---

## 9. Common Pitfalls

### Pattern Mixing

**Problem:**
Using different configuration access patterns in different contexts leads to inconsistent behavior and hard-to-debug issues.

**Example:**
```php
// getConfigInputfields hook:
$inputfield->generateGuid      // Requires addHookProperty

// saveReady hook:
$inputfield->generateGuid      // Inputfield not available here!
```

**Fix:**
```php
// Choose ONE pattern consistently
$field->get('generateGuid');  // Works everywhere
```

**Prevention:**
- [ ] Search for pattern usage before changing: `grep -rn "generateGuid\|guidFormat"`
- [ ] Update ALL references consistently
- [ ] Test that one pattern works everywhere
- [ ] Document pattern choice in module comments

### Hook Removal Mistakes

**Problem:**
Removing code without verifying it's not used elsewhere breaks functionality.

**Example:**
```php
// Original code:
$this->addHookProperty('InputfieldText::mySetting', ...);

// DANGEROUS: Removing without checking
// Because getConfigInputfields used $inputfield->mySetting
```

**Prevention Protocol:**
```bash
# 1. Search all usages
grep -rn "mySetting" MyModule.module

# 2. Check context around each usage
# 3. Understand WHY it exists
# 4. Test removal in isolation
# 5. Update ALL references consistently
```

**Checklist:**
- [ ] Never remove code without searching for usages first
- [ ] Read entire file to understand context
- [ ] Ask "why was this code added?"
- [ ] Test pattern change thoroughly
- [ ] Update all references to new pattern

### Breaking Changes in Minor Versions

**Problem:**
Breaking changes in minor versions cause unexpected issues for users upgrading.

**Example:**
- Changed public method signature (1.0.0 → 1.1.0)
- Removed configuration option (1.2.0 → 1.2.3)
- Changed hook behavior (1.0.5 → 1.1.0)

**Prevention:**
- [ ] Increment MAJOR version for breaking changes
- [ ] Document breaking changes clearly
- [ ] Provide migration path
- [ ] Add backward compatibility layer if possible
- [ ] Deprecate features before removing

### Testing Insufficient

**Problem:**
Inadequate testing leads to bugs in production.

**Example:**
- Only tested with new pages, not existing pages
- Only tested with one template
- No edge case testing
- No performance testing

**Prevention:**
- [ ] Test with multiple page templates
- [ ] Test with new and existing pages
- [ ] Test with edge cases (empty, max values)
- [ ] Test on different ProcessWire versions
- [ ] Test on different PHP versions
- [ ] Manual testing required even with automated tests

### Wrong Object Context

**Problem:**
Assuming wrong object type in hooks leads to undefined property/method errors.

**Example:**
```php
// WRONG: Assuming Inputfield in Page hook
public function saveHook(HookEvent $event) {
    $page = $event->arguments(0);
    $inputfield = $page->getField('my_field');  // Returns Field, not Inputfield
    if($inputfield->someProperty) {  // Won't work
        // ...
    }
}
```

**Fix:**
```php
// CORRECT: Use appropriate object
public function saveHook(HookEvent $event) {
    $page = $event->arguments(0);
    $field = $page->template->fieldgroup->get('my_field');

    // Field object has the configuration
    if($field->get('someProperty')) {
        // ...
    }
}
```

**Checklist:**
- [ ] Verify `$event->object` type matches expectations
- [ ] Check hook documentation for object types
- [ ] Don't assume Page when it's PageArray
- [ ] Don't assume Field when it's Inputfield
- [ ] Use instanceof checks before type-specific operations

---

## 10. Development Environment Setup

### PHPStan Configuration

**Installation:**
```bash
composer require phpstan/phpstan --dev
composer require --dev processwire/wire-core-stubs
```

**phpstan.neon Configuration:**
```neon
parameters:
    paths:
        - site/modules/
        - wire/core/
    level: 5
    stubFiles:
        - vendor/processwire/wire-core-stubs/wire-core-stubs.php
    ignoreErrors:
        - '#Call to an undefined method#'
        - '#Access to undefined property#'
        - '#Unsafe usage of new static#'
    checkGenericClassInNonGenericObjectType: false
```

**Run PHPStan:**
```bash
vendor/bin/phpstan analyse site/modules/MyModule
```

**Checklist:**
- [ ] PHPStan configured with stub files
- [ ] Analysis level set appropriately (3-8)
- [ ] Errors are fixed before commit
- [ ] No ignored errors that shouldn't be

### PHP-CS-Fixer Configuration

**Installation:**
```bash
composer require friendsofphp/php-cs-fixer --dev
```

**.php-cs-fixer.php Configuration:**
```php
<?php
return (new PhpCsFixer\Config())
    ->setRules([
        '@PSR12' => true,
        'indentation_type' => 'tab',  // ProcessWire uses tabs!
        'no_unused_imports' => true,
        'array_syntax' => 'short',
        'ordered_imports' => true,
        'no_unused_imports' => true,
        'single_blank_line_at_eof' => true,
    ])
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->in('site/modules')
            ->name('*.module')
    );
```

**Run PHP-CS-Fixer:**
```bash
vendor/bin/php-cs-fixer fix site/modules/MyModule
```

**Checklist:**
- [ ] Tabs used for indentation (not spaces)
- [ ] PSR-12 compliance checked
- [ ] Code style consistent
- [ ] No style violations in commit

### VS Code Settings

**.vscode/settings.json Configuration:**
```json
{
  "intelephense.environment.phpVersion": "8.1",
  "intelephense.files.exclude": [
    "**/node_modules/**",
    "**/vendor/**"
  ],
  "intelephense.files.associations": {
    "*.module": "php",
    "*.inc": "php"
  },
  "files.associations": {
    "*.module": "php"
  },
  "php.validate.executablePath": "/usr/bin/php",
  "php.suggest.basic": false
}
```

**VS Code Extensions:**
- [ ] PHP Intelephense installed
- [ ] PHP DocBlocker installed
- [ ] GitLens installed (optional)
- [ ] ProcessWire Language Highlight (optional)

**Checklist:**
- [ ] IDE configured for ProcessWire development
- [ ] PHP version matches production
- [ ] Autocomplete works for ProcessWire API
- [ ] File associations correct

### Local Development Configuration

**/site/config.php - Debug Settings:**
```php
// Enable debug mode
$config->debug = true;

// Debug only for specific users
$config->debugIf = 'user==admin';

// Enable advanced mode (more detailed error messages)
$config->advanced = true;

// Set development-friendly permissions
$config->chmodDir = '0755';
$config->chmodFile = '0644';

// Custom admin URL (for development)
$config->adminUrl = 'admin/';
```

**Log File Locations:**
```php
// Error log
/site/assets/logs/errors.txt

// Exceptions log
/site/assets/logs/exceptions.txt

// Module-specific logs
/site/assets/logs/my-module.txt
```

**Checklist:**
- [ ] Debug mode enabled for development
- [ ] Log locations known
- [ ] Permissions allow development
- [ ] Error messages are detailed
- [ ] Logs are accessible for debugging

---

## 11. Troubleshooting Guide

### Configuration Not Saving

**Symptoms:**
- Configuration values not persisting
- Default values not loading
- Configuration UI not appearing

**Common Causes & Fixes:**

| Cause | Fix |
|--------|------|
| Wrong object context in `getConfigInputfields` | Check `$event->object` type is Inputfield |
| Not using `$event->return->append()` | Append config fields to wrapper |
| Missing `attr('name')` on inputfield | Set name matching database key |
| Using `$inputfield->property` without hook | Use `$field->get('property')` instead |
| Field name mismatch | Ensure inputfield name matches field name |

**Debug Steps:**
```php
// Add temporary logging in getConfigInputfields hook
public function addConfigHook(HookEvent $event) {
    $this->log->save('debug', 'getConfigInputfields called');
    $this->log->save('debug', 'Object type: ' . get_class($event->object));

    // ... your code
}
```

**Checklist:**
- [ ] Check error log: `/site/assets/logs/errors.txt`
- [ ] Verify field type matches hook target
- [ ] Check `$event->return->append()` is called
- [ ] Enable debug mode: `$config->debug = true`
- [ ] Verify inputfield names match database keys

### Hooks Not Firing

**Symptoms:**
- Hook code not executing
- Expected behavior not happening
- No errors in logs

**Common Causes & Fixes:**

| Cause | Fix |
|--------|------|
| Module not installed | Install via Modules → Add New |
| Autoload not enabled | Set `'autoload' => true` in `getModuleInfo()` |
| Hook in wrong method | Use `init()` for early hooks, `ready()` for API-ready |
| Hook name misspelled | Check ProcessWire API documentation |
| Hook priority conflict | Adjust priority values |

**Debug Steps:**
```php
// Add logging to hook method
public function myHook(HookEvent $event) {
    $this->log->save('hook-test', 'Hook executed');

    // ... your code
}
```

**Checklist:**
- [ ] Verify module is installed and active
- [ ] Check autoload setting in `getModuleInfo()`
- [ ] Ensure hook is attached in `ready()` or `init()`
- [ ] Verify hook name matches ProcessWire method name exactly
- [ ] Check for hook priority conflicts

### Wrong Object Context

**Symptoms:**
- "Call to undefined method"
- "Access to undefined property"
- PHP fatal errors

**Common Causes & Fixes:**

| Cause | Fix |
|--------|------|
| Assuming Page when it's PageArray | Use `foreach` for PageArray |
| Assuming Inputfield when it's Field | Use `$field->get()` not `$inputfield->property` |
| Assuming WireData when it's Page | Check actual type before access |

**Debug Steps:**
```php
// Add type checking
public function myHook(HookEvent $event) {
    $obj = $event->object;

    $this->log->save('debug', 'Object type: ' . get_class($obj));

    if($obj instanceof Page) {
        // Safe to access Page methods
    } else if($obj instanceof Field) {
        // Safe to access Field methods
    } else {
        $this->log->save('error', 'Unexpected object type');
        return;
    }

    // ... your code
}
```

**Checklist:**
- [ ] Check `$event->object` type matches expectations
- [ ] Use `instanceof` checks before type-specific operations
- [ ] Verify hook documentation for object types
- [ ] Check for type mismatches in PHPStan analysis

### Performance Issues

**Symptoms:**
- Page loads are slow (>1 second)
- High memory usage
- Database query count too high
- Timeouts

**Common Causes & Fixes:**

| Cause | Fix |
|--------|------|
| N+1 queries in loops | Use `wire()` cache or preload data |
| Heavy operations in render hooks | Move to save hooks or background |
| No caching for expensive lookups | Implement caching strategy |
| Large result sets not limited | Add `limit()` to selectors |

**Debug Steps:**
```php
// Use Debug timer
$timer = \Debug::timer();

// Your expensive operation here
$result = $this->expensiveOperation();

$elapsed = $timer->total();
$this->log->save('performance', "Operation took: {$elapsed}s");

if($elapsed > 0.5) {
    $this->log->save('performance-warning', 'Slow operation detected');
}
```

**Checklist:**
- [ ] Profile slow operations with `\Debug::timer()`
- [ ] Check for N+1 database queries in loops
- [ ] Add caching for expensive operations
- [ ] Move heavy operations out of render hooks
- [ ] Use `WireCache` for repeated expensive lookups
- [ ] Limit result sets with selector limits

### Module Not Loading

**Symptoms:**
- Module not appearing in Modules list
- Hooks not firing
- Autoload errors

**Common Causes & Fixes:**

| Cause | Fix |
|--------|------|
| PHP syntax errors | Run `php -l module.module` |
| Wrong namespace | Ensure `namespace ProcessWire;` |
| Missing `implements Module` | Add `implements Module` to class declaration |
| Wrong file permissions | Ensure PHP can read module file |
| Wrong `getModuleInfo()` format | Return array with required keys |

**Debug Steps:**
```bash
# Check syntax
php -l site/modules/MyModule.module

# Check error logs
tail -f site/assets/logs/errors.txt

# Check ProcessWire system logs
tail -f site/assets/logs/wire-errors.txt
```

**Checklist:**
- [ ] Check PHP version compatibility
- [ ] Verify namespace is correct: `namespace ProcessWire;`
- [ ] Check `implements Module` is present
- [ ] Verify `getModuleInfo()` returns correct array keys
- [ ] Check for syntax errors: `php -l module.module`

### Investigation Protocol

**Before Removing/Changing Code:**

```bash
# 1. Read entire file to understand context
#    Check all hook placements
#    Understand configuration access patterns used

# 2. Search all usages
grep -rn "methodName\|propertyName" MyModule.module
#    Note which hooks use it
#    Note which contexts access it

# 3. Check git history (if available)
git log -p --all -S "methodName"
#    Understand why code was added
#    Check for related issues/commits

# 4. Ask: "Why was this code added?"
#    Was it for backward compatibility?
#    Is it used in other hooks?
#    Does removing it break anything?

# 5. Test pattern change in isolation first
#    Create test branch
#    Make changes
#    Run tests
#    Verify behavior

# 6. Update ALL references consistently
#    Don't leave mixed patterns
#    Update all usages found in step 2
#    Test again

# 7. Run full test suite
#    Smoke test manually
#    Check error logs

# 8. Commit with clear message
#    Explain what changed and why
```

**Checklist:**
- [ ] Read entire file before modifying
- [ ] Search all usages: `grep -rn "pattern" file.php`
- [ ] Check git history: `git log -p file.php`
- [ ] Understand purpose before modifying
- [ ] Test pattern change in isolation first
- [ ] Update ALL references consistently
- [ ] Run full test suite

---

## 12. Cross-References

### Related Skills

- **processwire-hooks** - Hook types (before/after/replace), HookEvent object, hookable methods
- **processwire-fields** - Field types (text, textarea, file, page), Inputfields, values, dependencies
- **processwire-modules** - Module structure, API access patterns, ready() vs init()
- **processwire-selectors** - Selector syntax for finding pages by field values
- **processwire-field-configuration** - Configuration access patterns, Field vs Inputfield relationship

### When to Use Each

| Question | Use This Skill When | Use Other Skills For |
|----------|---------------------|---------------------|
| How do I add configuration UI? | processwire-field-configuration (getConfigInputfields pattern) | processwire-hooks (hook setup) |
| How do I read config in hooks? | processwire-field-configuration (Hook Type Reference) | processwire-hooks (Pages hooks) |
| What field types exist? | processwire-fields skill | N/A |
| How do I create hooks? | processwire-hooks skill | N/A |
| How do I find pages? | processwire-selectors skill | N/A |
| How do I build a module? | processwire-modules skill (this checklist) | N/A |

### Related Specs

- **modules/guid-extend-features.md** - GuidGenerator specific implementation details
- **modules/module-development-checklist.md** - This document

---

## Summary

This checklist provides comprehensive coverage of ProcessWire module development:

1. **Pre-Development** - Requirements, research, environment setup
2. **Hook Setup** - Placement, types, configuration, removal
3. **Field Configuration** - getConfigInputfields, pattern selection, helpers
4. **Code Quality** - Documentation, style, validation, error handling
5. **Testing** - Manual, automated, edge cases, performance
6. **Code Review** - Consistency, security, dependencies, performance
7. **Deployment** - Versioning, changelog, testing, rollback
8. **Git Workflow** - Branching, commits, tagging, hotfixes
9. **Common Pitfalls** - Pattern mixing, hook removal, breaking changes, testing
10. **Environment Setup** - PHPStan, PHP-CS-Fixer, VS Code, local config
11. **Troubleshooting** - Configuration, hooks, object context, performance, loading
12. **Cross-References** - Related skills and when to use each

**Key Takeaway:** Choose a single pattern for field configuration access (recommend `$field->get('property')`) and use it consistently throughout your module.
