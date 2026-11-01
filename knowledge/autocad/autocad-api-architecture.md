# AutoCAD .NET API Architecture & Best Practices
<!-- BIM-AI-Foundation | Technical Reference -->

The AutoCAD .NET API allows developers to automate Autodesk AutoCAD, manage DWG databases, create custom entities, and build user interfaces.

---

## 1. Core Architecture: Application, Document & Database

AutoCAD follows a three-tier hierarchy:
```text
Application (Autodesk.AutoCAD.ApplicationServices)
 └── DocumentManager (MdiActiveDocument)
      ├── Editor (User prompts, selection sets, command line messages)
      └── Database (DWG database objects, symbols, dictionaries)
           ├── BlockTable (ModelSpace, PaperSpace, Block Definitions)
           ├── LayerTable (Layers, Colors, Linetypes)
           ├── DimStyleTable / TextStyleTable
           └── Named Object Dictionary (NOD / XRecords)
```

---

## 2. Invariants & Rules

### 2.1 The STA Threading & DocumentLock Rule
AutoCAD is strictly a Single-Threaded Apartment (STA).
* If calling the API from a modal command (`CommandFlags.Modal`), the document is locked by default.
* If calling from a modeless window (WPF palette, dockable dialog, async task, background thread), you **MUST acquire a `DocumentLock`**:
  ```csharp
  Document doc = Application.DocumentManager.MdiActiveDocument;
  using (DocumentLock docLock = doc.LockDocument())
  {
      using (Transaction tr = doc.Database.TransactionManager.StartTransaction())
      {
          // ... modify entities ...
          tr.Commit();
      }
  }
  ```

### 2.2 Object Access: OpenMode.ForRead vs OpenMode.ForWrite
* **Golden Rule:** Open containers (BlockTable, LayerTable) with `OpenMode.ForRead`.
* Only open specific records to be modified or appended with `OpenMode.ForWrite`.
* Never open objects `ForWrite` inside a loop without need—this causes performance degradation and database locks.

### 2.3 Managing Newly Created Entities
* When instantiating an entity (`new Line(...)`), it is in memory only.
* To persist in DWG:
  1. Call `btr.AppendEntity(entity)`.
  2. Call `tr.AddNewlyCreatedDBObject(entity, true)`.
  3. Call `tr.Commit()`.

---

## 3. Version Breaking Changes & .NET Runtimes

| AutoCAD Version | .NET Runtime | Target Framework | Key Considerations |
| :--- | :--- | :--- | :--- |
| **AutoCAD 2024** | .NET Framework 4.8 | `net48` | Legacy runtime. Uses classic DLL loading. |
| **AutoCAD 2025** | **.NET 8.0 (.NET Core)** | `net8.0-windows` | **Major breaking change:** SDK-style `.csproj` required. Coreclr isolation. |
| **AutoCAD 2026** | **.NET 8.0 (.NET Core)** | `net8.0-windows` | Modernized graphics pipeline, web/cloud sync endpoints. |

### Multi-Targeting Project Configuration:
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFrameworks>net8.0-windows;net48</TargetFrameworks>
    <UseWPF>true</UseWPF>
    <Platforms>x64</Platforms>
  </PropertyGroup>

  <ItemGroup Condition="'$(TargetFramework)' == 'net48'">
    <PackageReference Include="AutoCAD.NET" Version="24.3.0" ExcludeAssets="runtime" />
  </ItemGroup>
  <ItemGroup Condition="'$(TargetFramework)' == 'net8.0-windows'">
    <PackageReference Include="AutoCAD.NET" Version="25.0.0" ExcludeAssets="runtime" />
  </ItemGroup>
</Project>
```

---

## 4. High-Performance Selection Sets

To query elements in the drawing efficiently, use `Editor.SelectAll()` or `Editor.SelectCrossingWindow()` with a `SelectionFilter`:

```csharp
Editor ed = doc.Editor;

// Filter for all Circles on the "EQUIPMENT" layer:
TypedValue[] filterValues = new TypedValue[]
{
    new TypedValue((int)DxfCode.Start, "CIRCLE"),
    new TypedValue((int)DxfCode.LayerName, "EQUIPMENT")
};

SelectionFilter filter = new SelectionFilter(filterValues);
PromptSelectionResult selRes = ed.SelectAll(filter);

if (selRes.Status == PromptStatus.OK)
{
    SelectionSet ss = selRes.Value;
    ed.WriteMessage($"\nSelected {ss.Count} equipment circles.");
}
```
