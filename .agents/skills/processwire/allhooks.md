# ProcessWire 3.0.257 Hooks Reference

All methods with `___` prefix can be hooked on either before or after execution.

---

## Wire Base Classes

| Class                       | Hooks                                                                                                                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Wire**                    | `___callUnknown`, `___changed`, `___log`, `___trackException`                                                                                                                                  |
| **WireData**                | `___and`                                                                                                                                                                                       |
| **WireArray**               | `___and`, `___callUnknown`                                                                                                                                                                     |
| **WireInputData**           | `___callUnknown`                                                                                                                                                                               |
| **WireInput**               | `___callUnknown`                                                                                                                                                                               |
| **WireCache**               | `___log`                                                                                                                                                                                       |
| **WireLog**                 | `___save`                                                                                                                                                                                      |
| **WireMail**                | `___htmlToText`, `___sanitizeHeaderName`, `___sanitizeHeaderValue`, `___send`                                                                                                                  |
| **WireMailInterface**       | `___send`                                                                                                                                                                                      |
| **WireMailTools**           | `___isBlacklistEmail`, `___new`                                                                                                                                                                |
| **WireHttp**                | `___download`, `___send`, `___sendFile`                                                                                                                                                        |
| **WireShutdown**            | `___fatalError`                                                                                                                                                                                |
| **WireDateTime**            | `___relativeTimeStr`                                                                                                                                                                           |
| **WireFileTools**           | `___include`, `___log`                                                                                                                                                                         |
| **WireTextTools**           | `___wordAlternates`                                                                                                                                                                            |
| **WireAction**              | `___action`, `___executeMultiple`, `___getConfigInputfields`                                                                                                                                   |
| **WireSaveableItems**       | `___added`, `___clone`, `___cloned`, `___cloneReady`, `___delete`, `___deleted`, `___deleteReady`, `___find`, `___load`, `___renamed`, `___renameReady`, `___save`, `___saved`, `___saveReady` |
| **WireSaveableItemsLookup** | `___delete`, `___load`, `___save`                                                                                                                                                              |
| **WireDatabasePDO**         | `___unknownColumnError`                                                                                                                                                                        |
| **Sanitizer**               | `___array`, `___callUnknown`, `___fileName`, `___testAll`                                                                                                                                      |
| **Config**                  | `___callUnknown`                                                                                                                                                                               |
| **Session**                 | `___allowLogin`, `___allowLoginAttempt`, `___authenticate`, `___init`, `___isValidSession`, `___login`, `___loginFailure`, `___loginSuccess`, `___logout`, `___logoutSuccess`, `___redirect`   |
| **ProcessWire**             | `___finished`, `___init`, `___ready`                                                                                                                                                           |
| **Notices**                 | `___render`, `___renderText`                                                                                                                                                                   |

---

## Page Related

