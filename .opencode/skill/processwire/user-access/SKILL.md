---
name: processwire-user-access
description: Role-based access control, permissions, template access control, user management, and checking user permissions via API
compatibility: opencode
metadata:
  domain: processwire
  scope: user-access
---

## What I Do

I provide comprehensive guidance for ProcessWire access control:

- Role-based access control (RBAC) system
- Creating and managing roles
- Permission types and usage
- Template access control
- Checking permissions via API
- User management
- Multi-language editing permissions

## When to Use Me

Use this skill when:

- Setting up user roles and permissions
- Implementing template access control
- Checking user permissions in templates
- Creating custom permissions
- Limiting page editing to specific users
- Setting up multi-language translator roles

---

## Access Control Overview

ProcessWire uses Role-Based Access Control (RBAC):

1. **Users** are assigned to one or more **Roles**
2. **Roles** are assigned **Permissions**
3. **Roles** are assigned to **Templates** for page access control

```
User → Roles → Permissions
          ↓
      Templates → Page Access
```

---

## Roles

### Default Roles

| Role        | Description                                         |
| ----------- | --------------------------------------------------- |
| `guest`     | All anonymous users. Only assign page-view.         |
| `superuser` | Full access to everything. Most trusted users only. |

### Creating Custom Roles

1. Go to Access > Roles > Add New
2. Enter role name
3. Assign permissions
4. Save

### Checking User Roles

```php
// Check if user has a role
if($user->hasRole('editor')) {
    echo $page->editor_notes;
}

// Check multiple roles
if($user->hasRole('editor') || $user->hasRole('manager')) {
    // Show admin content
}

// Get all user roles
foreach($user->roles as $role) {
    echo $role->name;
}
```

### Role Assignment via API

```php
// Add role to user
$user->addRole('editor');
$user->save();

// Remove role from user
$user->removeRole('editor');
$user->save();

// Set roles (replaces all)
$user->roles->removeAll();
$user->addRole('guest');
$user->addRole('member');
$user->save();
```

---

## Permissions

### Default Core Permissions

| Permission      | Description                                              |
| --------------- | -------------------------------------------------------- |
| `page-view`     | View pages (required for all roles)                      |
| `page-edit`     | Pre-requisite for any editing access                     |
| `page-add`      | Add child pages (runtime, template context)              |
| `page-create`   | Create pages of certain type (runtime, template context) |
| `page-delete`   | Delete/trash pages                                       |
| `page-move`     | Change page parent                                       |
| `page-sort`     | Reorder child pages                                      |
| `page-template` | Change page template                                     |
| `page-lock`     | Lock/unlock pages                                        |
| `page-lister`   | Access Page Lister (Find)                                |
| `profile-edit`  | Edit own profile                                         |

### Optional Core Permissions

Install from Access > Permissions > Add New:

| Permission                | Description                                            |
| ------------------------- | ------------------------------------------------------ |
| `page-clone`              | Clone pages (requires ProcessPageClone module)         |
| `page-clone-tree`         | Clone entire page tree                                 |
| `page-edit-created`       | Only edit pages user created                           |
| `page-edit-images`        | Use image editor                                       |
| `page-edit-trash-created` | Trash pages user created                               |
| `page-hide`               | Hide/unhide pages                                      |
| `page-publish`            | Publish content (without: can only create unpublished) |
| `page-rename`             | Rename published pages                                 |
| `page-edit-front`         | Front-end editing (requires PageFrontEdit)             |

### User Admin Permissions

| Permission          | Description                              |
| ------------------- | ---------------------------------------- |
| `user-admin`        | Administer all users (except superusers) |
| `user-admin-all`    | Full user administration                 |
| `user-admin-[role]` | Administer users with specific role      |

### Checking Permissions

```php
// Check if user has permission
if($user->hasPermission('page-edit')) {
    // User can edit pages (somewhere)
}

// Check permission in page context
if($user->hasPermission('page-edit', $page)) {
    // User can edit THIS specific page
}

// Check if user can view page
if($page->viewable()) {
    echo $page->body;
}

// Check if user can edit page
if($page->editable()) {
    echo "<a href='$page->editUrl'>Edit</a>";
}

// Other page access checks
$page->addable();      // Can add children?
$page->publishable();  // Can publish?
$page->deleteable();   // Can delete?
$page->moveable();     // Can move?
$page->sortable();     // Can sort children?
```

### Creating Custom Permissions

**Via Admin:**

1. Go to Access > Permissions > Add New
2. Enter permission name (e.g., `my-custom-permission`)
3. Enter description in title field
4. Save

**Via API:**

```php
$permission = $permissions->add('my-custom-permission');
$permission->title = 'Description of what this permission does';
$permission->save();
```

**Using custom permission:**

```php
if($user->hasPermission('my-custom-permission')) {
    // User has this permission
}
```

---

## Template Access Control

### Enabling Access Control

1. Go to Setup > Templates > [template] > Access tab
2. Check "Define access for this template"
3. Assign roles for view, edit, create, add

### Access Types

| Type       | Description                                             |
| ---------- | ------------------------------------------------------- |
| **View**   | Who can view pages using this template                  |
| **Edit**   | Who can edit pages using this template                  |
| **Create** | Who can create new pages using this template            |
| **Add**    | Who can add child pages under pages using this template |

### Inheritance

When access control is NOT enabled for a template:

