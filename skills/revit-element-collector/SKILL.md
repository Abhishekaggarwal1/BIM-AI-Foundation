---
name: revit-element-collector
description: |
  High-speed FilteredElementCollector recipes, quick-filter chaining, spatial filtering, and performance optimization.
  Use whenever user asks to find, query, filter, or collect elements from the active document or view.
compatibility: Targets Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Element Collector Skill

Follow these performance rules when writing element queries:

## Essential Collector Recipes

### 1. Collect All Instances of a Category:
```csharp
var doors = new FilteredElementCollector(document)
    .OfClass(typeof(FamilyInstance))
    .OfCategory(BuiltInCategory.OST_Doors)
    .WhereElementIsNotElementType()
    .Cast<FamilyInstance>()
    .ToList();
```

### 2. Collect All Types/Symbols:
```csharp
var wallTypes = new FilteredElementCollector(document)
    .OfClass(typeof(WallType))
    .WhereElementIsElementType()
    .Cast<WallType>()
    .ToList();
```

### 3. Collect Visible Elements in Active View:
```csharp
var elementsInView = new FilteredElementCollector(document, activeView.Id)
    .WhereElementIsNotElementType()
    .ToElements();
```

### 4. Query Elements by Bounding Box:
```csharp
Outline outline = new Outline(minPoint, maxPoint);
var spatialFilter = new BoundingBoxIntersectsFilter(outline);

var elements = new FilteredElementCollector(document)
    .WherePasses(spatialFilter)
    .WhereElementIsNotElementType()
    .ToElements();
```

Reference `examples/CollectorExtensions.cs` for fluent querying extensions.
