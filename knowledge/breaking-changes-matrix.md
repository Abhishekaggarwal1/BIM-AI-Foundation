# Revit API Breaking Changes & Migration Matrix (2024–2026)
<!-- BIM-AI-Foundation | Technical Reference -->

This matrix documents the critical breaking changes, deprecations, and architectural shifts across Autodesk Revit 2024, 2025, and 2026. Consult this document to prevent obsolete API usage and compile-time failures.

---

## 1. High-Level Comparison Matrix

| Feature / Area | Revit 2024 | Revit 2025 | Revit 2026 | Impact & Solution |
| :--- | :--- | :--- | :--- | :--- |
| **.NET Runtime** | **.NET Framework 4.8** | **.NET 8.0 (.NET Core)** | **.NET 8.0 (.NET Core)** | **High Impact:** Must multi-target `net48` and `net8.0-windows`. Use SDK-style csproj. |
| **Assembly Loading** | AppDomain / Fusion | `AssemblyLoadContext` | `AssemblyLoadContext` | Third-party dependency conflicts handled via isolated load contexts. |
| **`ElementId` Representation** | `long` (`Int64`) | `long` (`Int64`) | `long` (`Int64`) | `ElementId.IntegerValue` is obsolete. Use `ElementId.Value`. |
| **Units & Specs** | `ForgeTypeId` | `ForgeTypeId` | `ForgeTypeId` | `ParameterType`, `DisplayUnitType`, `UnitType` are removed/obsolete. Use `SpecTypeId` & `UnitTypeId`. |
| **Parameter Retrieval** | `LookupParameter()`, `get_Parameter()` | `FindParameter()`, `LookupParameter()` | `FindParameter()`, `LookupParameter()` | In 2025+, prefer `Element.FindParameter(BuiltInParameter)`. |
| **Site Modeling** | `Toposolid` introduced; `TopographySurface` deprecated | `Toposolid` required | `Toposolid` advanced APIs | Use `Toposolid.Create()` or `Toposolid.CreateFromTopographySurface()`. |
| **Context Menus** | Limited / Workarounds | `RegisterContextMenu()` | `RegisterContextMenu()` | Revit 2025+ provides native add-in context menu registration via `UIControlledApplication`. |
| **Dark Theme UI** | Partial support | Full Canvas & UI Theme support | Full Theme support | Use `UIThemeManager` to detect current theme (`CurrentTheme` / `CurrentCanvasTheme`). |

---

## 2. In-Depth Breaking Change Explanations

### 2.1 The .NET 8 Migration (Revit 2025+)
Revit 2025 made the historic shift from the legacy Windows .NET Framework 4.8 to modern cross-platform **.NET 8.0**.

#### Consequences for Add-in Authors:
1. **Old-style `.csproj` files fail completely.** Add-ins must be migrated to modern SDK-style project files (`<Project Sdk="Microsoft.NET.Sdk">`).
2. **WPF and Windows Forms require Windows targeting:**
   ```xml
   <TargetFrameworks>net48;net8.0-windows</TargetFrameworks>
   <UseWPF>true</UseWPF>
   ```
3. **AssemblyLoadContext Behavior:**
   In Revit 2024 (.NET Framework), all add-ins share a single AppDomain. In Revit 2025 (.NET 8), Revit executes inside a default `AssemblyLoadContext`, but add-ins can leverage isolated contexts or `Nice3point.Revit.Toolkit` resolution to avoid package version collisions (e.g., `Newtonsoft.Json`).

---

### 2.2 `ElementId.Value` (Int64 Migration)
In Revit 2024, Autodesk expanded `ElementId` from a 32-bit signed integer to a 64-bit signed integer to support large-scale cloud coordination models.

```csharp
// ❌ WRONG (Obsolete in 2024, causes compilation warnings or overflow errors):
int idInt = element.Id.IntegerValue;
ElementId id = new ElementId(12345);

// ✅ CORRECT (Revit 2024, 2025, 2026):
long idLong = element.Id.Value;
ElementId id = new ElementId(12345L);
```

---

### 2.3 `ForgeTypeId` (Units & Parameter Types)
Old enum types (`ParameterType`, `DisplayUnitType`, `UnitType`) have been completely superseded by extensible `ForgeTypeId` identifiers.

#### Mapping Old Enums to Modern ForgeTypeId:

| Obsolete Enum | Modern Replacement | Code Example |
| :--- | :--- | :--- |
| `ParameterType.Length` | `SpecTypeId.Length` | `definition.GetDataType() == SpecTypeId.Length` |
| `ParameterType.Text` | `SpecTypeId.String.Text` | `definition.GetDataType() == SpecTypeId.String.Text` |
| `ParameterType.Area` | `SpecTypeId.Area` | `definition.GetDataType() == SpecTypeId.Area` |
| `DisplayUnitType.DUT_MILLIMETERS` | `UnitTypeId.Millimeters` | `UnitUtils.ConvertFromInternalUnits(val, UnitTypeId.Millimeters)` |
| `DisplayUnitType.DUT_METERS` | `UnitTypeId.Meters` | `UnitUtils.ConvertFromInternalUnits(val, UnitTypeId.Meters)` |
| `DisplayUnitType.DUT_DECIMAL_FEET` | `UnitTypeId.Feet` | `UnitUtils.ConvertToInternalUnits(val, UnitTypeId.Feet)` |

---

### 2.4 Preprocessor Directives for Multi-Version Codebases

When targeting Revit 2024 through 2026 from a single C# codebase, use conditional compilation:

```csharp
public static Parameter GetMarkParameter(Element element)
{
#if REVIT2025_OR_GREATER
    // Revit 2025 & 2026 native method
    return element.FindParameter(BuiltInParameter.ALL_MODEL_MARK);
#else
    // Revit 2024 fallback
    return element.get_Parameter(BuiltInParameter.ALL_MODEL_MARK);
#endif
}
```
