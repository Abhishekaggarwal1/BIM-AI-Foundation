---
name: revit-geometry-analysis
description: |
  Solid extraction, boolean intersection, clash detection, volume calculation, and ray tracing.
  Use whenever user asks to analyze geometry, check element intersections, calculate bounding volumes, or cast rays.
compatibility: Targets Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Geometry Analysis Skill

## 1. Extracting Solids from Elements
Elements may contain multiple solids or nested geometry instances.
Always use `Options` with `DetailLevel = ViewDetailLevel.Fine`:

```csharp
var options = new Options
{
    ComputeReferences = true,
    DetailLevel = ViewDetailLevel.Fine
};

GeometryElement geom = element.get_Geometry(options);
List<Solid> solids = GeometryUtils.ExtractSolids(geom);
```

## 2. Boolean Intersections (Clash Detection)
```csharp
Solid? intersection = GeometryUtils.Intersect(solidA, solidB);
if (intersection != null && intersection.Volume > 1e-4)
{
    // Real clash detected with intersection volume:
    double volumeCubicFeet = intersection.Volume;
}
```

Reference `examples/GeometryUtils.cs` for complete implementations.
