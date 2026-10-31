# Revit 2025 API Specifics (.NET 8 Migration)
<!-- BIM-AI-Foundation | Version Reference -->

## 1. Runtime Environment (Major Shift)
* **Target Runtime:** **.NET 8.0 (.NET Core)** (`net8.0-windows`)
* **Framework:** All add-ins MUST target `net8.0-windows`. Legacy .NET Framework 4.8 add-ins will fail to load.
* **Assembly Resolution:** Uses `AssemblyLoadContext` instead of legacy AppDomains.

## 2. Key API Changes & Deprecations
* **`Element.FindParameter()`:** Clean overload to look up parameters via `BuiltInParameter` or `ForgeTypeId`:
  ```csharp
  Parameter p = element.FindParameter(BuiltInParameter.ALL_MODEL_MARK);
  ```
* **Context Menus (`RegisterContextMenu`):** Native add-in context menu customization supported via `UIControlledApplication.RegisterContextMenu()`.
* **Dark Theme UI Canvas:** Native support for Dark Theme across Revit canvas and view windows via `UIThemeManager`.
* **TopographySurface Complete Deprecation:** Existing topography models must be converted to `Toposolid`.

## 3. MSBuild Target Definition:
```xml
<PropertyGroup Condition="'$(Configuration)' == 'Release R25'">
  <TargetFramework>net8.0-windows</TargetFramework>
  <DefineConstants>REVIT2025;REVIT2025_OR_GREATER;NET8_0_OR_GREATER</DefineConstants>
</PropertyGroup>
```
