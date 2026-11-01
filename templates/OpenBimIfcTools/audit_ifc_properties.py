# -*- coding: utf-8 -*-
"""IFC Property Auditor - BIM-AI-Foundation OpenBIM Template
Audits an IFC model for element counts and missing property sets.
"""

import sys
import ifcopenshell
import ifcopenshell.util.element

def audit_ifc(file_path):
    print(f"Loading IFC model: {file_path}")
    model = ifcopenshell.open(file_path)
    print(f"Schema: {model.schema}")

    walls = model.by_type("IfcWall")
    doors = model.by_type("IfcDoor")
    spaces = model.by_type("IfcSpace")

    print("\n--- Spatial Element Breakdown ---")
    print(f"Total Walls: {len(walls)}")
    print(f"Total Doors: {len(doors)}")
    print(f"Total Spaces: {len(spaces)}")

    # Audit Walls for FireRating
    unrated_walls = 0
    for wall in walls:
        psets = ifcopenshell.util.element.get_psets(wall)
        common = psets.get("Pset_WallCommon", {})
        fire_rating = common.get("FireRating")
        if not fire_rating or str(fire_rating).strip() == "":
            unrated_walls += 1

    print("\n--- Compliance Audit ---")
    print(f"Walls missing Pset_WallCommon.FireRating: {unrated_walls} of {len(walls)}")

if __name__ == '__main__':
    if len(sys.argv) > 1:
        audit_ifc(sys.argv[1])
    else:
        print("Usage: python audit_ifc_properties.py <path-to-model.ifc>")
