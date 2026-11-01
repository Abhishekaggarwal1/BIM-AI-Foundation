# AGENTS.md — Master AI Instructions for BIM Software Development
<!-- BIM-AI-Foundation | Open-Source Framework for AI-Assisted BIM Engineering -->

> **Version:** 1.0.0  
> **Standard:** Agentic AI Foundation (AAIF) Repository Specification  
> **Target Scope:** Autodesk Revit Add-in Development (C# / .NET) for Revit 2024, 2025, 2026  
> **Multi-AI Compatibility:** Claude Code, Cursor, GitHub Copilot, OpenAI Codex, Antigravity  

---

## 1. Prime Directives (Non-Negotiable Invariants)

When developing or modifying Autodesk Revit software, you MUST adhere to the following architectural laws. Violating any of these invariants causes hard application crashes or data corruption:

### 1.1 The STA Threading Model
* **The Revit API is strictly Single-Threaded Apartment (STA).** You may ONLY call Revit API methods from the main thread inside an active API context (`IExternalCommand.Execute`, `IExternalEventHandler.Execute`, or an application event callback).
* **NEVER call Revit API methods directly from background threads**, `Task.Run()`, async callbacks, timers, or WPF event handlers.
* **To run asynchronous or UI-triggered work:** You MUST use the `ExternalEvent` pattern or `RevitTask` completion source wrapper to dispatch execution back to the Revit main thread. See `skills/revit-external-event/SKILL.md`.

### 1.2 Transactions & Database Integrity
* **Any modification to the Revit database requires an open `Transaction`.** Read-only operations must NOT open a transaction.
* **Always wrap transactions in a `using` statement:**
  ```csharp
  using (var transaction = new Transaction(document, "Action Name"))
  {
      transaction.Start();
      // ... modify model ...
      transaction.Commit();
  }
  ```
* **NEVER display modal UI dialogs inside an active transaction.** Open the transaction only when user inputs have been collected and validated.
* **SubTransactions & TransactionGroups:** Use `SubTransaction` inside family documents or complex routines. Use `TransactionGroup` with `Assimilate()` to present multi-step actions as a single undo item to the user.

### 1.3 Element Identification (Revit 2024+ Int64 Migration)
* **`ElementId.IntegerValue` is DEPRECATED and TRUNCATES.** It will fail on models with large element counts.
* **Always use `ElementId.Value` (returns `long` / `Int64`):**
  ```csharp
  long idValue = element.Id.Value; // Correct (Revit 2024+)
  ```
* When constructing an `ElementId`, use `new ElementId(longValue)`.

### 1.4 Units & Parameter Types (ForgeTypeId Revolution)
* **Enum-based parameter types (`ParameterType`, `DisplayUnitType`, `UnitType`) are OBSOLETE.**
* **Always use `ForgeTypeId`:**
  * For parameter data types: `SpecTypeId.*` (e.g., `SpecTypeId.Length`, `SpecTypeId.Area`, `SpecTypeId.String.Text`).
  * For units: `UnitTypeId.*` (e.g., `UnitTypeId.Meters`, `UnitTypeId.Feet`, `UnitTypeId.Millimeters`).
* For conversions, use `UnitUtils.ConvertFromInternalUnits(val, unitTypeId)` and `UnitUtils.ConvertToInternalUnits(val, unitTypeId)`.
* **Internal Units Invariant:** Revit ALWAYS stores lengths internally in decimal feet, angles in radians, and areas in square feet.

### 1.5 FilteredElementCollector Best Practices
* **Quick Filters First:** Always apply `OfClass()` and `OfCategory()` before applying slow filters or memory-heavy evaluations.
* **DO NOT invoke LINQ `Where()` prematurely:**
  * Bad: `collector.Where(e => e.Name == "Wall1").First()` (instantiates all C# wrappers).
  * Good: `collector.OfClass(typeof(Wall)).WherePasses(new ElementParameterFilter(...))` or filter by `ElementMulticlassFilter`.
* **Always use `WhereElementIsNotElementType()`** when querying model instances, or `WhereElementIsElementType()` when querying types/symbols.

### 1.6 Revit Dynamo Scripting Invariants
* **Transactions in Dynamo:** NEVER use raw `new Transaction(doc)`. ALWAYS use `TransactionManager.Instance.EnsureInTransaction(doc)` and `TransactionManager.Instance.TransactionTaskDone()`.
* **Element Wrapping:** Dynamo wraps native Revit elements. Always use `UnwrapElement(IN[x])` before calling Revit DB methods, and `element.ToDSType(true)` when passing back to Dynamo nodes.
* **Geometry Conversion:** Use `ToProtoType()` to convert Revit curves/points to Dynamo, and `ToRevitType()` / `ToXyz()` to convert Dynamo geometry to Revit.

### 1.7 AutoCAD API & Invariants (C# & AutoLISP)
* **STA & DocumentLock:** AutoCAD is strictly Single-Threaded Apartment. Modifying the active database from a modeless palette, dockable dialog, or async task REQUIRES `using (DocumentLock docLock = doc.LockDocument())`.
* **Database Transactions:** Every entity belongs to a `BlockTableRecord` (e.g. `ModelSpace`). Always open tables with `OpenMode.ForRead`, open target records `OpenMode.ForWrite`, call `btr.AppendEntity(entity)`, `tr.AddNewlyCreatedDBObject(entity, true)`, and `tr.Commit()`.
* **AutoCAD 2025/2026 .NET 8 Migration:** Like Revit 2025, AutoCAD 2025+ runs on **.NET 8.0 Core** (`net8.0-windows`). AutoCAD 2024 uses .NET 4.8 (`net48`).

---

## 2. Version-Specific Constraints (2024 vs 2025 vs 2026)

| Software & Version | .NET Runtime | Target Framework | Key API Changes & Gotchas |
| :--- | :--- | :--- | :--- |
| **Revit 2024** | .NET Framework 4.8 | `net48` | `ElementId.Value` (`long`), Toposolid introduced (`Toposolid.Create`). |
| **Revit 2025** | **.NET 8.0 (.NET Core)** | `net8.0-windows` | **Major breaking change:** SDK-style csproj required. Uses `AssemblyLoadContext` for plugins. New `Element.FindParameter()`, `RegisterContextMenu` API. |
| **Revit 2026** | **.NET 8.0 (.NET Core)** | `net8.0-windows` | Advanced Toposolid APIs, modern cloud collaboration endpoints. |
| **AutoCAD 2024** | .NET Framework 4.8 | `net48` | Classic .NET Framework runtime, `acdbmgd.dll`, `acmgd.dll`. |
| **AutoCAD 2025/2026**| **.NET 8.0 (.NET Core)** | `net8.0-windows` | **Major breaking change:** Migrated to .NET 8. Coreclr isolation. |

### Conditional Compilation Preprocessor Symbols
When authoring code that targets multiple Revit versions, use the standard preprocessor flags provided by `Nice3point.Revit.Build.Tasks`:
```csharp
#if REVIT2025_OR_GREATER
    // .NET 8 / Revit 2025+ specific API
    Parameter param = element.FindParameter(BuiltInParameter.ALL_MODEL_MARK);
#else
    // Legacy Revit 2024 / .NET 4.8 fallback
    Parameter param = element.get_Parameter(BuiltInParameter.ALL_MODEL_MARK);
#endif
```

---

## 3. Architecture & Project Conventions

1. **Solution Structure:** Follow Clean Architecture:
   * `Domain`: Pure business logic, calculations, geometry representations (no Revit/AutoCAD API references).
   * `Application`: Commands, ViewModels, business services.
   * `Infrastructure`: Revit / AutoCAD API implementations (`IExternalCommand`, `IExtensionApplication`, `[CommandMethod]`, queries).
   * `UI`: WPF Views with `CommunityToolkit.Mvvm`.
2. **Commands:**
   * Every Revit command must declare:
     ```csharp
     [Transaction(TransactionMode.Manual)]
     [Regeneration(RegenerationOption.Manual)]
     public class MyCommand : IExternalCommand
     ```
   * Commands must return `Result.Succeeded`, `Result.Failed`, or `Result.Cancelled`.
   * Never let uncaught exceptions escape. Wrap the body in a try-catch and log or display a user-friendly error.
3. **WPF in Revit & AutoCAD:**
   * Set `Window.Owner` to host window handle using `WindowInteropHelper` to maintain modal ownership.
   * Use dark/light theme aware styles.

---

## 4. Intelligent Skill & Knowledge Retrieval (Progressive Disclosure)

Do NOT guess or hallucinate API signatures. Read the specialized skill or knowledge reference file matching your task:

### Task-to-Skill Router
* **Scaffolding a new Revit plugin or solution (C#):** Read [`skills/revit-plugin-scaffold/SKILL.md`](skills/revit-plugin-scaffold/SKILL.md)
* **pyRevit extensions & Python ribbon buttons:** Read [`skills/revit-pyrevit-extension/SKILL.md`](skills/revit-pyrevit-extension/SKILL.md)
* **Revit Dynamo Python nodes & Zero-Touch C# nodes:** Read [`skills/revit-dynamo-script/SKILL.md`](skills/revit-dynamo-script/SKILL.md)
* **AutoCAD .NET plugins (C#) & AutoLISP scripts:** Read [`skills/autocad-plugin-scaffold/SKILL.md`](skills/autocad-plugin-scaffold/SKILL.md)
* **Civil 3D infrastructure (.NET & Alignments/Surfaces):** Read [`skills/civil3d-plugin-scaffold/SKILL.md`](skills/civil3d-plugin-scaffold/SKILL.md)
* **Navisworks plugins, Clash Detective & Search Sets:** Read [`skills/navisworks-plugin-scaffold/SKILL.md`](skills/navisworks-plugin-scaffold/SKILL.md)
* **OpenBIM & IFC processing (IfcOpenShell & Xbim):** Read [`skills/openbim-ifc-processing/SKILL.md`](skills/openbim-ifc-processing/SKILL.md)
* **Rhino.Inside.Revit & Grasshopper integration:** Read [`skills/rhino-inside-revit/SKILL.md`](skills/rhino-inside-revit/SKILL.md)
* **Automated Unit Testing (xUnitRevit / TestRunner):** Read [`skills/revit-unit-testing/SKILL.md`](skills/revit-unit-testing/SKILL.md)
* **BIM Collaboration Format (BCF issues & viewpoints):** Read [`skills/bim-bcf-manager/SKILL.md`](skills/bim-bcf-manager/SKILL.md)
* **Revit Family (.rfa) document & parameter automation:** Read [`skills/revit-family-automator/SKILL.md`](skills/revit-family-automator/SKILL.md)
* **APS (Forge) Design Automation for headless Revit:** Read [`skills/aps-design-automation/SKILL.md`](skills/aps-design-automation/SKILL.md)
* **Background tasks, async operations, or WPF dispatch:** Read [`skills/revit-external-event/SKILL.md`](skills/revit-external-event/SKILL.md)
* **Reading, writing, or creating parameters & units:** Read [`skills/revit-parameter-manager/SKILL.md`](skills/revit-parameter-manager/SKILL.md)
* **High-performance element filtering & selection:** Read [`skills/revit-element-collector/SKILL.md`](skills/revit-element-collector/SKILL.md)
* **Solid booleans, intersections, or ray casting:** Read [`skills/revit-geometry-analysis/SKILL.md`](skills/revit-geometry-analysis/SKILL.md)
* **Suppressing warning popups or handling failures:** Read [`skills/revit-failure-handler/SKILL.md`](skills/revit-failure-handler/SKILL.md)
* **Model audits, QA/QC checks, and validation rules:** Read [`skills/revit-model-validation/SKILL.md`](skills/revit-model-validation/SKILL.md)
* **Dockable panels, palettes, and WPF MVVM UI:** Read [`skills/revit-dockable-panel/SKILL.md`](skills/revit-dockable-panel/SKILL.md)

### Technical Knowledge Deep Dives
* **Version breaking changes matrix:** [`knowledge/breaking-changes-matrix.md`](knowledge/breaking-changes-matrix.md)
* **Revit threading and async architecture:** [`knowledge/revit-api/threading-and-async.md`](knowledge/revit-api/threading-and-async.md)
* **Transactions and failure preprocessors:** [`knowledge/revit-api/transactions-and-failures.md`](knowledge/revit-api/transactions-and-failures.md)
* **pyRevit architecture & Python patterns:** [`knowledge/revit-api/pyrevit-patterns.md`](knowledge/revit-api/pyrevit-patterns.md)
* **Dynamo architecture & Python scripting patterns:** [`knowledge/revit-api/dynamo-python-patterns.md`](knowledge/revit-api/dynamo-python-patterns.md)
* **AutoCAD .NET API architecture & patterns:** [`knowledge/autocad/autocad-api-architecture.md`](knowledge/autocad/autocad-api-architecture.md)
* **Civil 3D API architecture & patterns:** [`knowledge/civil3d/civil3d-api-architecture.md`](knowledge/civil3d/civil3d-api-architecture.md)
* **Navisworks API architecture & clash automation:** [`knowledge/navisworks/navisworks-api-architecture.md`](knowledge/navisworks/navisworks-api-architecture.md)
* **OpenBIM IFC architecture & standards:** [`knowledge/openbim/openbim-ifc-patterns.md`](knowledge/openbim/openbim-ifc-patterns.md)
* **Rhino.Inside.Revit computational architecture:** [`knowledge/computational-design/rhino-inside-revit.md`](knowledge/computational-design/rhino-inside-revit.md)
* **Full Semantic Knowledge Index:** [`knowledge/INDEX.md`](knowledge/INDEX.md)

---

## 5. Development & Build Commands

When executing CLI commands inside a plugin repository created with this framework:
* **Build entire solution:** `dotnet build`
* **Build specific Revit version:**
  * Revit 2024: `dotnet build -f net48 -c "Release R24"`
  * Revit 2025: `dotnet build -f net8.0-windows -c "Release R25"`
  * Revit 2026: `dotnet build -f net8.0-windows -c "Release R26"`
* **Build AutoCAD Add-in:**
  * AutoCAD 2024: `dotnet build -f net48`
  * AutoCAD 2025/2026: `dotnet build -f net8.0-windows`
* **Run Unit/Integration tests:** `dotnet test`
* **Scaffold new add-in via CLI:**
  * C# Revit Plugin: `pwsh ./cli/bim-ai.ps1 new -Name MyAddin -Type csharp`
  * pyRevit Extension: `pwsh ./cli/bim-ai.ps1 new -Name MyTools -Type pyrevit`
  * AutoCAD Plugin: `pwsh ./cli/bim-ai.ps1 new -Name MyAcadPlugin -Type autocad`
  * Dynamo Scripts: `pwsh ./cli/bim-ai.ps1 new -Name MyDynamoScripts -Type dynamo`

