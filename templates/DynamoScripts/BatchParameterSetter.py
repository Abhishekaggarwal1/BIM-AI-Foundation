# -*- coding: utf-8 -*-
"""Batch Parameter Setter - BIM-AI-Foundation Dynamo Template
Inputs:
  IN[0]: List of Elements
  IN[1]: Parameter Name (string)
  IN[2]: Value to Set (string, number, or list of values)
Outputs:
  OUT[0]: Successfully updated element count
  OUT[1]: Error log list
"""

import clr
clr.AddReference('RevitAPI')
from Autodesk.Revit.DB import *

clr.AddReference('RevitServices')
from RevitServices.Persistence import DocumentManager
from RevitServices.Transactions import TransactionManager

doc = DocumentManager.Instance.CurrentDBDocument

def to_list(obj):
    if obj is None: return []
    return obj if isinstance(obj, list) else [obj]

raw_elements = to_list(IN[0])
param_name = str(IN[1]) if IN[1] is not None else ""
val_input = IN[2]

elements = [UnwrapElement(e) for e in raw_elements if e is not None]

# If val_input is a list, match 1-to-1 with elements; otherwise repeat value
if isinstance(val_input, list):
    values = val_input
else:
    values = [val_input] * len(elements)

success_count = 0
errors = []

TransactionManager.Instance.EnsureInTransaction(doc)
try:
    for elem, val in zip(elements, values):
        try:
            param = elem.LookupParameter(param_name)
            if param is None:
                errors.append("Element ID {}: Parameter '{}' not found".format(elem.Id.Value, param_name))
                continue
            if param.IsReadOnly:
                errors.append("Element ID {}: Parameter '{}' is read-only".format(elem.Id.Value, param_name))
                continue

            storage_type = param.StorageType
            if storage_type == StorageType.String:
                param.Set(str(val))
            elif storage_type == StorageType.Double:
                param.Set(float(val))
            elif storage_type == StorageType.Integer:
                param.Set(int(val))
            elif storage_type == StorageType.ElementId:
                param.Set(ElementId(int(val)))
            success_count += 1
        except Exception as ex:
            errors.append("Element ID {}: {}".format(elem.Id.Value, str(ex)))
finally:
    TransactionManager.Instance.TransactionTaskDone()

OUT = [success_count, errors]
