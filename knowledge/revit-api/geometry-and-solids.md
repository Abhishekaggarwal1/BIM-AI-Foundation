# Geometry & Solids in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. Extracting Element Geometry

Revit elements wrap their 3D geometry in a `GeometryElement`. Geometry can be nested inside `GeometryInstance` objects (especially for family instances like doors, windows, and columns).

```csharp
using Autodesk.Revit.DB;

public static List<Solid> GetElementSolids(Element element)
{
    var solids = new List<Solid>();

    var options = new Options
    {
        ComputeReferences = true,
        DetailLevel = ViewDetailLevel.Fine,
        IncludeNonVisibleObjects = false
    };

    GeometryElement geomElement = element.get_Geometry(options);
    if (geomElement == null) return solids;

    ExtractSolidsRecursive(geomElement, solids);
    return solids;
}

private static void ExtractSolidsRecursive(GeometryElement geomElement, List<Solid> solids)
{
    foreach (GeometryObject obj in geomElement)
    {
        if (obj is Solid solid && solid.Volume > 1e-6)
        {
            solids.Add(solid);
        }
        else if (obj is GeometryInstance instance)
        {
            // Extract geometry from family instances (transformed into project coordinates):
            GeometryElement instanceGeom = instance.GetInstanceGeometry();
            if (instanceGeom != null)
            {
                ExtractSolidsRecursive(instanceGeom, solids);
            }
        }
    }
}
```

---

## 2. Boolean Operations on Solids

Revit provides `BooleanOperationsUtils` for performing CSG (Constructive Solid Geometry) operations:

```csharp
public static Solid IntersectSolids(Solid solidA, Solid solidB)
{
    try
    {
        return BooleanOperationsUtils.ExecuteBooleanOperation(
            solidA, 
            solidB, 
            BooleanOperationsType.Intersect
        );
    }
    catch (Autodesk.Revit.Exceptions.InvalidOperationException)
    {
        // Solids do not intersect or form an invalid boundary
        return null;
    }
}
```

Supported operation types:
* `BooleanOperationsType.Union`
* `BooleanOperationsType.Intersect`
* `BooleanOperationsType.Difference`

---

## 3. Ray Casting with `ReferenceIntersector`

`ReferenceIntersector` casts a 3D ray through a 3D view and returns all intersected elements or surfaces:

```csharp
public static ReferenceWithContext FindNearestObstacle(
    View3D view3D, 
    XYZ origin, 
    XYZ direction)
{
    // Filter to intersect only Walls and Columns:
    var filter = new ElementMulticategoryFilter(new[]
    {
        BuiltInCategory.OST_Walls,
        BuiltInCategory.OST_Columns,
        BuiltInCategory.OST_StructuralColumns
    });

    var intersector = new ReferenceIntersector(filter, FindReferenceTarget.Element, view3D)
    {
        FindEntireChildrenContext = true
    };

    return intersector.FindNearest(origin, direction);
}
```
