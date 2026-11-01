---
name: civil3d-plugin-scaffold
description: |
  Scaffolding Autodesk Civil 3D .NET plugins (C#), querying CivilDocument, automating Alignments, Profiles, Corridors, Surfaces (TIN), and Pipe Networks.
  Use whenever user asks to create Civil 3D plugins, manipulate Civil 3D terrain/surfaces, calculate station and offset, or automate infrastructure designs.
compatibility: Autodesk Civil 3D 2024 (net48), Civil 3D 2025-2026 (net8.0-windows).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Civil 3D Plugin Scaffold & Infrastructure Engineering Skill

Autodesk Civil 3D extends AutoCAD with civil infrastructure objects: Alignments, Profiles, Corridors, TIN Surfaces, and Pressure/Gravity Pipe Networks.

---

## 1. Prime Invariants for Civil 3D Development

### 1.1 CivilDocument Access
Civil 3D objects are owned by `CivilDocument`, which is linked to the active AutoCAD `Database`:
```csharp
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.Civil.ApplicationServices;

Document acadDoc = Application.DocumentManager.MdiActiveDocument;
Database db = acadDoc.Database;
CivilDocument civilDoc = CivilDocument.GetCivilDocument(db);
```

### 1.2 Alignments & Station/Offset Math
* Alignments represent highway, railway, or utility baselines.
* Always query station and offset via native geometry projection:
  ```csharp
  using Autodesk.Civil.DatabaseServices;

  Alignment alignment = (Alignment)tr.GetObject(alignmentId, OpenMode.ForRead);
  double station = 0.0;
  double offset = 0.0;
  alignment.StationOffset(point3d.X, point3d.Y, ref station, ref offset);
  ```

### 1.3 Surface Sampling & Elevation Queries
```csharp
TinSurface surface = (TinSurface)tr.GetObject(surfaceId, OpenMode.ForRead);
double elevation = surface.FindElevationAtXY(x, y);
```

---

## 2. Standard Civil 3D Command Template

```csharp
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Runtime;
using Autodesk.Civil.ApplicationServices;
using Autodesk.Civil.DatabaseServices;

[assembly: CommandClass(typeof(BimCivil3D.Commands))]

namespace BimCivil3D
{
    public class Commands
    {
        [CommandMethod("CIVIL_AUDITALIGNMENTS", CommandFlags.Modal)]
        public void AuditAlignments()
        {
            Document doc = Application.DocumentManager.MdiActiveDocument;
            if (doc == null) return;

            CivilDocument civilDoc = CivilDocument.GetCivilDocument(doc.Database);
            Editor ed = doc.Editor;

            using (Transaction tr = doc.Database.TransactionManager.StartTransaction())
            {
                ObjectIdCollection alignmentIds = civilDoc.GetAlignmentIds();
                ed.WriteMessage($"\n--- Civil 3D Alignments ({alignmentIds.Count} found) ---");

                foreach (ObjectId alignId in alignmentIds)
                {
                    Alignment align = (Alignment)tr.GetObject(alignId, OpenMode.ForRead);
                    ed.WriteMessage($"\n- Alignment: {align.Name}, Length: {align.Length:F2}m, Start Station: {align.StartingStation:F2}");
                }

                tr.Commit();
            }
        }
    }
}
```
