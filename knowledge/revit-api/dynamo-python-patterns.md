# Dynamo Architecture & Python Scripting Patterns
<!-- BIM-AI-Foundation | Technical Reference -->

Dynamo integrates visual node graphs with imperative code via **Python Script** nodes and compiled **Zero-Touch C#** libraries.

---

## 1. Dynamo Python Engines: IronPython vs. CPython 3

Starting in Dynamo 2.8 and Revit 2022+, Dynamo introduced **CPython 3 (PythonNet)** alongside the legacy **IronPython 2.7**:
* **IronPython 2.7:** Direct CLR interop, but obsolete Python 2 syntax and lack of modern third-party C-extensions.
* **CPython 3 (Default in Revit 2024–2026):** Enables libraries like `numpy`, `scipy`, `pandas`, and standard `python 3.9+` syntax.

### Key Syntax Differences in CPython 3:
1. Strings are Unicode by default (no need for `unicode()` or `u""`).
2. Iterators: `map()` and `filter()` return generators, not lists. Always wrap with `list()`.
3. Division: `/` returns float; use `//` for integer division.

---

## 2. The RevitServices Ecosystem

Dynamo controls the Revit lifecycle through the `RevitServices` assembly:

```python
import clr
clr.AddReference('RevitServices')
from RevitServices.Persistence import DocumentManager
from RevitServices.Transactions import TransactionManager

# 1. Document & Application Access
doc = DocumentManager.Instance.CurrentDBDocument
uiapp = DocumentManager.Instance.CurrentUIApplication
app = uiapp.Application

# 2. Transaction Management
# Always use TransactionManager, NOT Autodesk.Revit.DB.Transaction
TransactionManager.Instance.EnsureInTransaction(doc)
# ... apply modifications ...
TransactionManager.Instance.TransactionTaskDone()

# Optional: Force model regeneration during multi-step scripts
TransactionManager.Instance.ForceCloseTransaction()
```

---

## 3. Element Wrapping & Unwrapping

Dynamo elements (from node output) are wrapped in `Revit.Elements.Element`. The Revit API expects `Autodesk.Revit.DB.Element`.

```python
clr.AddReference('RevitNodes')
import Revit
clr.ImportExtensions(Revit.Elements)

# Unwrap Dynamo element to native Revit API element:
revit_wall = UnwrapElement(IN[0])

# Access native Revit properties:
wall_type = doc.GetElement(revit_wall.GetTypeId())

# Wrap native Revit API element back into Dynamo element:
dynamo_wall = revit_wall.ToDSType(isRevitOwned=True)
```

---

## 4. Geometry Conversion (`Revit.GeometryConversion`)

When working between Dynamo's `Autodesk.DesignScript.Geometry` and Revit's `Autodesk.Revit.DB`:

```python
clr.ImportExtensions(Revit.GeometryConversion)

# 1. Dynamo Point -> Revit XYZ
dynamo_pt = IN[0]
revit_xyz = dynamo_pt.ToXyz()

# 2. Revit XYZ -> Dynamo Point
dynamo_pt_out = revit_xyz.ToPoint()

# 3. Dynamo Curve -> Revit Curve
revit_curve = dynamo_curve.ToRevitType()

# 4. Revit Curve -> Dynamo Curve
dynamo_curve_out = revit_curve.ToProtoType()
```

---

## 5. Defensive Input Handling & List Lacing

Dynamo users may supply single elements, lists, or nested lists to ports (`IN[0]`, `IN[1]`, etc.). Always normalize inputs:

```python
def to_list(obj):
    """Normalizes single item or list into a standard flat list."""
    if obj is None:
        return []
    if isinstance(obj, list):
        return obj
    return [obj]

# Flatten nested lists recursively if needed
def flatten(nested_list):
    for item in nested_list:
        if isinstance(item, list):
            for sub in flatten(item):
                yield sub
        else:
            yield item

elements = [UnwrapElement(e) for e in to_list(IN[0])]
```
