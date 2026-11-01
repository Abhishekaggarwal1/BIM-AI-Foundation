---
name: revit-family-automator
description: |
  Automating Autodesk Revit Family (.rfa) document creation, parameter injection, formula manipulation, type catalogs, and nested family insertion.
  Use whenever user asks to edit family files programmatically, add family parameters, automate type creation, or use FamilyManager.
compatibility: Revit 2024-2026 / C# .NET & Python.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Family (.rfa) Automation Skill

Automating Revit family documents requires operating on a `Document` where `doc.IsFamilyDocument == true` using `doc.FamilyManager`.

---

## 1. Prime Invariants for Family Automation

### 1.1 Document Context
* You cannot add family parameters to a project document (`.rvt`).
* You must open or edit the family document (`doc.EditFamily(familyInstance.Symbol.Family)` or `app.OpenDocumentFile("path.rfa")`).

### 1.2 Using `FamilyManager`
```csharp
using Autodesk.Revit.DB;

Document famDoc = doc.EditFamily(family);
FamilyManager famMgr = famDoc.FamilyManager;

using (Transaction tr = new Transaction(famDoc, "Add Parameter & Types"))
{
    tr.Start();

    // 1. Add Family Parameter using modern SpecTypeId (Revit 2024+)
    FamilyParameter param = famMgr.AddParameter(
        "Clearance_Width",
        GroupTypeId.Dimensions,
        SpecTypeId.Length,
        false // isInstance
    );

    // 2. Set formula
    famMgr.SetFormula(param, "Width + 50 mm");

    // 3. Add Family Type
    FamilyType newType = famMgr.NewType("Type B - 1200mm");

    tr.Commit();
}

// Reload into project with custom load options
famDoc.LoadFamily(doc, new FamilyLoadOptions());
```

### 1.3 `IFamilyLoadOptions` Implementation
```csharp
public class FamilyLoadOptions : IFamilyLoadOptions
{
    public bool OnFamilyFound(bool familyInUse, out bool overwriteParameterValues)
    {
        overwriteParameterValues = true;
        return true;
    }

    public bool OnSharedFamilyFound(Family sharedFamily, bool familyInUse, out FamilySource source, out bool overwriteParameterValues)
    {
        source = FamilySource.Family;
        overwriteParameterValues = true;
        return true;
    }
}
```
