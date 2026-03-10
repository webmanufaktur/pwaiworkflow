---
name: processwire-login-register-pro
description: LoginRegisterPro module for ProcessWire - front-end user authentication, registration, login, profile editing, and user management
compatibility: opencode
metadata:
  domain: processwire
  scope: authentication
---

## What I Do

I provide comprehensive guidance for LoginRegisterPro - ProcessWire's commercial front-end user authentication module:

- User registration with email confirmation
- User login/logout functionality
- Profile editing for authenticated users
- Two-factor authentication support
- reCAPTCHA integration
- Customizable markup and templates
- Multi-language support
- Role-based access control

## When to Use Me

Use this skill when:

- Setting up front-end user authentication
- Creating registration forms
- Building login/logout functionality
- Adding profile editing for users
- Configuring email confirmations
- Implementing reCAPTCHA
- Customizing form markup
- Hooking into authentication events

---

## Getting Started

### Basic Integration

```php
<?= $modules->get('LoginRegisterPro')->execute() ?>
```

### Get Module Instance

```php
$loginRegister = $modules->get('LoginRegisterPro');
```

---

## API Methods

### Execute Forms

```php
// Render all forms (auto-detects)
echo $loginRegister->execute();

// Render specific form
echo $loginRegister->execute('login');
echo $loginRegister->execute('register');
echo $loginRegister->execute('profile');
echo $loginRegister->execute('confirm');
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `$loginRegister->userReady` | bool | User is authenticated and not editing profile |
| `$loginRegister->profileUrl` | string | URL to profile edit page |
| `$loginRegister->logoutUrl` | string | URL for logout |
| `$loginRegister->loginUrl` | string | URL for login |
| `$loginRegister->registerUrl` | string | URL for registration |

### Custom Links

```php
// Add custom action links for logged-in users
$loginRegister->addLink('/products/', 'View products');
$loginRegister->addLink('/products/add/', 'Add new product');
```

### Redirect

```php
// Set redirect URL after successful login
$loginRegister->setRedirectUrl('/dashboard/');
```

### Custom Markup

```php
// Customize markup/HTML output
$loginRegister->setMarkup('markup', '<div class="auth-form">{out}</div>');
$loginRegister->setMarkup('submit', '<button class="btn">{out}</button>');
```

### Render Assets

```php
// In <head> section
echo $loginRegister->renderStyles();
echo $loginRegister->renderScripts();

// Output notification messages
echo $loginRegister->renderNotices();
```

### Email Configuration

```php
// Set confirmation email subject
$loginRegister->emailSubject = 'Please confirm your account';

// Set plain text email body
$loginRegister->emailText = 'Click here to confirm: {confirmUrl}';

// Set HTML email body
$loginRegister->emailHtml = '<p>Click <a href="{confirmUrl}">here</a> to confirm.</p>';
```

---

## Hooks

### Login Hooks

```php
// After successful login
$wire->addHookAfter('LoginRegisterPro::loginSuccess', function(HookEvent $e) {
    $user = $e->return; // The user that logged in
    // Custom logic here
});

// Before login processing
$wire->addHookBefore('LoginRegisterPro::loginReady', function(HookEvent $e) {
    // Modify login data before processing
});

// On login error
$wire->addHookAfter('LoginRegisterPro::loginError', function(HookEvent $e) {
    $email = $e->arguments(0);
    // Handle failed login
});
```

### Registration Hooks

```php
// Before registration save
$wire->addHookBefore('LoginRegisterPro::registerReady', function(HookEvent $e) {
    // Modify registration data before save
});

// After successful registration
$wire->addHookAfter('LoginRegisterPro::registerSuccess', function(HookEvent $e) {
    $user = $e->return;
    // Custom logic after registration
});

// On registration error
$wire->addHookAfter('LoginRegisterPro::registerError', function(HookEvent $e) {
    // Handle registration error
});
```

### Profile Hooks

```php
// Before profile save
$wire->addHookBefore('LoginRegisterPro::profileSave', function(HookEvent $e) {
    $user = $e->arguments(0);
    // Modify profile data before save
});

