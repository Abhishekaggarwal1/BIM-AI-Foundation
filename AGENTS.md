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

---

## 2. Version-Specific Constraints (2024 vs 2025 vs 2026)

| Revit Version | .NET Runtime | Target Framework | Key API Changes & Gotchas |
| :--- | :--- | :--- | :--- |
| **Revit 2024** | .NET Framework 4.8 | `net48` | `ElementId.Value` (`long`), Toposolid introduced (`Toposolid.Create`). |
| **Revit 2025** | **.NET 8.0 (.NET Core)** | `net8.0-windows` | **Major breaking change:** SDK-style csproj required. Uses `AssemblyLoadContext` for plugins. New `Element.FindParameter()`, `RegisterContextMenu` API. |
| **Revit 2026** | **.NET 8.0 (.NET Core)** | `net8.0-windows` | Advanced Toposolid APIs, modern cloud collaboration endpoints. |

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
   * `Domain`: Pure business logic, calculations, geometry representations (no Revit API references).
   * `Application`: Commands, ViewModels, business services.
   * `Infrastructure`: Revit API implementations (`IExternalCommand`, `IExternalApplication`, `FilteredElementCollector` queries).
   * `UI`: WPF Views with `CommunityToolkit.Mvvm`.
2. **Commands:**
   * Every command must declare:
     ```csharp
     [Transaction(TransactionMode.Manual)]
     [Regeneration(RegenerationOption.Manual)]
     public class MyCommand : IExternalCommand
     ```
   * Commands must return `Result.Succeeded`, `Result.Failed`, or `Result.Cancelled`.
   * Never let uncaught exceptions escape `IExternalCommand.Execute`. Wrap the body in a try-catch and log or display a user-friendly error.
3. **WPF in Revit:**
   * Set `Window.Owner` to Revit’s main window handle (`Autodesk.Windows.ComponentManager.ApplicationWindow` or `Process.GetCurrentProcess().MainWindowHandle`) using `WindowInteropHelper` to maintain modal ownership.
   * Use dark/light theme aware styles.

---

## 4. Intelligent Skill & Knowledge Retrieval (Progressive Disclosure)

Do NOT guess or hallucinate API signatures. Read the specialized skill or knowledge reference file matching your task:

### Task-to-Skill Router
* **Scaffolding a new plugin or solution:** Read [`skills/revit-plugin-scaffold/SKILL.md`](skills/revit-plugin-scaffold/SKILL.md)
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
* **Full Semantic Knowledge Index:** [`knowledge/INDEX.md`](knowledge/INDEX.md)

---

## 5. Development & Build Commands

When executing CLI commands inside a Revit plugin repository created with this framework:
* **Build entire solution:** `dotnet build`
* **Build specific Revit version:**
  * Revit 2024: `dotnet build -f net48 -c "Release R24"`
  * Revit 2025: `dotnet build -f net8.0-windows -c "Release R25"`
  * Revit 2026: `dotnet build -f net8.0-windows -c "Release R26"`
* **Run Unit/Integration tests:** `dotnet test`
* **Scaffold new add-in via CLI:** `pwsh ./cli/bim-ai.ps1 new -Name MyAddin`
