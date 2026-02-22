---
name: processwire-security
description: Security best practices, file permissions, admin security, two-factor authentication, input sanitization, CSRF protection, and secure coding
compatibility: opencode
metadata:
  domain: processwire
  scope: security
---

## What I Do

I provide comprehensive guidance for ProcessWire security:

- File and directory permissions
- Admin security best practices
- Two-factor authentication (2FA/TFA)
- Input sanitization
- CSRF protection
- Secure template coding
- Session security
- Production deployment security

## When to Use Me

Use this skill when:

- Setting up file permissions
- Securing the admin panel
- Implementing two-factor authentication
- Sanitizing user input
- Protecting against XSS and CSRF attacks
- Deploying to production
- Hardening a ProcessWire installation

---

## File Permissions

### Recommended Permissions

| Type            | Secure  | Standard | Insecure |
| --------------- | ------- | -------- | -------- |
| **Directories** | 700/750 | 755      | 777      |
| **Files**       | 600/640 | 644      | 666      |
| **config.php**  | 400/440 | 600      | 644      |

### Setting Permissions in config.php

```php
// /site/config.php
$config->chmodDir = '0755';   // Directories created by PW
$config->chmodFile = '0644';  // Files created by PW
```

### Changing Permissions (SSH)

```bash
# Single file
chmod 600 site/config.php

# Single directory
chmod 755 site/assets

# All directories recursively
find site/assets -type d -exec chmod 755 {} \;

# All files recursively
find site/assets/ -type f -exec chmod 644 {} \;
```

### Determine if Apache Runs as You

Create a test file:

```php
<?php echo exec('whoami');
```

- If output is your username: Use 755/644
- If output is "nobody", "www", "apache": May need 775/664 or consult host

### Writable Directories

These directories need to be writable:

- `/site/assets/` and all subdirectories
- `/site/modules/` (optional, for admin module installation)

### config.php Security

Lock down after installation:

```bash
chmod 400 site/config.php  # Read-only, owner only
# Or if that doesn't work:
chmod 440 site/config.php  # Read-only, owner and group
```

---

## Admin Security

### Hide Admin URL

Default is `/processwire/`. Change it:

