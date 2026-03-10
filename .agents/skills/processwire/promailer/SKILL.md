---
name: promailer
description: ProMailer is a ProcessWire Pro module for managing email newsletters, subscribers, and distributions.
---

# ProMailer Development

You are an expert in ProMailer, a ProcessWire Pro module for managing email newsletters, subscribers, and mailings.

## Core Concepts

- ProMailer handles subscriber lists, subscription forms, and email message distributions
- Requires ProcessWire 3.0.123 or newer
- Module files go in /site/modules/ProMailer/
- Template files should be copied to /site/templates/

## Key Files and Locations

### Module Files
- `/site/modules/ProMailer/` - Module installation directory
- `/site/modules/ProMailer/promailer-subscribe.php` - Subscribe/unsubscribe template
- `/site/modules/ProMailer/promailer-email.php` - Email template example
- `/site/modules/ProMailer/promailer-webhooks.inc` - Webhooks handler (copy to /site/templates/)

### Template Files (copy to /site/templates/)
- `/site/templates/promailer-subscribe.php` - Subscribe/unsubscribe page
- `/site/templates/promailer-email.php` - Email message template
- `/site/templates/promailer-webhooks.inc` - Webhook processing

## Subscriber Lists

### List Types
1. **ProMailer-managed lists** - Manually managed email addresses
2. **Users/pages lists** - Dynamic lists matching ProcessWire users or pages

### Creating a List
1. Go to Setup > ProMailer > Subscriber Lists > Add New
2. Select list type (managed vs users/pages)
3. Configure list settings including status (open/closed)

## Custom Fields

### Definition Format
```
name:type
```

### Common Sanitizers
- `text` - Single line text (255 chars)
- `textarea` - Multi-line text
- `email` - Email address
- `int` - Integer
- `option` - Single select dropdown
- `options` - Multiple checkboxes
- `bool` - Boolean checkbox

### Required Fields
Prepend asterisk to field name: `*first_name:text`

### Example
```
*first_name:text
last_name:text
age:int
gender:option[Male|Female|Other]
```

## Email Template Placeholders

### Built-in Placeholders
- `{email}` - Recipient email address
- `{from_email}` - Sender email
- `{from_name}` - Sender name
- `{subject}` - Email subject
- `{title}` - Message title
- `{unsubscribe_url}` - Unsubscribe URL
- `{subscribe_url}` - Subscribe URL

### Custom Field Placeholders
Use `{field_name}` syntax for any custom fields

### Conditional Placeholders
```php
{if:first_name}
  Hello {first_name},
{else}
  Hello friend,
{endif}
```

## Subscription Form

### Include from Other Templates
```php
include('./promailer-subscribe.php');
```

### Pre-subscription Form (GET method)
```xml
<form method='get' action='/promailer/'>
  <label for='email'>Email address</label>
  <input type='email' id='email' name='email'>
  <button type='submit'>Subscribe</button>
</form>
```

### Subscribe Form Placeholders
- `{url}` - Form action URL
- `{email_name}` - Email input field name
- `{email_placeholder}` - Email placeholder text
- `{submit_name}` - Submit button name
- `{submit_label}` - Submit button label
- `{list}` - List title
- `{honeypot}` - Spam prevention honeypot
- `{extras}` - Hidden inputs required by ProMailer

## Email Sending Methods

### Live Sending
- Browser window must remain open
- Updates in real-time
- Stops when navigating away

### Background Sending
- Continues after browser closes
- Triggered by web traffic
- Uses configured throttle and quantity

## External Email Services

### Supported WireMail Modules
- WireMailMailgun
- WireMailSMTP
- SwiftMailer
- PHPMailer
- WireMailMandrill

### Configuration
1. Install desired WireMail module
2. Configure module with API credentials
3. Module becomes available in ProMailer delivery options

## Webhooks

### Setup
1. Copy `/site/modules/ProMailer/promailer-webhooks.inc` to `/site/templates/`
2. Configure webhook URL with email provider
3. Endpoint: `https://domain.com/promailer/?webhook=provider`

### Common Use Cases
- Bounce detection
- Spam complaint tracking
- Email open/click tracking

## Multi-language Support

1. Go to Setup > Languages > [language]
2. Click "Add files to translate"
3. Add `/site/templates/promailer-subscribe.php`
4. Translate all text strings

## Best Practices

### Email Development
- Use absolute URLs (https://domain.com/) not relative
- Use email HTML frameworks (Foundation for Emails, MJML, Maizzle)
- Test across email clients (especially Outlook)

### List Management
- Use double opt-in for subscriptions
- Regularly clean bounced addresses
- Use separate test lists for sending tests

### Template Organization
- Keep email templates in /site/templates/
- Use separate HTML and text versions
- Test send to small list before large campaigns
