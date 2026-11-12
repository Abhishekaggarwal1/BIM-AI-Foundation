# BIM-AI-Foundation: Complete User Guide & Developer Handbook
<!-- Step-by-Step Guide for AI-Assisted AEC Software Development -->

Welcome to **BIM-AI-Foundation**! This guide walks you through setting up your environment, scaffolding new plugins, integrating AI rules into existing projects, and getting the most out of AI coding assistants like **Cursor IDE**, **Claude Code**, **GitHub Copilot**, and **Windsurf**.

---

## 1. Quick Start: Scaffolding a New Project

The repository includes a cross-platform CLI tool (`cli/bim-ai.ps1` and `cli/bim-ai.cmd`) that generates production-ready projects pre-configured with multi-targeting and AI domain rules.

You can run commands using **PowerShell 7 (`pwsh`)**, **Windows PowerShell (`powershell`)**, or **Windows Command Prompt (`cli\bim-ai.cmd`)**.

### Scaffolding Commands

```powershell
# 1. Revit C# Add-in (Multi-targets Revit 2024, 2025, and 2026)
pwsh ./cli/bim-ai.ps1 new -Name "SmartWallFilter" -Type "csharp"

# 2. pyRevit Python Extension (Creates .extension, .tab, and pushbutton panels)
pwsh ./cli/bim-ai.ps1 new -Name "CustomBimTools" -Type "pyrevit"

# 3. AutoCAD .NET Add-in (Multi-targets AutoCAD 2024 .NET 4.8 & 2025/2026 .NET 8)
pwsh ./cli/bim-ai.ps1 new -Name "LayerAuditor" -Type "autocad"

# 4. Navisworks Manage Add-in (Navisworks 2024-2026 Clash Automation)
pwsh ./cli/bim-ai.ps1 new -Name "ClashManager" -Type "navisworks"

# 5. Dynamo Python Workspace (Pre-wired with TransactionManager and RevitServices)
pwsh ./cli/bim-ai.ps1 new -Name "DynamoScripts" -Type "dynamo"

# 6. OpenBIM / IFC Tools (IfcOpenShell & buildingSMART IDS automation)
pwsh ./cli/bim-ai.ps1 new -Name "IfcValidator" -Type "openbim"
```

*(If running from CMD or without PowerShell 7, simply replace `pwsh ./cli/bim-ai.ps1` with `.\cli\bim-ai.cmd`)*

---

## 2. Integrating Rules into an Existing Project

If you already have an existing Revit or CAD plugin repository and want AI coding assistants to stop making common Revit API mistakes, you can inject BIM-AI-Foundation rules directly:

```powershell
pwsh ./cli/bim-ai.ps1 init -TargetDir "C:\Projects\MyExistingRevitAddin"
```

### What this does:
- Copies **`AGENTS.md`** (universal AI standard for Cursor, Claude, Copilot).
- Copies **`.cursor/rules/*.mdc`** for Cursor IDE progressive disclosure.
- Copies **`.github/copilot-instructions.md`** for GitHub Copilot.
- Copies the **19 Agent Skills** (`skills/`) and architectural knowledge base (`knowledge/`).

---

## 3. How to Use with AI Coding Assistants

Once a project has BIM-AI-Foundation rules, your AI assistant automatically gains AEC domain intelligence. Here is how to prompt effectively:

### A. Working in Cursor IDE
- Cursor automatically loads `.cursor/rules/bim-skills-router.mdc`.
- **Tip:** When asking for specific features, mention the domain or target skill in chat:
  > *"Using the `revit-external-event` skill, create a modeless WPF progress bar that updates Revit wall parameters asynchronously."*
  > *"Using `revit-geometry-analysis`, find all beam solids that intersect with duct solids."*

### B. Working with Claude Code
- Claude Code automatically reads `CLAUDE.md` and routes queries to `skills/*/SKILL.md`.
- **Tip:** Claude will read the relevant skill without loading the entire repository documentation, saving up to 85% of tokens.

### C. Working with GitHub Copilot
- Copilot reads `.github/copilot-instructions.md` and respects the STA threading model, `ElementId.Value`, and `ForgeTypeId` parameter standards.

---

