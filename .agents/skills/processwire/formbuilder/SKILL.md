---
name: processwire-formbuilder
description: FormBuilder Pro module API, form creation, entry management, hooks, embed methods, and customization patterns
compatibility: opencode
metadata:
  domain: processwire
  scope: formbuilder
---

## What I Do

I provide guidance for the commercial FormBuilder module:

- $forms API variable usage
- Embed methods (A, B, C, D)
- FormBuilderProcessor hooks
- Entry management
- Email configuration
- Customization patterns

## When to Use Me

Use this skill when:

- Working with the FormBuilder Pro module
- Creating custom forms programmatically
- Customizing form rendering or processing
- Managing form entries via API
- Adding custom form behaviors via hooks

---

## Getting Started

### Availability

The `$forms` API variable is only available when FormBuilder Pro module is installed.

### Embed Methods

```php
// Method A: Direct include
echo $forms->embed('form-name'); 

// Method B: iFrame
echo $forms->embed('form-name'); 

// Method C: Preferred - separate styles/scripts
$form = $forms->render('form-name');
echo $form->styles; // in <head>
echo $form->scripts; // in <head> or before </body>
echo $form; // form output

// Method D: Custom file
include($form->file);
```

---

## $forms API

### Forms

```php
// Load form by name or ID
$form = $forms->load('contact');

// Render form (embed method C)
$rendered = $forms->render('contact');
echo $rendered;

// Get all form names
$names = $forms->getFormNames();

// Count forms
$count = $forms->count();

// Add new form
$newForm = $forms->addForm('my-form');

// Save form
$forms->save($form);

// Delete form
$forms->delete($form);
```

### Entries

```php
// Get entry count
$count = $forms->countEntries('contact');

// Get single entry
$entry = $forms->getEntry($entryID, 'contact');

// Find entries across all forms
$results = $forms->findEntries('keyword');

// Save entry
$forms->saveEntry($entryData, 'contact');
```

### Utilities

```php
// Convert value to FormBuilderForm
$form = $forms->form($value);

// Get form ID
$id = $forms->formID($value);

// Get form name
$name = $forms->formName($value);

// Check if form exists
$isForm = $forms->isForm($id);

// Check reserved names
$isReserved = $forms->isReservedName('name');

// Get framework (Markup, UIKIT, Bootstrap, etc.)
$framework = $forms->getFramework($form);
```

### Files

```php
// Get files path
$path = $forms->getFilesPath();

// Get file URL
$url = $forms->getFileURL($formID, $entryID, $filename);

// View/output file
$forms->viewFile($key);
```

### Export/Import

```php
// Export form as JSON
$json = $forms->exportJSON('contact');

// Import form from JSON
$forms->importJSON('contact', $json);
```

---

## FormBuilderProcessor Hooks

The FormBuilderProcessor class contains most hookable methods for form customization.

### Rendering Hooks

```php
// Before form renders
$forms->addHookAfter('FormBuilderProcessor::renderReady', function($event) {
    $form = $event->arguments(0);
    // Add custom markup
    $event->return .= '<div class="custom-wrapper">';
});

// Modify form output
$forms->addHookAfter('FormBuilderProcessor::render', function($event) {
    $output = $event->return;
    // Modify output
});
```

### Input Processing Hooks

```php
// Before processing input
$forms->addHookBefore('FormBuilderProcessor::processInputReady', function($event) {
    $form = $event->arguments(0);
    $submitType = $event->arguments(1);
    // Validate or modify data
});

// After processing (before spam check)
$forms->addHookAfter('FormBuilderProcessor::processInputDone', function($event) {
    $form = $event->arguments(0);
});

// Check for spam
$forms->addHookBefore('FormBuilderProcessor::processInputIsSpam', function($event) {
    $form = $event->arguments(0);
    // Custom spam detection
});
```

### Entry Hooks

```php
// Before adding new entry
$forms->addHookBefore('FormBuilderProcessor::addEntryReady', function($event) {
    $data = $event->arguments(0);
    $form = $event->arguments(1);
    
    // Modify entry data before save
    $data['created_by'] = wire('user')->id;
    
    $event->arguments(0, $data);
});

// After entry added
$forms->addHookAfter('FormBuilderProcessor::addedEntry', function($event) {
    $data = $event->arguments(0);
    $form = $event->arguments(1);
    $entryId = $event->return;
});

// Before updating entry
$forms->addHookBefore('FormBuilderProcessor::updateEntryReady', function($event) {
    $data = $event->arguments(0);
    $form = $event->arguments(1);
});

// After entry updated
$forms->addHookAfter('FormBuilderProcessor::updatedEntry', function($event) {
    $data = $event->arguments(0);
    $form = $event->arguments(1);
});
```

### Email Hooks