| Class                | Hooks                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Page**             | `___added`, `___addedStatus`, `___addReady`, `___addStatusReady`, `___callUnknown`, `___cloned`, `___cloneReady`, `___deleted`, `___deleteReady`, `___edit`, `___editReady`, `___getIcon`, `___getInputfields`, `___getMarkup`, `___getUnknown`, `___if`, `___isPublic`, `___links`, `___loaded`, `___moved`, `___moveReady`, `___path`, `___references`, `___removedStatus`, `___removeStatusReady`, `___renamed`, `___renameReady`, `___render`, `___renderField`, `___renderPage`, `___renderValue`, `___rootParent`, `___saved`, `___saveReady`, `___setEditor`                                                                                                                                                                                                                 |
| **PageArray**        | `___getMarkup`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **Pages**            | `___add`, `___added`, `___addReady`, `___clone`, `___cloned`, `___cloneReady`, `___delete`, `___deleteBranchReady`, `___deleted`, `___deleteReady`, `___emptyTrash`, `___find`, `___found`, `___insertAfter`, `___insertBefore`, `___moved`, `___moveReady`, `___new`, `___published`, `___publishReady`, `___renamed`, `___renameReady`, `___restore`, `___restored`, `___restoreReady`, `___save`, `___saved`, `___savedField`, `___savedPageOrField`, `___saveField`, `___saveFieldReady`, `___saveFields`, `___savePageOrFieldReady`, `___saveReady`, `___setupNew`, `___setupPageName`, `___sort`, `___sorted`, `___statusChanged`, `___statusChangeReady`, `___templateChanged`, `___touch`, `___trash`, `___trashed`, `___trashReady`, `___unpublished`, `___unpublishReady` |
| **PagesType**        | `___add`, `___added`, `___delete`, `___deleted`, `___deleteReady`, `___new`, `___save`, `___saved`, `___saveReady`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| **PagesRequest**     | `___getClosestPage`, `___getLoginPageOrUrl`, `___getPage`, `___getPageForUser`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **PagesAccess**      | `___updatePage`, `___updateTemplate`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| **PageFinder**       | `___find`, `___getQuery`, `___getQueryAllowedTemplatesWhere`, `___getQueryJoinPath`, `___getQueryUnknownField`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **PageFinder2**      | `___find`, `___getQuery`, `___getQueryAllowedTemplatesWhere`, `___getQueryJoinPath`, `___getQueryUnknownField`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **PageAction**       | `___action`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **NullPage**         | `___rootParent`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **PagefilesManager** | `___path`, `___save`, `___url`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **Pagefiles**        | `___clone`, `___delete`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |

---

## User/Roles/Permissions

| Class           | Hooks                                                                                   |
| --------------- | --------------------------------------------------------------------------------------- |
| **User**        | `___changed`, `___hasPagePermission`, `___hasTemplatePermission`, `___setEditor`        |
| **Users**       | `___save`, `___saveReady`                                                               |
| **Roles**       | `___add`, `___delete`, `___deleted`, `___save`                                          |
| **Permissions** | `___add`, `___delete`, `___deleted`, `___getOptionalPermissions`, `___save`, `___saved` |
| **Password**    | `___setPass`                                                                            |

---

## Fieldtypes & Fields

| Class              | Hooks                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Fieldtype**      | `___cloneField`, `___createField`, `___deleteField`, `___deletePageField`, `___deleteTemplateField`, `___emptyPageField`, `___exportConfigData`, `___exportValue`, `___formatValue`, `___getCompatibleFieldtypes`, `___getConfigAdvancedInputfields`, `___getConfigAllowContext`, `___getConfigArray`, `___getConfigInputfields`, `___getFieldSetups`, `___getSelectorInfo`, `___importConfigData`, `___importValue`, `___install`, `___loadPageField`, `___loadPageFieldFilter`, `___markupValue`, `___renamedField`, `___replacePageField`, `___savedField`, `___saveFieldReady`, `___savePageField`, `___sleepValue`, `___uninstall`, `___upgrade`, `___wakeupValue` |
| **FieldtypeMulti** | `___deletePageFieldRows`, `___getCompatibleFieldtypes`, `___getConfigInputfields`, `___getSelectorInfo`, `___loadPageField`, `___savePageField`, `___savePageFieldRows`, `___sleepValue`, `___wakeupValue`                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| **Field**          | `___editable`, `___getConfigInputfields`, `___getInputfield`, `___viewable`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **Fields**         | `___applySetupName`, `___changedType`, `___changeFieldtype`, `___changeTypeReady`, `___clone`, `___delete`, `___deleteFieldDataByTemplate`, `___getTags`, `___save`, `___saveFieldgroupContext`                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **Fieldgroups**    | `___clone`, `___delete`, `___fieldAdded`, `___fieldRemoved`, `___getExportData`, `___load`, `___save`, `___saveContext`, `___setImportData`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |

---

## Inputfields & Form Handling

