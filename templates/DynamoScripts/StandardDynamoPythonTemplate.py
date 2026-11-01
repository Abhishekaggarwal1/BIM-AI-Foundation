# -*- coding: utf-8 -*-
"""Standard Dynamo Python Template - BIM-AI-Foundation
Compatibility: Dynamo 2.x - 3.x / Revit 2024-2026 (CPython 3 & IronPython 2)
"""

import clr

# Reference Revit API
clr.AddReference('RevitAPI')
from Autodesk.Revit.DB import *

# Reference RevitServices
clr.AddReference('RevitServices')
from RevitServices.Persistence import DocumentManager
from RevitServices.Transactions import TransactionManager

# Reference Dynamo Nodes & Geometry interop
clr.AddReference('RevitNodes')
import Revit
clr.ImportExtensions(Revit.Elements)
clr.ImportExtensions(Revit.GeometryConversion)

# Document handles
doc = DocumentManager.Instance.CurrentDBDocument
uiapp = DocumentManager.Instance.CurrentUIApplication
app = uiapp.Application

def to_list(obj):
    """Safely normalizes single objects and lists."""
    if obj is None: return []
    return obj if isinstance(obj, list) else [obj]

# Inputs
input_items = to_list(IN[0])

# Unwrap elements to native Revit DB objects
elements = [UnwrapElement(e) for e in input_items if e is not None]

output_data = []

# Optional: Transaction handling (only if modifying model database)
TransactionManager.Instance.EnsureInTransaction(doc)
try:
    for elem in elements:
        # Example: element logic here
        output_data.append(elem.Id.Value)
finally:
    TransactionManager.Instance.TransactionTaskDone()

# Assign output to Dynamo OUT port
OUT = output_data
