# -*- coding: utf-8 -*-
"""Wall Joiner Tool - BIM-AI-Foundation pyRevit Template
Automatically joins intersecting walls in the active view within a safe transaction.
"""

from pyrevit import revit, DB, forms, script

doc = revit.doc
uidoc = revit.uidoc
logger = script.get_logger()

def main():
    # 1. Native Revit Quick Filter (high performance)
    walls = (
        DB.FilteredElementCollector(doc, doc.ActiveView.Id)
        .OfClass(DB.Wall)
        .WhereElementIsNotElementType()
        .ToElements()
    )

    if not walls or len(walls) < 2:
        forms.alert("Need at least 2 walls in the active view to join.", title="Wall Joiner")
        return

    joined_count = 0

    # 2. Wrap modifications in a pyRevit Transaction
    with revit.Transaction("Automated Wall Join"):
        for i, wall_a in enumerate(walls):
            for wall_b in walls[i + 1:]:
                try:
                    # Check if already joined to avoid unnecessary operations
                    if not DB.JoinGeometryUtils.AreElementsJoined(doc, wall_a, wall_b):
                        DB.JoinGeometryUtils.JoinGeometry(doc, wall_a, wall_b)
                        joined_count += 1
                except Exception:
                    # Swallow non-intersecting or unjoinable geometry
                    pass

    forms.alert(
        "Finished processing.\nSuccessfully joined {} intersecting wall pairs.".format(joined_count),
        title="Wall Joiner Success"
    )

if __name__ == '__main__':
    main()