- Pages inherit access from closest parent with access control enabled

### Checking Template Access

```php
// Check if current user can view pages with template
$template = $templates->get('article');
if($user->hasTemplatePermission('page-view', $template)) {
    // User can view articles
}

// Check edit access
if($user->hasTemplatePermission('page-edit', $template)) {
    // User can edit articles
}
```

---

## Users

### The User Object

Users are Page objects with template "user":

```php
// Current user
$user = wire('user');
echo $user->name;
echo $user->email;

// Check if logged in
if($user->isLoggedin()) {
    echo "Welcome, {$user->name}";
}

// Check if guest
if($user->isGuest()) {
    echo "Please log in";
}

// Check if superuser
if($user->isSuperuser()) {
    echo "You have full access";
}
```

### Finding Users

```php
// Get specific user
$admin = $users->get('admin');
$userById = $users->get(41);

// Find users
$editors = $users->find("roles=editor");
$activeUsers = $users->find("login_count>0");

// All users with a role
$admins = $users->find("roles=superuser");
```

### Creating Users

```php
$u = new User();
$u->name = 'johndoe';
$u->pass = 'secretpassword';
$u->email = 'john@example.com';
$u->addRole('member');
$u->save();
```

### Modifying Users

```php
$u = $users->get('johndoe');
$u->of(false);  // Turn off output formatting
$u->email = 'newemail@example.com';
$u->save();
```

### Login/Logout

```php
// Login
$name = $sanitizer->pageName($input->post->user);
$pass = $input->post->pass;

if($session->login($name, $pass)) {
    // Login successful
    $session->redirect('/members/');
} else {
    // Login failed
    echo "Invalid login";
}

// Logout
$session->logout();
$session->redirect('/');

// Force login (bypass password)
$session->forceLogin($user);
```

---

## Common Patterns

### Login Form

```php
if($input->post->login) {
    $name = $sanitizer->pageName($input->post->username);
    $pass = $input->post->password;

    if($session->login($name, $pass)) {
        $session->redirect('/dashboard/');
    } else {
        $error = "Invalid username or password";
    }
}
?>

<form method="post">
    <?php if(isset($error)) echo "<p class='error'>$error</p>"; ?>
    <input type="text" name="username" placeholder="Username">
    <input type="password" name="password" placeholder="Password">
    <button type="submit" name="login" value="1">Login</button>
</form>
```

### Protected Page

```php
// Require login
if($user->isGuest()) {
    $session->redirect('/login/?ret=' . urlencode($page->url));
}

// Require specific role
if(!$user->hasRole('member')) {
    throw new Wire404Exception();
}

// Require specific permission
if(!$user->hasPermission('view-reports', $page)) {
    echo "<p>Access denied</p>";
    return;
}
```

### Show Content Based on Role

```php
<h1><?=$page->title?></h1>
<?=$page->body?>

<?php if($user->hasRole('editor')): ?>
    <div class="editor-notes">
        <h3>Editor Notes</h3>
        <?=$page->editor_notes?>
    </div>
<?php endif; ?>

<?php if($page->editable()): ?>
    <a href="<?=$page->editUrl?>">Edit this page</a>
<?php endif; ?>
```

### Admin-Only Content

```php
if($user->isSuperuser()) {
    echo "<div class='debug'>Page ID: {$page->id}</div>";
}
```

### Limit Editing to Page Creator

Install `page-edit-created` permission and assign to role:

```php
// API check
if($page->createdUser->id == $user->id) {
    // Current user created this page
}
```

---

## Multi-Language Permissions

For translator-specific roles:

| Permission               | Description                    |
| ------------------------ | ------------------------------ |
| `page-edit-lang-default` | Edit default language fields   |
| `page-edit-lang-[name]`  | Edit specific language fields  |
| `page-edit-lang-none`    | Edit non-multi-language fields |
| `lang-edit`              | Access language tools in Setup |

### Translator Role Setup

1. Create role "translator-spanish"
2. Assign permissions:
   - `page-edit`
   - `page-edit-lang-spanish` (create this permission)
3. Assign role to templates user should translate
4. Assign role to user

---

## Access Control in Selectors

```php
// By default, find() respects access control
$pages->find("template=article");  // Only viewable pages

// Include hidden pages
$pages->find("template=article, include=hidden");

// Include unpublished
$pages->find("template=article, include=unpublished");

// Include all (hidden, unpublished, trash)
$pages->find("template=article, include=all");

// Disable access checks entirely
$pages->find("template=article, check_access=0");
```

---

## Pitfalls / Gotchas

1. **page-edit is prerequisite**: Most editing permissions require `page-edit` first.

2. **Template context required**: `page-edit` alone doesn't grant edit access - the role must also be assigned to the template.

3. **Guest role special**: All users have `guest` role permissions. Don't give `guest` more than `page-view`.

4. **Superuser bypasses all**: Superusers have all permissions regardless of what's assigned.

5. **Runtime permissions**: `page-add` and `page-create` are runtime-only - don't create them manually.

6. **Access inheritance**: Pages inherit access from parent when template access control is not enabled.

7. **check_access in selectors**: Use `check_access=0` carefully - it bypasses security.

8. **User passwords**: Always use `$user->pass = $value` - never access password directly.

9. **Login security**: Use `$sanitizer->pageName()` on username input.

10. **Session hijacking**: Enable HTTPS and secure session settings in production.
