# pyRevit Architecture & Python Patterns for Revit
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. IronPython vs. CPython 3 Engine

pyRevit supports two Python execution engines:
* **IronPython 2.7 (Default):** Runs directly on the .NET CLR, with direct access to .NET types and Revit API assemblies without interop overhead.
* **CPython 3 (via Python.NET):** Enables modern Python 3 libraries (`numpy`, `pandas`, `requests`). Enabled by adding `#! python3` as the first line of `script.py`.

---

## 2. Core pyRevit Modules

```python
from pyrevit import revit, DB, UI, forms, script

# Document Handles
doc = revit.doc          # Active Autodesk.Revit.DB.Document
uidoc = revit.uidoc      # Active Autodesk.Revit.UI.UIDocument
app = revit.app          # Active Autodesk.Revit.ApplicationServices.Application

# Script Output & Logger
output = script.get_output()
logger = script.get_logger()
```

---

## 3. High-Speed Element Queries in Python

Never use slow Python list comprehensions over unfiltered collections. Always let the Revit C++ core filter elements before marshalling to Python:

```python
# ⚡ FAST: Natively filtered at the database level
door_instances = (
    DB.FilteredElementCollector(doc)
    .OfClass(DB.FamilyInstance)
    .OfCategory(DB.BuiltInCategory.OST_Doors)
    .WhereElementIsNotElementType()
    .ToElements()
)

# 🐢 SLOW ANTI-PATTERN (Avoid):
# all_elements = DB.FilteredElementCollector(doc).ToElements()
# doors = [e for e in all_elements if "Door" in e.Category.Name]
```

---

## 4. Parameter Management in Python

```python
# Reading Parameters
param = element.get_Parameter(DB.BuiltInParameter.ALL_MODEL_MARK)
if param and param.HasValue:
    mark_value = param.AsString()

# Writing Parameters (Must be inside a Transaction)
with revit.Transaction("Update Mark"):
    param.Set("D-101")

# Converting Units (e.g., millimeters to internal feet)
length_in_mm = 1500.0
internal_feet = DB.UnitUtils.ConvertToInternalUnits(
    length_in_mm, 
    DB.UnitTypeId.Millimeters
)
```

---

## 5. Rapid UI with `pyrevit.forms`

pyRevit provides built-in dialogs without requiring custom XAML:

```python
from pyrevit import forms

# 1. Alert / Confirmation
forms.alert("Operation completed successfully!", title="Success")

# 2. String Input
project_code = forms.ask_for_string(prompt="Enter Project Code:", title="Setup")

# 3. Select From List (with search/filter)
levels = DB.FilteredElementCollector(doc).OfClass(DB.Level).ToElements()
selected_level = forms.SelectFromList.show(
    [l.Name for l in levels],
    title="Select Level",
    multiselect=False
)

# 4. Progress Bar for Batch Operations
with forms.ProgressBar(title="Processing Elements ({value} of {max_value})") as pb:
    for i, elem in enumerate(door_instances):
        # Do work...
        pb.update_progress(i + 1, len(door_instances))
```
