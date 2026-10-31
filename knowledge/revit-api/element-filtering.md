# High-Performance Element Filtering in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. Quick Filters vs. Slow Filters
In Revit's internal database (C++ core), element data is stored in native memory. When you query elements in C#, Revit must wrap native elements into managed .NET objects.
* **Quick Filters:** Evaluated natively in C++ without loading full element geometry or parameters into managed memory.
* **Slow Filters:** Require loading element geometry or parameters into memory, taking 10x–100x longer.

### Filter Classification:

| Filter Type | Examples | Performance |
| :--- | :--- | :--- |
| **Quick Filters** | `ElementClassFilter` (`OfClass`), `ElementCategoryFilter` (`OfCategory`), `ElementIsElementTypeFilter` (`WhereElementIsElementType` / `WhereElementIsNotElementType`), `ElementOwnerViewFilter`, `ElementIdSetFilter`, `BoundingBoxIntersectsFilter` | ⚡ **Ultra Fast** (Native C++) |
| **Slow Filters** | `ElementParameterFilter`, `FamilySymbolFilter`, `RoomFilter`, `SpatialElementBoundaryFilter`, `ElementIntersectsSolidFilter`, `ElementIntersectsElementFilter` | 🐢 **Slow** (Memory heavy) |

---

## 2. The Golden Collector Ordering Rule

Always chain filters from **most restrictive quick filter** to **least restrictive slow filter**:

```
1. Scope Collector ────────► new FilteredElementCollector(doc) OR new FilteredElementCollector(doc, activeView.Id)
2. Class Filter   ────────► .OfClass(typeof(FamilyInstance))
3. Category Filter ───────► .OfCategory(BuiltInCategory.OST_Doors)
4. Instance/Type ─────────► .WhereElementIsNotElementType()
5. Parameter/Slow Filter ─► .WherePasses(parameterFilter)
6. Enumeration ───────────► foreach / .ToElements()
```

### High-Performance Example:
```csharp
// Collecting all active door instances in the model:
var doors = new FilteredElementCollector(document)
    .OfClass(typeof(FamilyInstance))
    .OfCategory(BuiltInCategory.OST_Doors)
    .WhereElementIsNotElementType()
    .Cast<FamilyInstance>()
    .ToList();
```

---

## 3. Severe Anti-Patterns (Do NOT Do This)

### Anti-Pattern 1: Premature LINQ Enumeration
```csharp
// ❌ HORRIBLE PERFORMANCE: Instantiates 150,000 C# element wrappers into memory!
var walls = new FilteredElementCollector(doc)
    .Where(e => e is Wall)
    .Where(e => e.Name.Contains("Exterior"))
    .ToList();

// ✅ OPTIMIZED: Evaluated in native core, only Exterior walls loaded into .NET:
var walls = new FilteredElementCollector(doc)
    .OfClass(typeof(Wall))
    .WhereElementIsNotElementType()
    .Cast<Wall>()
    .Where(w => w.Name.Contains("Exterior"))
    .ToList();
```

### Anti-Pattern 2: String Comparison on Categories
```csharp
// ❌ WRONG: Slow and breaks on localized Revit (e.g., German/French Revit where category is "Wände"):
var walls = collector.Where(e => e.Category?.Name == "Walls");

// ✅ CORRECT: Language-neutral and evaluated at database level:
var walls = collector.OfCategory(BuiltInCategory.OST_Walls);
```

---

## 4. Spatial & Bounding Box Queries

To find elements within a spatial region without evaluating all elements in the project:

```csharp
// Define an Outline bounding box in feet:
Outline outline = new Outline(new XYZ(0, 0, 0), new XYZ(50, 50, 20));
BoundingBoxIntersectsFilter spatialFilter = new BoundingBoxIntersectsFilter(outline);

var elementsInZone = new FilteredElementCollector(document)
    .WherePasses(spatialFilter)
    .WhereElementIsNotElementType()
    .ToElements();
```
