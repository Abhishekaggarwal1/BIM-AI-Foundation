# GitHub Copilot Instructions for BIM-AI-Foundation

## Repository Overview
This repository provides a framework for building Autodesk Revit add-ins in C# (.NET) supporting Revit 2024, 2025, and 2026.

## Non-Negotiable Coding Rules
1. **Thread Safety:** Never call `Autodesk.Revit.DB` or `UI` methods outside the main Revit STA thread. Always use `ExternalEvent` or `RevitTask` from WPF or async code.
2. **Transaction Scoping:** Use `using (var t = new Transaction(doc, "Name")) { t.Start(); ... t.Commit(); }` for any model change.
3. **ElementId:** Always use `element.Id.Value` (`long`). Never use `ElementId.IntegerValue`.
4. **Units:** Always convert using `UnitUtils.ConvertFromInternalUnits()` or `UnitUtils.ConvertToInternalUnits()` with `ForgeTypeId` (`UnitTypeId.*`).
5. **Collector Optimization:** Apply `OfClass()`, `OfCategory()`, and `WhereElementIsNotElementType()` before doing any in-memory LINQ or slow filters.
6. **Multi-Targeting:** Revit 2024 targets `net48`; Revit 2025 and 2026 target `net8.0-windows`. Use preprocessor conditional `#if REVIT2025_OR_GREATER` when necessary.
7. **Task-Specific Skills:** Consult `skills/*/SKILL.md` for procedural recipes and tested templates.
