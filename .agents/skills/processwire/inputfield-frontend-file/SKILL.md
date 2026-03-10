---
name: processwire-inputfield-frontend-file
description: InputfieldFrontendFile module for ProcessWire - front-end file and image uploads for user profiles with drag-drop, thumbnails, and validation
compatibility: opencode
metadata:
  domain: processwire
  scope: file-upload
---

## What I Do

I provide comprehensive guidance for InputfieldFrontendFile - a front-end file and image upload module for ProcessWire:

- Drag and drop Ajax image upload
- Thumbnails for uploaded files/images
- Drag-sorting of files
- File details and description editing
- Client-side image resizing
- Upload progress indicator
- Temp files until submit
- Drop-in replacement for InputfieldFile/InputfieldImage

## When to Use Me

Use this skill when:

- Setting up front-end file uploads
- Configuring user profile image fields
- Implementing drag-and-drop uploads
- Validating uploaded files
- Managing file descriptions
- Configuring upload size limits
- Setting up admin notifications

---

## Requirements

### Prerequisites

- LoginRegisterPro v3+ installed
- ProcessWire 3.0.148+
- FileValidatorImage module (for image uploads)
- jQuery (loaded automatically by LoginRegisterPro)
- jQuery UI (Draggable, Droppable, Sortable - loaded automatically)

### Installation

1. Download InputfieldFrontendFile from LoginRegisterPro support board
2. Place in `/site/modules/InputfieldFrontendFile/`
3. Modules > Refresh > Install

---

## Configuration

### Field Setup

1. Create or use existing File/Image field in ProcessWire
2. Add field to User template
3. Enable field in User Profile
4. Add field to LoginRegisterPro Profile form

### File Field Settings

```php
// In Setup > Fields > [File field]

// Details tab
// - Specify allowed file extensions
// - Maximum files allowed: 1+ (NOT 0 - avoid "unlimited")
// - Text formatters: "HTML Entity Encoder" recommended

// Input tab
// - Number of rows for description field:
//   0 = disabled
//   1 = single-row
//   2+ = multi-row
```

### Image Field Settings

```php
// In Setup > Fields > [Image field]

// Supports:
// - Default image grid mode (square/proportional)
// - Maximum image dimensions (width/height)
// - Minimum image dimensions (width/height) - RECOMMENDED
// - Client-side resize (automatic)
```

### Ignored Settings

The following are intentionally ignored by InputfieldFrontendFile:

- Decompress zip files
- Overwrite existing files
- Focus point selection
- How to resize to max dimensions
- Max megapixels
- Client-side resize quality for JPEG

---

## Usage in Templates

### Basic Usage

InputfieldFrontendFile works automatically with LoginRegisterPro. When a File/Image field is added to the Profile form, it renders automatically.

```php
<?= $modules->get('LoginRegisterPro')->execute('profile') ?>
```

### Rendering Separately

```php
<?php
$form = $modules->get('LoginRegisterPro')->execute('profile');
echo $form;
?>
```

---

## API Reference

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `$field->maxFiles` | int | Maximum files allowed |
| `$field->descriptionRows` | int | Rows for description field |
| `$field->extensions` | string | Allowed file extensions |

### Getting Uploaded Files

```php
// Get user's uploaded files
$user = $wire->user;
$files = $user->get('my_field_name');

// Iterate through files
foreach($files as $file) {
    echo $file->url;
    echo $file->description;
    echo $file->width;      // for images
    echo $file->height;     // for images
    echo $file->basename;
    echo $file->filesize;
}
```

---

## Security Considerations

### Important Warnings

> **Front-end file uploads carry inherent risks.** This module adds safety measures but cannot verify:
> - Whether uploaded content is appropriate for your audience
> - Whether files contain malicious code
> - Legal compliance of uploaded content

### Recommended Best Practices

1. **Always set limits** - Never use "unlimited" (0) for max files
2. **Restrict extensions** - Only allow necessary file types
3. **Set size limits** - Configure max upload size in LoginRegisterPro
4. **Monitor uploads** - Enable admin notification emails
5. **Validate images** - Install FileValidatorImage module
6. **Set minimum dimensions** - For image fields, require minimum width/height
7. **Review uploads** - Regularly check uploaded files
8. **Maintain backups** - Regular database and file system backups

---

## Configuration in LoginRegisterPro

### Max File Size

In LoginRegisterPro module settings:

```
Profile section > Profile form fields
> Max allowed file size for file upload fields
```

Example: `5M` for 5 megabytes

### Admin Notifications

```
Confirm fieldset > Admin notification email
```

Receives notifications for:
- New user registrations
- New file uploads (when InputfieldFrontendFile is installed)

---

## Frontend Features

### Drag and Drop

Users can drag files directly onto the upload area for Ajax upload.

### Sorting

Images can be dragged to reorder. Uses jQuery UI Sortable.

### Thumbnails

- Image thumbnails shown in grid
- Click to view full size
- Shows filename, dimensions, file size

### File Descriptions

If enabled, users can add/edit descriptions for uploaded files.

### Progress Indicator

Shows upload progress during file transfer.

### Client-Side Resize

Images are resized client-side before upload if they exceed max dimensions.

---

## Troubleshooting

### Field Not Appearing

1. Ensure InputfieldFrontendFile module is installed
2. Verify field is added to User template
3. Check "show in User Profile" is enabled
4. Confirm field is added to LoginRegisterPro Profile form

### Uploads Failing

1. Check PHP upload_max_filesize setting
2. Verify max file size in LoginRegisterPro config
3. Ensure allowed extensions match file type
4. Check for minimum dimension requirements

### Images Not Resizing

1. Verify client supports JavaScript
2. Check max dimensions are set in field config
3. Ensure FileValidatorImage is installed for validation

### Validation Errors

1. File extension not allowed
2. File exceeds max size
3. Image dimensions too small/large
4. Corrupt or invalid file format

---

## Related Modules

- **LoginRegisterPro** - Parent module, handles form rendering
- **FileValidatorImage** - Validates uploaded images for authenticity
- **FileValidator** - Base validation module

---

## Example: Complete Profile with Avatar

```php
<?php
// In your profile template
$lr = $modules->get('LoginRegisterPro');

// Add custom avatar field to profile
// 1. Create Image field "avatar" 
// 2. Add to User template
// 3. Enable in User Profile
// 4. Add to LoginRegisterPro Profile form
// 5. Configure: max files=1, min dimensions=100x100

echo $lr->execute('profile');

// Display current avatar
if($user->avatar) {
    echo "<img src='{$user->avatar->url}' alt='Profile Photo'>";
}
?>
```

---

## Integration with LoginRegisterPro Hooks

```php
// After profile save - notify admin of new uploads
$wire->addHookAfter('LoginRegisterPro::profileSuccess', function(HookEvent $e) {
    $user = $e->arguments(0);
    
    // Check for file field changes
    if($user->isChanged('profile_files')) {
        // New files uploaded
        $files = $user->profile_files;
        foreach($files as $file) {
            // Log or notify
        }
    }
});
```
