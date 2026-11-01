# Civil 3D API Architecture & Best Practices
<!-- BIM-AI-Foundation | Technical Reference -->

Autodesk Civil 3D builds on the AutoCAD .NET API, introducing high-level civil infrastructure databases.

---

## 1. Document & Database Architecture

```text
Autodesk.AutoCAD.ApplicationServices.Application
 └── Document (MdiActiveDocument)
      ├── Database (AutoCAD primitives)
      └── CivilDocument.GetCivilDocument(Database)
           ├── AlignmentIds (Centerlines, curb returns)
           ├── SurfaceIds (TIN, Grid, Volume surfaces)
           ├── CorridorIds (3D roadway models, baselines, subassemblies)
           └── PipeNetworkIds (Storm, sanitary, pressure pipes)
```

---

## 2. Invariants & Rules

1. **AutoCAD Transaction Dependency:** All Civil 3D objects are DBObjects stored in the DWG database. They require standard `Transaction` management and `OpenMode` semantics.
2. **Station Formatting:** Never format stations with raw string slicing. Always use `StationFormatType` or Civil 3D formatting utilities to respect project chainage formats (e.g., `10+50.00`).
3. **Corridor Rebuilds:** Modifying baseline alignments or assemblies requires checking `corridor.NeedsRebuild` and calling `corridor.Rebuild()`.
