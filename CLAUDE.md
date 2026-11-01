# CLAUDE.md — Claude Code Project Instructions
<!-- BIM-AI-Foundation | Revit Add-in Engineering Framework -->

## Overview
This repository provides a standardized foundation for developing Autodesk Revit plugins across Revit 2024, 2025, and 2026 using C# and modern .NET.

## Non-Negotiable Revit API Invariants
1. **STA Threading:** Revit API is strictly single-threaded. Never invoke Revit API methods from background tasks or WPF events without `ExternalEvent` or `RevitTask`.
2. **Transactions:** All model modifications require `using (var t = new Transaction(doc, "...")) { t.Start(); ... t.Commit(); }`.
3. **ElementId:** Always use `ElementId.Value` (`long`), NOT obsolete `ElementId.IntegerValue`.
4. **Units & Parameters:** Use `ForgeTypeId` (`SpecTypeId.*` and `UnitTypeId.*`) via `UnitUtils`. Obsolete enums (`ParameterType`, `DisplayUnitType`) are forbidden.
5. **Collector Performance:** Use `FilteredElementCollector` with quick filters (`OfClass`, `OfCategory`, `WhereElementIsNotElementType`) before applying any slow filter or LINQ.

## Common Developer Commands
- **Build Solution:** `dotnet build`
- **Build Revit 2024 (.NET 4.8):** `dotnet build -f net48 -c "Release R24"`
- **Build Revit 2025/2026 (.NET 8):** `dotnet build -f net8.0-windows -c "Release R25"`
- **Build AutoCAD 2024 (.NET 4.8):** `dotnet build -f net48`
- **Build AutoCAD 2025/2026 (.NET 8):** `dotnet build -f net8.0-windows`
- **Test:** `dotnet test`
- **CLI Tool:** `pwsh ./cli/bim-ai.ps1 [status|init|new|sync|validate]`

## Progressive Skill Retrieval
When handling specific tasks, read the specialized skill file before writing code:
- Revit Plugin Scaffolding (C#): `skills/revit-plugin-scaffold/SKILL.md`
- pyRevit Extensions & Python: `skills/revit-pyrevit-extension/SKILL.md`
- Revit Dynamo Python & Zero-Touch Nodes: `skills/revit-dynamo-script/SKILL.md`
- AutoCAD .NET (C#) & AutoLISP: `skills/autocad-plugin-scaffold/SKILL.md`
- Async & ExternalEvents: `skills/revit-external-event/SKILL.md`
- Parameter & Unit Management: `skills/revit-parameter-manager/SKILL.md`
- High-Performance Filtering: `skills/revit-element-collector/SKILL.md`
- Geometry & Boolean Intersections: `skills/revit-geometry-analysis/SKILL.md`
- Failure & Warning Handling: `skills/revit-failure-handler/SKILL.md`
- Model Validation & QA/QC: `skills/revit-model-validation/SKILL.md`
- Dockable Panels & WPF MVVM: `skills/revit-dockable-panel/SKILL.md`
- Version Breaking Changes: `knowledge/breaking-changes-matrix.md`