// After profile save
$wire->addHookAfter('LoginRegisterPro::profileSuccess', function(HookEvent $e) {
    $user = $e->return;
    // Custom logic after profile update
});
```

### Confirmation Hooks

```php
// After successful confirmation
$wire->addHookAfter('LoginRegisterPro::confirmSuccess', function(HookEvent $e) {
    $user = $e->return;
    // Handle confirmation success
});
```

### General Hooks

```php
// Hook into render
$wire->addHookBefore('LoginRegisterPro::execute', function(HookEvent $e) {
    $form = $e->arguments(0);
    // Modify form before render
});
```

---

## Template Examples

### Conditional Display

```php
<?php if($user->isLoggedIn()): ?>
    <h1>Welcome <?= $user->name ?></h1>
    <?= $page->body ?>
<?php else: ?>
    <?= $modules->get('LoginRegisterPro')->execute() ?>
<?php endif; ?>
```

### Separate Login/Register

```php
<aside>
    <?= $modules->get('LoginRegisterPro')->execute('login') ?>
</aside>
<main>
    <?= $modules->get('LoginRegisterPro')->execute('register') ?>
</main>
```

### Navigation Links

```php
<?php if($user->isLoggedIn()): ?>
    <?php $lr = $modules->get('LoginRegisterPro'); ?>
    <a href="<?= $lr->profileUrl ?>">Edit Profile</a>
    <a href="<?= $lr->logoutUrl ?>">Logout</a>
<?php else: ?>
    <a href="<?= $modules->get('LoginRegisterPro')->loginUrl ?>">Login</a>
    <a href="<?= $modules->get('LoginRegisterPro')->registerUrl ?>">Register</a>
<?php endif; ?>
```

### With Redirect After Login

```php
<?php
$loginRegister = $modules->get('LoginRegisterPro');
$loginRegister->setRedirectUrl('/dashboard/');
echo $loginRegister->execute();
?>
```

---

## Configuration

### Login Settings

- Roles allowed to login on front-end
- Login form fields

### Register Settings

- Roles to add to newly registered users
- Registration form fields
- Registration expiration time
- Require email confirmation

### Confirm Settings

- Email subject and body
- From name/email
- Confirmation code expiration
- WireMail module selection

### Profile Settings

- Profile form fields
- Require password for changes
- Frontend File/Image field support

### reCAPTCHA Settings

- Google reCAPTCHA v2/v3 API keys

---

## Compatible Field Types

### Supported Fields

- Checkbox
- Email
- Text
- Textarea
- URL
- Integer
- Float
- Datetime
- Toggle
- Options (Radios, Checkboxes, Select)
- Page references (Select, Radios, Checkboxes, AsmSelect)
- **Frontend File/Image** (Profile form only)

### Unsupported Fields

- Repeater
- CKEditor
- FieldsetPage
- Multi-language fields
- PageTable
- ProFields
- PageAutocomplete
- PageListSelect
- Any field requiring admin environment

---

## Security Best Practices

1. **Limit login role** - Only allow "login-register" role for front-end login
2. **Use reCAPTCHA** - Enable to prevent spam registrations
3. **Set expiration** - Configure registration expiration for unconfirmed accounts
4. **Password requirements** - Require password for sensitive profile changes
5. **File uploads** - Use InputfieldFrontendFile module (not core file/image fields)
6. **Email notifications** - Configure admin notifications for new registrations

---

## Troubleshooting

### Form Not Rendering

1. Check module is installed and configured
2. Ensure jQuery is loaded (required)
3. Verify template has required fields

### Emails Not Sending

1. Configure WireMail module
2. Check email settings in module config
3. Verify SMTP settings if using external mail

### reCAPTCHA Not Working

1. Verify API keys are correct
2. Check reCAPTCHA version compatibility
3. Ensure domain is registered in Google reCAPTCHA console

### Profile Fields Not Showing

1. Add fields to User template in admin
2. Enable "show in profile" for each field
3. Check field type is compatible