1. Login to admin
2. Click Admin page in tree
3. Settings tab > change Name field
4. Save (you'll get 404, navigate to new URL)

### Require HTTPS for Admin

1. Setup > Templates > Filters > Show system templates > Yes
2. Click "admin" template
3. URLs tab > Scheme/Protocol > "HTTPS only"
4. Save

### Login Throttling

Built-in via Session Login Throttle module. Configure at:
Modules > Core > Session > Login Throttle

Enable "Throttle by IP address" if users don't share IPs.

### Strong Passwords

Enforce via field settings:
Fields > Show System Fields > Edit "pass" field

Options:

- Minimum length
- Require letters + numbers
- Require mixed case
- Require symbols

### Session Logging

Monitor logins at: Setup > Logs > session

Consider installing:

- Login Notifier module
- Login History module

---

## Two-Factor Authentication

### Available Modules

| Module     | Method                                        |
| ---------- | --------------------------------------------- |
| `TfaTotp`  | TOTP apps (Authy, Google Authenticator, etc.) |
| `TfaEmail` | Email/SMS codes                               |

### Setup

1. Install Tfa module(s) from Modules
2. Configure at Modules > Configure > ProcessLogin
3. Users enable in their profile (tfa_type field)

### Enforce 2FA

Use TfaEmail to enforce 2FA for all users:

- Users without authenticator apps get email codes
- More secure users can still use TOTP

---

## Input Sanitization

### The $sanitizer API

Always sanitize user input before use:

```php
// Text sanitization
$name = $sanitizer->text($input->post->name);
$email = $sanitizer->email($input->post->email);
$url = $sanitizer->url($input->post->website);

// For selectors
$q = $sanitizer->selectorValue($input->get->q);
$pages->find("title*=$q");

// Page names (for URLs)
$pageName = $sanitizer->pageName($input->post->username);

// Integer
$id = $sanitizer->int($input->get->id);

// Array of integers
$ids = $sanitizer->intArray($input->post->ids);
```

### Common Sanitizers

| Method                | Purpose                       |
| --------------------- | ----------------------------- |
| `text($str)`          | Single line text, strips tags |
| `textarea($str)`      | Multi-line text, strips tags  |
| `email($str)`         | Valid email address           |
| `url($str)`           | Valid URL                     |
| `int($val)`           | Integer                       |
| `float($val)`         | Float/decimal                 |
| `pageName($str)`      | Valid page name (URL segment) |
| `name($str)`          | Valid ProcessWire name        |
| `selectorValue($str)` | Safe for use in selectors     |
| `entities($str)`      | HTML entity encode            |
| `purify($str)`        | HTML Purifier (safe HTML)     |
| `array($val)`         | Ensure array                  |
| `intArray($val)`      | Array of integers             |

### HTML Output Encoding

```php
// Encode for HTML output
echo $sanitizer->entities($userInput);

// Or use htmlspecialchars
echo htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');
```

### Rich Text (Allow Safe HTML)

```php
// Uses HTML Purifier
$safeHtml = $sanitizer->purify($input->post->content);
```

---

## CSRF Protection

### Form Tokens

ProcessWire automatically handles CSRF for admin forms. For custom forms:

```php
// In form
<form method="post">
    <?php echo $session->CSRF->renderInput(); ?>
    <!-- form fields -->
</form>

// When processing
if($input->post->submit) {
    if(!$session->CSRF->hasValidToken()) {
        throw new WireException("Invalid request");
    }
    // Process form
}
```

### Token Methods

```php
// Get token name and value
$tokenName = $session->CSRF->getTokenName();
$tokenValue = $session->CSRF->getTokenValue();

// Validate token
if($session->CSRF->validate()) {
    // Valid
}

// Validate specific token
if($session->CSRF->hasValidToken()) {
    // Valid
}
```

---

## Session Security

### Database Sessions

More secure than file-based sessions:

```php
// /site/config.php
$config->sessionDB = true;
```

### Session Settings

```php
// /site/config.php

// Session name
$config->sessionName = 'wire';

// Cookie settings
$config->sessionCookieSecure = true;  // HTTPS only
$config->sessionCookieSameSite = 'Lax';  // Or 'Strict'

// Session fingerprinting
$config->sessionFingerprint = true;

// Session expiration (seconds)
$config->sessionExpireSeconds = 86400;  // 24 hours
```

### Login Security

```php
// Check login attempts
$throttle = $modules->get('SessionLoginThrottle');
if(!$throttle->isAllowed($username)) {
    throw new WireException("Too many login attempts");
}

// Secure login
$name = $sanitizer->pageName($input->post->username);
$pass = $input->post->password;

if($session->login($name, $pass)) {
    // Regenerate session ID after login
    $session->regenerateId();
    $session->redirect('/dashboard/');
}
```

---

## Template File Security

### Don't Trust User Input

```php
// WRONG - XSS vulnerability
echo "Hello " . $input->get->name;

// RIGHT - sanitize/encode
echo "Hello " . $sanitizer->entities($input->get->name);
```

### Validate Page Access

```php
// Check if page is viewable
if(!$page->viewable()) {
    throw new Wire404Exception();
}

// Check edit permission
if(!$page->editable()) {
    throw new WirePermissionException("Access denied");
}
```

### Selector Injection Prevention

```php
// WRONG - allows selector injection
$template = $input->get->template;
$pages->find("template=$template");

// RIGHT - sanitize for selector
$template = $sanitizer->selectorValue($input->get->template);
$pages->find("template=$template");

// BETTER - whitelist
$allowed = ['article', 'news', 'blog'];
$template = $input->get->template;
if(!in_array($template, $allowed)) {
    $template = 'article';
}
$pages->find("template=$template");
```

### File Upload Security

```php
// Validate file type
$upload = new WireUpload('myfile');
$upload->setValidExtensions(['pdf', 'doc', 'docx']);
$upload->setMaxFiles(1);
$upload->setOverwrite(false);
$upload->setDestinationPath($config->paths->assets . 'uploads/');

$files = $upload->execute();

if($upload->getErrors()) {
    foreach($upload->getErrors() as $error) {
        echo "<p>Error: $error</p>";
    }
}
```

---

## Production Deployment

### Disable Debug Mode

```php
// /site/config.php
$config->debug = false;
```

### Remove Installation Files

After installation, delete:

- `/install.php`
- `/site/install/` directory

### Protect Sensitive Files

Ensure `.htaccess` blocks access to:

- `/site/config.php`
- `/site/assets/logs/`
- `/site/assets/backups/`

### Recommended .htaccess Additions

```apache
# Block access to sensitive files
<FilesMatch "(^\.ht|config\.php|\.module)">
    Order allow,deny
    Deny from all
</FilesMatch>

# Block access to log files
<Directory "site/assets/logs">
    Order allow,deny
    Deny from all
</Directory>
```

### Database Security

```php
// Use strong, unique database password
// Don't use 'root' user in production
// Limit database user permissions to only what's needed
```

---

## Common Patterns

### Secure Login Form

```php
<?php
$error = '';

if($input->post->login) {
    // Validate CSRF
    if(!$session->CSRF->hasValidToken()) {
        $error = "Invalid request";
    } else {
        $name = $sanitizer->pageName($input->post->username);
        $pass = $input->post->password;

        if($session->login($name, $pass)) {
            $session->regenerateId();
            $session->redirect('/members/');
        } else {
            $error = "Invalid username or password";
        }
    }
}
?>

<form method="post">
    <?=$session->CSRF->renderInput()?>
    <?php if($error): ?>
        <p class="error"><?=htmlspecialchars($error)?></p>
    <?php endif; ?>
    <input type="text" name="username" required>
    <input type="password" name="password" required>
    <button type="submit" name="login" value="1">Login</button>
</form>
```

### Secure Search

```php
$q = $sanitizer->selectorValue($input->get->q);

if(strlen($q) >= 3) {
    $results = $pages->find("title|body~=$q, limit=20");
} else {
    $results = new PageArray();
    if($q) $error = "Search term must be at least 3 characters";
}
```

### Secure AJAX Endpoint

```php
// Check if AJAX
if(!$config->ajax) {
    throw new Wire404Exception();
}

// Validate CSRF for POST
if($input->post->action) {
    if(!$session->CSRF->hasValidToken()) {
        echo json_encode(['error' => 'Invalid token']);
        return;
    }
}

// Sanitize input
$id = $sanitizer->int($input->post->id);
$page = $pages->get($id);

if(!$page->id || !$page->viewable()) {
    echo json_encode(['error' => 'Not found']);
    return;
}

echo json_encode(['title' => $page->title]);
```

---

## Pitfalls / Gotchas

1. **Debug mode in production**: Always set `$config->debug = false` in production.

2. **777 permissions**: Never use in shared hosting. Use most restrictive permissions that work.

3. **Unsanitized selectors**: Always use `$sanitizer->selectorValue()` for user input in selectors.

4. **Missing CSRF tokens**: Always use CSRF tokens in custom forms.

5. **Raw output**: Always encode user-provided data before output with `$sanitizer->entities()`.

6. **Forgot password module**: Only install if needed - email is inherently insecure.

7. **Writable /site/modules/**: In shared hosting, manage modules via FTP instead.

8. **Weak passwords**: Enforce password strength in the "pass" field settings.

9. **HTTP in production**: Always use HTTPS, especially for admin.

10. **File uploads**: Always validate extensions and use secure destination paths.

11. **config.php permissions**: Should not be world-readable in shared hosting.

12. **Session fixation**: Call `$session->regenerateId()` after login.
