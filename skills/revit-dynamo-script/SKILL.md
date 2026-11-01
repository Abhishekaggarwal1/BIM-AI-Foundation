---
name: revit-dynamo-script
description: |
  Authoring Python scripts for Dynamo, building custom Zero-Touch C# nodes, and automating Revit via Dynamo graphs.
  Use whenever user asks to write Dynamo Python scripts, create custom Dynamo nodes, use RevitServices, or interact with Revit through Dynamo.
compatibility: Dynamo 2.x - 3.x / Revit 2024-2026 (PythonNet CPython 3 and IronPython 2.7).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Dynamo Scripting & Python Node Skill

Dynamo enables visual programming and computational design in Autodesk Revit. Inside Dynamo, developers write custom logic using **Python Script** nodes or compile **Zero-Touch C# .NET** node libraries.

---

## 1. Core Dynamo Python Architecture

Unlike pyRevit or standard add-ins, Dynamo manages its own transaction and document context via `RevitServices`.

### Essential Imports & Boilerplate:
```python
# -*- coding: utf-8 -*-
import clr

# Import Revit API
clr.AddReference('RevitAPI')
import Autodesk
from Autodesk.Revit.DB import *

# Import Revit API UI (if needed)
clr.AddReference('RevitAPIUI')
from Autodesk.Revit.UI import *

# Import RevitServices (Dynamo context & transaction manager)
clr.AddReference('RevitServices')
import RevitServices
from RevitServices.Persistence import DocumentManager
from RevitServices.Transactions import TransactionManager

# Import Dynamo Geometry / RevitNodes (for wrapping/unwrapping)
clr.AddReference('RevitNodes')
import Revit
clr.ImportExtensions(Revit.Elements)
clr.ImportExtensions(Revit.GeometryConversion)

# Standard document handles
doc = DocumentManager.Instance.CurrentDBDocument
uiapp = DocumentManager.Instance.CurrentUIApplication
app = uiapp.Application
```

---

## 2. Invariants & Rules for Dynamo Python

### 2.1 Unwrapping Dynamo Elements
Dynamo wraps native Revit elements inside Dynamo wrapper classes (`Revit.Elements.Element`).
* To call native Revit API methods or read Revit parameters, you **MUST unwrap** them:
  ```python
  # Single element unwrapping:
  revit_elem = UnwrapElement(IN[0])

  # List unwrapping:
  input_list = IN[0] if isinstance(IN[0], list) else [IN[0]]
  revit_elements = [UnwrapElement(e) for e in input_list]
  ```

### 2.2 Transactions in Dynamo
* **NEVER use `using (Transaction tr = ...)` or raw `Transaction(doc)` in Dynamo Python.**
* **ALWAYS use Dynamo's `TransactionManager`:**
  ```python
  TransactionManager.Instance.EnsureInTransaction(doc)
  try:
      # Perform database modifications here
      element.LookupParameter("Comments").Set("Modified by Dynamo")
  finally:
      TransactionManager.Instance.TransactionTaskDone()
  ```
* For read-only scripts, do NOT call `EnsureInTransaction`.

### 2.3 Geometry Interop: Revit vs Dynamo Geometry
Dynamo geometry (`Autodesk.DesignScript.Geometry`) is distinct from Revit geometry (`Autodesk.Revit.DB`):
* **Revit to Dynamo:** `revit_curve.ToProtoType()` or `revit_point.ToPoint()`
* **Dynamo to Revit:** `dynamo_curve.ToRevitType()` or `dynamo_point.ToXyz()`

### 2.4 ElementId in Revit 2024+
* Always use `element.Id.Value` (returns `long` / 64-bit integer).
* Never convert to 32-bit `int` or rely on `IntegerValue`.

---

## 3. Production Dynamo Python Template

```python
# -*- coding: utf-8 -*-
"""Dynamo Python Script - BIM-AI-Foundation Template
Author: BIM-AI-Foundation
Description: Batch sets parameter values on unwrapped Revit elements.
"""

import clr
clr.AddReference('RevitAPI')
from Autodesk.Revit.DB import *

clr.AddReference('RevitServices')
from RevitServices.Persistence import DocumentManager
from RevitServices.Transactions import TransactionManager

doc = DocumentManager.Instance.CurrentDBDocument

# Input handling: IN[0] = Elements, IN[1] = Parameter Name, IN[2] = Value to Set
def to_list(obj):
    if obj is None: return []
    return obj if isinstance(obj, list) else [obj]

raw_elements = to_list(IN[0])
param_name = str(IN[1]) if IN[1] is not None else ""
new_value = IN[2]

# Unwrap Dynamo elements into Revit DB elements
elements = [UnwrapElement(e) for e in raw_elements if e is not None]

success_count = 0
errors = []

# Modify database within Dynamo TransactionManager
TransactionManager.Instance.EnsureInTransaction(doc)
try:
    for elem in elements:
        try:
            param = elem.LookupParameter(param_name)
            if param and not param.IsReadOnly:
                if isinstance(new_value, str):
                    param.Set(new_value)
                elif isinstance(new_value, (int, float)):
                    param.Set(float(new_value))
                success_count += 1
            else:
                errors.append("Parameter '{}' missing or read-only on Element ID: {}".format(param_name, elem.Id.Value))
        except Exception as ex:
            errors.append("Element ID {}: {}".format(elem.Id.Value, str(ex)))
finally:
    TransactionManager.Instance.TransactionTaskDone()

# Output ports: OUT[0] = Count, OUT[1] = Error reports
OUT = [success_count, errors]
```

---

## 4. Zero-Touch C# Node Development

To create high-performance custom nodes in C# for Dynamo:
1. Create a standard `.NET` Class Library targeting `net8.0-windows` (for Revit 2025/2026) or `net48` (Revit 2024).
2. Reference Dynamo NuGet packages:
   * `DynamoVisualProgramming.ZeroTouchLibrary`
   * `DynamoVisualProgramming.WpfUILibrary`
3. Any `public static` method in a `public class` automatically displays as a node in the Dynamo library!
4. Use `[IsVisibleInDynamoLibrary(false)]` to hide internal helper methods.