| Class                 | Hooks                                                                                                                                                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Inputfield**        | `___callUnknown`, `___exportConfigData`, `___getConfigAllowContext`, `___getConfigArray`, `___getConfigInputfields`, `___importConfigData`, `___install`, `___processInput`, `___render`, `___renderReadyHook`, `___renderValue`, `___uninstall` |
| **InputfieldWrapper** | `___allowProcessInput`, `___getConfigInputfields`, `___new`, `___processInput`, `___render`, `___renderInputfield`, `___renderValue`                                                                                                             |

---

## Page Files & Images

| Class                  | Hooks                                                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Pagefile**           | `___changed`, `___filename`, `___httpUrl`, `___install`, `___noCacheURL`, `___url`                                                          |
| **PagefileExtra**      | `___create`, `___noCacheURL`                                                                                                                |
| **Pageimage**          | `___createdVariation`, `___crop`, `___filenameDoesNotExist`, `___install`, `___isVariation`, `___rebuildVariations`, `___render`, `___size` |
| **Pageimages**         | `___render`                                                                                                                                 |
| **ImageSizer**         | `___resize`                                                                                                                                 |
| **ImageSizerEngineGD** | `___imSaveReady`                                                                                                                            |

---

## Templates

| Class            | Hooks                                                                                                       |
| ---------------- | ----------------------------------------------------------------------------------------------------------- |
| **Template**     | `___getConnectedField`                                                                                      |
| **Templates**    | `___clone`, `___delete`, `___fileModified`, `___getExportData`, `___getTags`, `___save`, `___setImportData` |
| **TemplateFile** | `___fileFailed`, `___render`                                                                                |

---

## Modules & Process

| Class                   | Hooks                                                                                                                                                                                                                                                           |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Module**              | `___install`, `___uninstall`, `___upgrade`                                                                                                                                                                                                                      |
| **Modules**             | `___delete`, `___getModuleConfigInputfields`, `___install`, `___isUninstallable`, `___moduleVersionChanged`, `___refresh`, `___saveConfig`, `___saveModuleConfigData`, `___uninstall`                                                                           |
| **ModulePlaceholder**   | `___install`, `___uninstall`                                                                                                                                                                                                                                    |
| **ModuleJS**            | `___install`, `___uninstall`, `___use`                                                                                                                                                                                                                          |
| **FileCompilerModule**  | `___install`, `___uninstall`                                                                                                                                                                                                                                    |
| **FileCompiler**        | `___compile`, `___compileData`                                                                                                                                                                                                                                  |
| **FileValidatorModule** | `___log`                                                                                                                                                                                                                                                        |
| **Process**             | `___breadcrumb`, `___browserTitle`, `___execute`, `___executed`, `___executeNavJSON`, `___executeUnknown`, `___headline`, `___install`, `___installPage`, `___uninstall`, `___uninstallPage`, `___upgrade`                                                      |
| **ProcessController**   | `___execute`                                                                                                                                                                                                                                                    |
| **AdminTheme**          | `___getExtraMarkup`, `___install`, `___uninstall`, `___upgrade`                                                                                                                                                                                                 |
| **AdminThemeFramework** | `___getPrimaryNavArray`, `___getUserNavArray`, `___renderFile`                                                                                                                                                                                                  |
| **Textformatter**       | `___install`, `___uninstall`                                                                                                                                                                                                                                    |
| **Tfa**                 | `___buildAuthCodeForm`, `___getFingerprintArray`, `___getUserEnabledInputfields`, `___getUserSettingsInputfields`, `___install`, `___process`, `___processUserEnabledInputfields`, `___processUserSettingsInputfields`, `___render`, `___start`, `___uninstall` |

---

## Selectors

| Class         | Hooks                       |
| ------------- | --------------------------- |
| **Selectors** | `___getCustomVariableValue` |

---

## Usage Example

```php
// Before hook
$pages->addHookBefore('save', function($event) {
    $page = $event->object;
    // do something before save
});

// After hook
$pages->addHookAfter('saved', function($event) {
    $page = $event->object;
    $changes = $event->arguments(0);
    // do something after save
});
```

---

**Total: 374 hooks in core, 659 in modules (1033 total)**
**Last update: 2026-03-10**
