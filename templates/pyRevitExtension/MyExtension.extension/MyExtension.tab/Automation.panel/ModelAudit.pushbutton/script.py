# -*- coding: utf-8 -*-
"""Model Audit Tool - BIM-AI-Foundation pyRevit Template
Scans the active document for common BIM health issues.
"""

from pyrevit import revit, DB, forms, script

doc = revit.doc
output = script.get_output()
logger = script.get_logger()

def audit_rooms():
    """Finds unplaced and redundant rooms."""
    collector = (
        DB.FilteredElementCollector(doc)
        .OfCategory(DB.BuiltInCategory.OST_Rooms)
        .WhereElementIsNotElementType()
        .ToElements()
    )
    
    unplaced = []
    redundant = []
    placed = 0

    for room in collector:
        # Check if room is placed in model
        if room.Location is None:
            unplaced.append(room)
        elif room.Area <= 0.0:
            redundant.append(room)
        else:
            placed += 1

    return placed, unplaced, redundant

def main():
    output.print_md("# BIM Model Health Audit Report")
    output.print_md("**Document:** `{}`".format(doc.Title))
    
    placed, unplaced, redundant = audit_rooms()
    
    output.print_md("---")
    output.print_md("### 1. Room Placement Status")
    output.print_md("- **Placed Rooms:** {}".format(placed))
    output.print_md("- **Unplaced Rooms:** {}".format(len(unplaced)))
    output.print_md("- **Redundant/Unenclosed Rooms:** {}".format(len(redundant)))

    if unplaced:
        output.print_md("#### Unplaced Room List:")
        for r in unplaced:
            # Uses Revit 2024+ 64-bit ElementId.Value
            output.print_md("  - Room ID `{}`, Name: `{}`".format(r.Id.Value, r.get_Parameter(DB.BuiltInParameter.ROOM_NAME).AsString()))

    if not unplaced and not redundant:
        forms.alert("Model audit passed with zero room issues!", title="Audit Clean")
    else:
        forms.alert(
            "Audit complete:\n- {} Unplaced rooms\n- {} Redundant rooms\n\nSee output window for details.".format(
                len(unplaced), len(redundant)
            ),
            title="Audit Report"
        )

if __name__ == '__main__':
    main()