## 4. Building and Compiling Scaffolded Projects

Projects scaffolded with BIM-AI-Foundation use SDK-style projects and official NuGet packages (`Nice3point.Revit.Api`, `AutoCAD.NET`, `Chuongmep.Navis.Api`). You **do not** need Revit or AutoCAD installed to compile!

### Build Commands:

```powershell
# Build entire solution for default version (Revit 2025 .NET 8)
dotnet build MyPlugin.sln -c Release

# Target specific Revit versions:
dotnet build -f net48 -c "Release R24"            # Revit 2024 (.NET Framework 4.8)
dotnet build -f net8.0-windows -c "Release R25"   # Revit 2025 (.NET 8.0)
dotnet build -f net8.0-windows -c "Release R26"   # Revit 2026 (.NET 8.0)

# Target AutoCAD versions:
dotnet build -f net48                             # AutoCAD 2024 (.NET 4.8)
dotnet build -f net8.0-windows                    # AutoCAD 2025/2026 (.NET 8.0)
```

---

## 5. Scanning Code for API Anti-Patterns

Before testing or releasing an add-in, scan your codebase with the built-in static validator:

```powershell
pwsh ./cli/bim-ai.ps1 validate -TargetDir "C:\Path\To\Your\Code"
```

### What it checks:
1. **Obsolete 32-bit IDs:** Flags `ElementId.IntegerValue` and suggests `ElementId.Value` (`long`).
2. **Obsolete Unit Enums:** Flags `ParameterType` and `DisplayUnitType`, directing you to modern `ForgeTypeId`.
3. **STA Threading Violations:** Flags `Task.Run()` calls that interact directly with the Revit or AutoCAD API without `RevitTask` or `DocumentLock`.
4. **Dynamo Transaction Violations:** Flags raw `new Transaction(doc)` in Dynamo Python scripts, suggesting `TransactionManager.Instance.EnsureInTransaction(doc)`.

---

## 6. Catalog of the 19 Agent Skills

| Skill Folder | When to Use / Prompt Trigger |
| :--- | :--- |
| `revit-plugin-scaffold` | Creating new Revit C# add-ins, configuring `.csproj`, Ribbon buttons, `.addin` manifest. |
| `revit-external-event` | Async/await, modeless WPF dialogs, background threads, `RevitTask`. |
| `revit-parameter-manager`| Reading/writing parameters, unit conversions with `UnitUtils` and `ForgeTypeId`. |
| `revit-element-collector`| High-speed element queries, quick filters (`OfClass`, `OfCategory`, bounding box). |
| `revit-geometry-analysis`| Extracting solids, boolean operations, clash checks, ray casting. |
| `revit-failure-handler` | Suppressing modal warning popups, custom `IFailuresPreprocessor`. |
| `revit-model-validation` | Automated model audits, unplaced rooms, door/window QA/QC checks. |
| `revit-dockable-panel` | Dockable panels and palettes with WPF MVVM (`IDockablePaneProvider`). |
| `revit-family-automator`| Modifying `.rfa` family documents, `FamilyManager`, formulas, parameters. |
| `revit-pyrevit-extension`| pyRevit pushbuttons, `bundle.yaml`, Python ribbon integration. |
| `revit-dynamo-script` | Revit Dynamo Python nodes, `RevitServices`, geometry conversion. |
| `revit-unit-testing` | Automated testing with xUnit, in-process testing, decoupled architecture. |
| `autocad-plugin-scaffold`| AutoCAD C# plugins, `DocumentLock`, AutoLISP scripting. |
| `civil3d-plugin-scaffold`| Civil 3D alignments, profiles, TIN surfaces, corridors. |
| `navisworks-plugin-scaffold`| Navisworks Manage plugins, Clash Detective automation, selection sets. |
| `openbim-ifc-processing` | Parsing IFC files, extracting properties, IDS validation via `IfcOpenShell`. |
| `rhino-inside-revit` | RhinoCommon to Revit geometry conversion in Grasshopper. |
| `bim-bcf-manager` | Reading and writing BCF 2.1/3.0 XML issue reports with 3D camera viewpoints. |
| `aps-design-automation` | Headless batch processing via Autodesk Platform Services (Forge). |

