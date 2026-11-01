---
name: openbim-ifc-processing
description: |
  Processing, validating, and extracting data from OpenBIM IFC (Industry Foundation Classes) files using IfcOpenShell (Python) and Xbim (C#).
  Use whenever user asks to parse IFC files, extract Property Sets (Psets), calculate quantities (Qto), validate IDS (Information Delivery Specifications), or automate OpenBIM workflows.
compatibility: IFC2X3, IFC4, IFC4.3 / Python 3.9+ (IfcOpenShell) / .NET 8 (Xbim).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# OpenBIM & IFC Processing Skill

OpenBIM relies on international standards (ISO 16739 IFC, ISO 19650, buildingSMART IDS) to exchange vendor-neutral BIM data.

---

## 1. IfcOpenShell Python Patterns

`ifcopenshell` is the standard open-source Python library for parsing and modifying IFC models.

### Basic Setup & Loading:
```python
import ifcopenshell
import ifcopenshell.util.element

# Load an IFC file (supports IFC2X3, IFC4, IFC4.3)
model = ifcopenshell.open("path/to/building.ifc")

# Extract schema version
schema = model.schema  # e.g., 'IFC4'
```

### 1.1 High-Speed Entity Queries:
```python
# Query by IFC Class
walls = model.by_type("IfcWall")
doors = model.by_type("IfcDoor")
spaces = model.by_type("IfcSpace")

# Filter by attribute
load_bearing_walls = [w for w in walls if w.PredefinedType == "SOLIDWALL"]
```

### 1.2 Extracting Property Sets (Psets) & Quantities (Qto):
Never parse raw `IfcRelDefinesByProperties` manually. Always use `ifcopenshell.util.element`:
```python
import ifcopenshell.util.element

for wall in walls:
    # Get all property sets as a clean Python dictionary:
    psets = ifcopenshell.util.element.get_psets(wall)
    
    # Access common pset:
    common = psets.get("Pset_WallCommon", {})
    is_external = common.get("IsExternal", False)
    fire_rating = common.get("FireRating", "N/A")
    
    # Access quantities:
    qto = psets.get("Qto_WallBaseQuantities", {})
    net_area = qto.get("NetSideArea", 0.0)
```

---

## 2. Information Delivery Specification (IDS) Validation

buildingSMART **IDS (Information Delivery Specification)** standardizes automated BIM compliance checking:
```python
import ifcopenshell
import ifcopenshell.validate

# Validate syntax against buildingSMART IFC schema
logger = ifcopenshell.validate.json_logger()
ifcopenshell.validate.validate("path/to/building.ifc", logger)

# Check compliance issues
issues = logger.statements
print(f"Total schema violations found: {len(issues)}")
```

---

## 3. Xbim (.NET / C#) High-Performance Processing

For C# developers processing gigabyte-scale IFC files:
```csharp
using Xbim.Ifc;
using Xbim.Ifc4.Interfaces;

using (var model = IfcStore.Open("building.ifc"))
{
    var walls = model.Instances.OfType<IIfcWall>();
    foreach (var wall in walls)
    {
        string name = wall.Name;
        string globalId = wall.GlobalId;
    }
}
```
