---
name: revit-pyrevit-extension
description: |
  Developing Python scripts, tools, and custom Ribbon buttons for pyRevit extensions.
  Use whenever user asks to write Python scripts for Revit, create pyRevit buttons (.pushbutton), or build pyRevit extensions.
compatibility: pyRevit 4.8+ / Revit 2024-2026 (IronPython and CPython 3).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# pyRevit Extension & Python Scripting Skill

pyRevit allows developers to build custom Revit tools and ribbon buttons entirely in **Python** without compiling C# `.dll` files.

---

## 1. pyRevit Folder Hierarchy

pyRevit automatically generates Ribbon Tabs, Panels, and Buttons based on directory naming conventions:

```text
MyTools.extension/
└── MyTools.tab/
    └── Automation.panel/
        ├── WallJoiner.pushbutton/
        │   ├── script.py          # Python execution logic
        │   ├── bundle.yaml        # Title, tooltip, author metadata
        │   └── icon.png           # 32x32 button icon
        └── BatchRenamer.pushbutton/
            ├── script.py
            └── icon.png
```

### Bundle Types:
* `.pushbutton` : Standard push button.
* `.pulldown`   : Dropdown menu containing push buttons.
* `.splitbutton`: Split button with default action and dropdown list.

---

## 2. Standard `bundle.yaml` Configuration

Create `bundle.yaml` inside each `.pushbutton` folder:

```yaml
title: "Wall\nJoiner"
tooltip: "Automatically joins intersecting walls and swallows geometry warnings."
author: "BIM-AI-Foundation"
context: doc-project
```

---

## 3. Standard `script.py` Template

```python
# -*- coding: utf-8 -*-
"""Automatically joins intersecting walls in the active view."""

from pyrevit import revit, DB, forms, script

# Active document and UI handles
doc = revit.doc
uidoc = revit.uidoc
logger = script.get_logger()

def main():
    # 1. Collect walls using native Revit Quick Filters (fast)
    walls = (
        DB.FilteredElementCollector(doc, doc.ActiveView.Id)
        .OfClass(DB.Wall)
        .WhereElementIsNotElementType()
        .ToElements()
    )

    if not walls:
        forms.alert("No walls found in the active view.", title="Wall Joiner")
        return

    # 2. Wrap modifications in a pyRevit Transaction
    with revit.Transaction("Automated Wall Join"):
        joined_count = 0
        for i, wall_a in enumerate(walls):
            for wall_b in walls[i + 1:]:
                try:
                    DB.JoinGeometryUtils.JoinGeometry(doc, wall_a, wall_b)
                    joined_count += 1
                except Exception:
                    # Ignore elements that cannot join or are already joined
                    pass

    # 3. User feedback
    forms.alert(
        "Successfully joined {} wall intersections.".format(joined_count),
        title="Wall Joiner Success"
    )

if __name__ == '__main__':
    main()
```

---

## 4. Key pyRevit Rules & Gotchas

1. **Transaction Scope:** Always use `with revit.Transaction("Action Name"):` for any model change. Read-only queries must NOT open a transaction.
2. **Revit API Access via `DB`:** All native Revit API classes (`DB.XYZ`, `DB.FilteredElementCollector`, `DB.UnitUtils`, `DB.ElementId`) are accessible via `from pyrevit import DB`.
3. **ElementId in Revit 2024+:**
   - In Python, `element.Id.Value` returns a 64-bit `long`.
   - Never convert to 32-bit `int` or use `IntegerValue`.
4. **Units & ForgeTypeId:**
   - Convert internal imperial feet to metric using `DB.UnitUtils.ConvertFromInternalUnits(val, DB.UnitTypeId.Millimeters)`.
5. **Interactive UI Popups:** Use `forms.SelectFromList`, `forms.ask_for_string`, and `forms.alert` for rapid user input without writing custom WPF XAML.
