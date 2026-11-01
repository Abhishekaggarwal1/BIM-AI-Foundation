# -*- coding: utf-8 -*-
"""Room Audit Script - BIM-AI-Foundation Dynamo Template
Outputs:
  OUT[0]: List of Placed Rooms
  OUT[1]: List of Unplaced Rooms
  OUT[2]: List of Redundant/Unenclosed Rooms
"""

import clr
clr.AddReference('RevitAPI')
from Autodesk.Revit.DB import *

clr.AddReference('RevitServices')
from RevitServices.Persistence import DocumentManager

clr.AddReference('RevitNodes')
import Revit
clr.ImportExtensions(Revit.Elements)

doc = DocumentManager.Instance.CurrentDBDocument

collector = (
    FilteredElementCollector(doc)
    .OfCategory(BuiltInCategory.OST_Rooms)
    .WhereElementIsNotElementType()
    .ToElements()
)

placed_rooms = []
unplaced_rooms = []
redundant_rooms = []

for room in collector:
    # Wrap elements back to Dynamo elements for downstream nodes
    dynamo_room = room.ToDSType(isRevitOwned=True)

    if room.Location is None:
        unplaced_rooms.append(dynamo_room)
    elif room.Area <= 0.0:
        redundant_rooms.append(dynamo_room)
    else:
        placed_rooms.append(dynamo_room)

OUT = [placed_rooms, unplaced_rooms, redundant_rooms]
