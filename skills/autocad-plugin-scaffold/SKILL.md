---
name: autocad-plugin-scaffold
description: |
  Scaffolding modern AutoCAD .NET add-ins (C#), defining AutoCAD commands, managing DocumentLock & Transactions, and authoring AutoLISP scripts.
  Use whenever user asks to create an AutoCAD plugin, write AutoCAD C# commands, interact with AutoCAD Database/BlockTable, or author AutoLISP (.lsp) routines.
compatibility: AutoCAD 2024 (net48), AutoCAD 2025-2026 (net8.0-windows).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# AutoCAD Plugin Scaffold & Command Development Skill

This skill provides procedural patterns, invariants, and templates for authoring production-grade **AutoCAD .NET (C#)** add-ins and **AutoLISP** automation.

---

## 1. Prime Invariants for AutoCAD Development

### 1.1 STA Threading & DocumentLock
* AutoCAD runs in a Single-Threaded Apartment (STA).
* Whenever code modifies an active drawing from a modeless dialog, palette, or async task, you **MUST lock the document**:
  ```csharp
  Document doc = Application.DocumentManager.MdiActiveDocument;
  using (DocumentLock docLock = doc.LockDocument())
  {
      // Database transaction here
  }
  ```

### 1.2 Transactions & Database Hierarchy
* Every entity (Line, Circle, Polyline, MText, BlockReference) lives inside a `BlockTableRecord` (e.g., `ModelSpace` or `PaperSpace`).
* Always access tables with `OpenMode.ForRead`, and only open the specific target container or entity with `OpenMode.ForWrite`:
  ```csharp
  Database db = doc.Database;
  using (Transaction tr = db.TransactionManager.StartTransaction())
  {
      BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
      BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

      using (Line line = new Line(new Point3d(0, 0, 0), new Point3d(100, 100, 0)))
      {
          btr.AppendEntity(line);
          tr.AddNewlyCreatedDBObject(line, true);
      }
      tr.Commit();
  }
  ```

### 1.3 Target Frameworks: AutoCAD 2024 vs 2025/2026
* **AutoCAD 2024:** .NET Framework 4.8 (`net48`).
* **AutoCAD 2025 & 2026:** **.NET 8.0 (.NET Core)** (`net8.0-windows`).
* Use conditional preprocessors when targeting multi-version AutoCAD:
  ```xml
  <TargetFrameworks>net8.0-windows;net48</TargetFrameworks>
  ```

---

## 2. Standard AutoCAD Command Template

```csharp
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Runtime;

[assembly: CommandClass(typeof(BimFoundation.AutoCAD.Commands))]

namespace BimFoundation.AutoCAD
{
    public class Commands
    {
        [CommandMethod("BIM_DRAWGRID", CommandFlags.Modal)]
        public void DrawGrid()
        {
            Document doc = Application.DocumentManager.MdiActiveDocument;
            if (doc == null) return;

            Database db = doc.Database;
            Editor ed = doc.Editor;

            // Prompt user for grid spacing
            PromptDoubleOptions pdo = new PromptDoubleOptions("\nEnter grid spacing in drawing units: ")
            {
                AllowNegative = false,
                AllowZero = false,
                DefaultValue = 1000.0
            };

            PromptDoubleResult pdr = ed.GetDouble(pdo);
            if (pdr.Status != PromptStatus.OK) return;

            double spacing = pdr.Value;

            using (DocumentLock docLock = doc.LockDocument())
            using (Transaction tr = db.TransactionManager.StartTransaction())
            {
                try
                {
                    BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
                    BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

                    int linesCreated = 0;
                    for (int i = 0; i < 5; i++)
                    {
                        double pos = i * spacing;
                        // Vertical line
                        Line vLine = new Line(new Point3d(pos, 0, 0), new Point3d(pos, 4 * spacing, 0));
                        btr.AppendEntity(vLine);
                        tr.AddNewlyCreatedDBObject(vLine, true);

                        // Horizontal line
                        Line hLine = new Line(new Point3d(0, pos, 0), new Point3d(4 * spacing, pos, 0));
                        btr.AppendEntity(hLine);
                        tr.AddNewlyCreatedDBObject(hLine, true);

                        linesCreated += 2;
                    }

                    tr.Commit();
                    ed.WriteMessage($"\n[BIM-AI-Foundation] Successfully generated {linesCreated} grid lines.");
                }
                catch (System.Exception ex)
                {
                    ed.WriteMessage($"\n[ERROR] Command failed: {ex.Message}");
                    tr.Abort();
                }
            }
        }
    }
}
```

---

## 3. AutoLISP (.lsp) Scripting Reference

For lightweight automation directly in the AutoCAD command line:

```lisp
;;; Standard AutoLISP Routine - BIM-AI-Foundation
(defun c:BIM_QUICKAUDIT ()
  (vl-load-com)
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq layers (vla-get-layers doc))
  (setq layerCount (vla-get-count layers))
  
  (princ (strcat "\n[BIM-AI-Foundation] Total layers in drawing: " (itoa layerCount)))
  
  ;; Count total entities in ModelSpace
  (setq mspace (vla-get-modelspace doc))
  (setq entityCount (vla-get-count mspace))
  (princ (strcat "\n[BIM-AI-Foundation] Total entities in ModelSpace: " (itoa entityCount)))
  (princ)
)
```
