# Knowledge Base Index & Semantic Map
<!-- BIM-AI-Foundation | High-Density Token-Optimized Knowledge Index -->

Use this index to quickly locate specific technical documentation and examples. Only read the targeted document required for your task.

---

## 1. Core Revit API Knowledge (`knowledge/revit-api/`)

| Topic | Document Path | Key Concepts Covered |
| :--- | :--- | :--- |
| **Threading & Async** | [`revit-api/threading-and-async.md`](revit-api/threading-and-async.md) | STA main thread, `IExternalEventHandler`, `ExternalEvent`, `RevitTask`, thread context switching |
| **Transactions & Failures** | [`revit-api/transactions-and-failures.md`](revit-api/transactions-and-failures.md) | `Transaction`, `SubTransaction`, `TransactionGroup`, `IFailuresPreprocessor`, warning suppression, rollback |
| **Element Filtering** | [`revit-api/element-filtering.md`](revit-api/element-filtering.md) | `FilteredElementCollector`, quick vs slow filters, bounding box, inverted filters, LINQ optimization |
| **Parameters & Units** | [`revit-api/parameters-and-units.md`](revit-api/parameters-and-units.md) | `ForgeTypeId`, `SpecTypeId`, `UnitTypeId`, `UnitUtils`, `StorageType`, shared parameters |
| **Geometry & Solids** | [`revit-api/geometry-and-solids.md`](revit-api/geometry-and-solids.md) | `GeometryElement`, `Solid`, `Face`, `Edge`, `BooleanOperationsUtils`, `ReferenceIntersector` ray casting |
| **Families & Types** | [`revit-api/family-and-types.md`](revit-api/family-and-types.md) | `FamilySymbol`, `FamilyInstance`, `IFamilyLoadOptions`, activating symbols, type vs instance |
| **Ribbon UI & Dockable Panels** | [`revit-api/ui-ribbon-dockable.md`](revit-api/ui-ribbon-dockable.md) | `RibbonPanel`, `PushButton`, `SplitButton`, `DockablePane`, `IDockablePaneProvider`, WPF MVVM |
| **Extensible Storage** | [`revit-api/extensible-storage.md`](revit-api/extensible-storage.md) | `SchemaBuilder`, `FieldBuilder`, `Entity`, `DataStorage`, GUID management, access permissions |
| **pyRevit & Python Patterns** | [`revit-api/pyrevit-patterns.md`](revit-api/pyrevit-patterns.md) | pyRevit extensions, `.pushbutton`, `bundle.yaml`, `forms` dialogs, IronPython & CPython 3 |
| **Dynamo Python & Nodes** | [`revit-api/dynamo-python-patterns.md`](revit-api/dynamo-python-patterns.md) | Dynamo Python nodes, `RevitServices`, `TransactionManager`, `UnwrapElement`, geometry interop |

---

## 2. AutoCAD & Infrastructure Knowledge (`knowledge/autocad/` & `knowledge/civil3d/`)

| Topic | Document Path | Key Concepts Covered |
| :--- | :--- | :--- |
| **AutoCAD .NET & LISP** | [`autocad/autocad-api-architecture.md`](autocad/autocad-api-architecture.md) | `DocumentLock`, `TransactionManager`, `BlockTableRecord`, ModelSpace, `OpenMode`, AutoLISP |
| **Civil 3D Infrastructure** | [`civil3d/civil3d-api-architecture.md`](civil3d/civil3d-api-architecture.md) | `CivilDocument`, Alignments, Profiles, TIN Surfaces, Corridors, Station/Offset |

---

## 3. Coordination & OpenBIM Knowledge (`knowledge/navisworks/` & `knowledge/openbim/`)

| Topic | Document Path | Key Concepts Covered |
| :--- | :--- | :--- |
| **Navisworks Clash & API** | [`navisworks/navisworks-api-architecture.md`](navisworks/navisworks-api-architecture.md) | `ClashTest`, `DocumentClash`, `ModelItem`, SelectionSets, Viewpoints |
| **OpenBIM & IFC** | [`openbim/openbim-ifc-patterns.md`](openbim/openbim-ifc-patterns.md) | IfcOpenShell, Xbim, Pset/Qto extraction, IDS compliance validation |
| **Rhino.Inside.Revit** | [`computational-design/rhino-inside-revit.md`](computational-design/rhino-inside-revit.md) | RhinoCommon to Revit interop, Brep conversion, Grasshopper pipelines |

---

## 3. Version Breaking Changes & Migration (`knowledge/versions/`)

| Document Path | Description |
| :--- | :--- |
| [`breaking-changes-matrix.md`](breaking-changes-matrix.md) | Comprehensive side-by-side comparison for Revit 2024 vs 2025 vs 2026 |
| [`versions/revit-2024.md`](versions/revit-2024.md) | .NET 4.8 runtime, `ElementId.Value` (Int64), introduction of Toposolid API |
| [`versions/revit-2025.md`](versions/revit-2025.md) | **Major .NET 8.0 migration**, `AssemblyLoadContext`, `FindParameter()`, Dark Theme UI |
| [`versions/revit-2026.md`](versions/revit-2026.md) | .NET 8.0 enhancements, Toposolid subdivide APIs, cloud coordination endpoints |

---

## 4. Architecture & Patterns (`knowledge/architecture/`)

| Document Path | Description |
| :--- | :--- |
| [`architecture/clean-architecture-bim.md`](architecture/clean-architecture-bim.md) | Separation of Domain, Application, and Revit Infrastructure layers |
| [`architecture/mvvm-in-revit.md`](architecture/mvvm-in-revit.md) | `CommunityToolkit.Mvvm` integration with WPF, window parenting, theme sync |
| [`architecture/dependency-injection.md`](architecture/dependency-injection.md) | Managing `IServiceProvider` lifecycle inside `IExternalApplication` |