```php
// Before admin email sent
$forms->addHookBefore('FormBuilderProcessor::emailForm', function($event) {
    $form = $event->arguments(0);
    $data = $event->arguments(1);
    
    // Modify email recipients
    $event->emailTo = "admin@example.com";
});

// After admin email ready (but not sent)
$forms->addHookAfter('FormBuilderProcessor::emailFormReady', function($event) {
    $form = $event->arguments(0);
    $email = $event->arguments(1);
    
    // Modify email
    $email->subject = "New submission: " . $form->get('formName');
});

// Before auto-responder sent
$forms->addHookBefore('FormBuilderProcessor::emailFormResponder', function($event) {
    $form = $event->arguments(0);
    $data = $event->arguments(1);
});

// Skip fields in email
$forms->addHookAfter('FormBuilderProcessor::emailFormPopulateSkipFields', function($event) {
    $email = $event->arguments(0);
    $email->setSkipFieldName('password');
    $email->setSkipFieldName('confirm_email');
});
```

### Save to Page Hooks

```php
// Before saving to page
$forms->addHookBefore('FormBuilderProcessor::savePageReady', function($event) {
    $page = $event->arguments(0);
    $data = $event->arguments(1);
    
    // Modify page before save
    $page->of(false);
    $page->title = $data['name'];
});

// After page saved
$forms->addHookAfter('FormBuilderProcessor::savePageDone', function($event) {
    $page = $event->arguments(0);
    $data = $event->arguments(1);
    $isNew = $event->arguments(2);
    
    // Do something with saved page
});
```

### Error Handling Hooks

```php
// Add error message
$forms->addHookBefore('FormBuilderProcessor::processInputReady', function($event) {
    $form = $event->arguments(0);
    
    if(someCondition()) {
        $form->addError("Custom error message");
    }
});

// Add warning (doesn't block submission)
$forms->addHookBefore('FormBuilderProcessor::processInputReady', function($event) {
    $form = $event->arguments(0);
    $form->addWarning("This is a warning");
});

// Admin-only error
$forms->addHookBefore('FormBuilderProcessor::processInputReady', function($event) {
    $form = $event->arguments(0);
    $form->adminError("Admin-only error");
});
```

---

## Common Patterns

### Custom Field Population

```php
// Populate form with data
$form = $forms->render('contact');
$form->populate([
    'name' => 'John Doe',
    'email' => 'john@example.com'
]);
echo $form;
```

### Conditional Field Values

```php
$forms->addHookBefore('FormBuilderProcessor::renderReady', function($event) {
    $form = $event->arguments(0);
    $inputfields = $form->getInputfields();
    
    // Make field read-only based on user
    if(wire('user')->isLoggedIn()) {
        $inputfields->get('email')->attr('readonly', true);
    }
});
```

### Custom Validation

```php
$forms->addHookBefore('FormBuilderProcessor::addEntryReady', function($event) {
    $data = $event->arguments(0);
    
    // Custom validation
    if($data['email'] !== $data['confirm_email']) {
        throw new WireException("Email addresses must match");
    }
});
```

### Track Submissions

```php
$forms->addHookAfter('FormBuilderProcessor::addedEntry', function($event) {
    $data = $event->arguments(0);
    $form = $event->arguments(1);
    $entryId = $event->return;
    
    wire('log')->save('form-submissions', sprintf(
        "Form: %s, Entry: %d, Email: %s",
        $form->formName,
        $entryId,
        $data['email']
    ));
});
```

### External API Integration

```php
$forms->addHookAfter('FormBuilderProcessor::addedEntry', function($event) {
    $data = $event->arguments(0);
    
    // Send to external API
    $http = new WireHttp();
    $http->send('https://api.example.com/webhook', [
        'data' => $data
    ]);
});
```

### Modify Email Recipients Conditionally

```php
$forms->addHookBefore('FormBuilderProcessor::emailForm', function($event) {
    $form = $event->arguments(0);
    $data = $event->arguments(1);
    
    // Route to different department based on selection
    if($data['department'] === 'sales') {
        $event->emailTo = 'sales@example.com';
    } else {
        $event->emailTo = 'support@example.com';
    }
});
```

### Add Google Sheets Integration

```php
$forms->addHookAfter('FormBuilderProcessor::addedEntry', function($event) {
    $data = $event->arguments(0);
    $form = $event->arguments(1);
    
    // Requires Google Sheets configured in form settings
    // Data automatically saved if configured
});
```

---

## FormBuilder Classes Reference

| Class | Purpose |
|------|---------|
| **FormBuilder** | Main API ($forms) |
| **FormBuilderProcessor** | Form lifecycle, rendering, processing |
| **FormBuilderEntries** | Entry storage and retrieval |
| **FormBuilderEmail** | Email configuration |
| **FormBuilderForm** | Form configuration and fields |
| **FormBuilderProcessorAction** | Plugin interface for extensions |

---

## Pitfalls

1. **Embed method C**: Remember to output `$form->styles` in `<head>` and `$form->scripts` before `</body>`

2. **Entry hooks**: `addEntryReady` receives raw data array, `addedEntry` runs after save with entry ID in return

3. **Email hooks**: Set properties on `$event` (like `emailTo`, `emailFrom`) in before hooks

4. **Page save**: Form must be configured to save to page in admin for page hooks to trigger

5. **Spam filtering**: Place custom spam checks before `processInputIsSpam` or hook it

6. **Session keys**: Disable `skipSessionKey` only for trusted forms, as it provides CSRF protection
