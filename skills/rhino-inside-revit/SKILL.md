---
name: rhino-inside-revit
description: |
  Developing computational geometry pipelines using Rhino.Inside.Revit (RiR), authoring custom Grasshopper components, and bridging RhinoCommon with Revit API.
  Use whenever user asks to work with Rhino.Inside.Revit, transfer Breps/SubD into Revit, author Grasshopper Python scripts for Revit, or convert Rhino geometry to Revit DirectShape.
compatibility: Rhino 7/8 / Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Rhino.Inside.Revit (RiR) Computational Skill

Rhino.Inside.Revit embeds Robert McNeel & Associates' Rhino/Grasshopper directly into the memory space of Autodesk Revit.

---

## 1. Core RiR Architecture & Imports

Because Rhino and Revit share the same memory space, Grasshopper Python scripts can access both `RhinoCommon` and `Autodesk.Revit.DB` simultaneously:

```python
import clr
clr.AddReference('System.Core')
clr.AddReference('RhinoCommon')
clr.AddReference('RhinoInside.Revit')
clr.AddReference('RevitAPI')

import Rhino
import RhinoInside.Revit as rir
from RhinoInside.Revit import Revit, Convert
from Autodesk.Revit import DB

# Active document handles
doc = Revit.ActiveDBDocument
```

---

## 2. Geometry Conversion (RhinoCommon ⇄ Revit API)

Never write manual vertex conversion loops. Always use the built-in `Convert.Geometry` extension methods:

```python
# 1. Rhino Point3d -> Revit XYZ
rhino_pt = Rhino.Geometry.Point3d(10, 20, 0)
revit_xyz = Convert.Geometry.GeometryEncoder.ToXYZ(rhino_pt)

# 2. Revit XYZ -> Rhino Point3d
rhino_pt_back = Convert.Geometry.GeometryDecoder.ToPoint3d(revit_xyz)

# 3. Rhino Brep -> Revit Solid
rhino_brep = ... # Any Rhino.Geometry.Brep
revit_solid = Convert.Geometry.GeometryEncoder.ToSolid(rhino_brep)
```

---

## 3. Creating DirectShape Elements from Grasshopper

Transferring complex freeform geometry into native Revit categories (e.g. Mass, Generic Models, Floors):

```python
# Create DirectShape within a Transaction
with DB.Transaction(doc, "Grasshopper to Revit DirectShape") as t:
    t.Start()
    
    # Target Category (e.g., Generic Models)
    cat_id = DB.ElementId(DB.BuiltInCategory.OST_GenericModel)
    
    ds = DB.DirectShape.CreateElement(doc, cat_id)
    ds.ApplicationId = "GrasshopperRiR"
    ds.ApplicationDataId = "FreeformShape01"
    
    # Assign converted solid
    ds.SetShape([revit_solid])
    
    t.Commit()
```
