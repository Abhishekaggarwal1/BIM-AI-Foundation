# OpenBIM & IFC Architectural Knowledge
<!-- BIM-AI-Foundation | Technical Reference -->

Industry Foundation Classes (IFC) is an open international standard (ISO 16739) managed by buildingSMART.

---

## 1. Schema Evolution & Compatibility

| Schema | Release Year | Primary Domain & Characteristics |
| :--- | :--- | :--- |
| **IFC2X3** | 2006 | Historic legacy standard still prevalent in legacy pipelines (Coordination View 2.0). |
| **IFC4** | 2013 | Modern architectural & MEP standard (Reference View / Design Transfer View). |
| **IFC4.3** | 2024 | Infrastructure expansion (Roads, Railways, Bridges, Ports, Tunnels). |

---

## 2. IFC Spatial Hierarchy Decomposition

Every valid IFC file follows a strict spatial tree:
```text
IfcProject
 └── IfcSite
      └── IfcBuilding
           └── IfcBuildingStorey
                ├── IfcSpace (Rooms / Zones)
                └── IfcProduct (Walls, Slabs, Beams, Columns, MEP)
```

Relationship: Connected via `IfcRelAggregates` and `IfcRelContainedInSpatialStructure`.

---

## 3. Property Sets & Classification Standards

* **Standard Psets:** Prefixed with `Pset_` (e.g., `Pset_WallCommon`, `Pset_DoorCommon`, `Pset_BeamCommon`).
* **Base Quantities:** Prefixed with `Qto_` (e.g., `Qto_WallBaseQuantities`, `Qto_DoorBaseQuantities`).
* **Classification:** Linked via `IfcRelAssociatesClassification` to reference Uniclass 2015, OmniClass, or MasterFormat.
