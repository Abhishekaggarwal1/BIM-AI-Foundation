---
name: revit-model-validation
description: |
  Building model health audits, parameter validation, QA/QC rule checkers, unplaced room detection, and untagged element audits.
  Use whenever user asks to validate a Revit model, check model health, find unplaced rooms, or audit required parameters.
compatibility: Targets Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Model Validation & QA/QC Skill

Auditing BIM models requires read-only queries with high performance and zero transaction overhead.

## Common Validation Checks

1. **Unplaced Rooms:**
   ```csharp
   var unplacedRooms = new FilteredElementCollector(doc)
       .OfCategory(BuiltInCategory.OST_Rooms)
       .WhereElementIsNotElementType()
       .Cast<Autodesk.Revit.DB.Architecture.Room>()
       .Where(r => r.Location == null || r.Area < 1e-4)
       .ToList();
   ```

2. **Missing Parameter Check:**
   ```csharp
   var untaggedDoors = new FilteredElementCollector(doc)
       .OfCategory(BuiltInCategory.OST_Doors)
       .WhereElementIsNotElementType()
       .Where(d => string.IsNullOrWhiteSpace(d.get_Parameter(BuiltInParameter.ALL_MODEL_MARK)?.AsString()))
       .ToList();
   ```

Reference `examples/ModelValidator.cs` for a complete QA/QC auditor class.
