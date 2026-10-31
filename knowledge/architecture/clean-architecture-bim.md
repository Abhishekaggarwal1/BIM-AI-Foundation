# Clean Architecture for BIM Plugins
<!-- BIM-AI-Foundation | Architecture Reference -->

## 1. Why Clean Architecture in Revit Add-ins?
A common failure mode in Revit plugins is coupling UI, business logic, and Revit API calls into a single file or `IExternalCommand`. When Autodesk changes API methods or when testing logic, the entire plugin breaks.

```
┌────────────────────────────────────────────────────────┐
│ UI Layer (WPF, Views, Converters)                      │
│ - Zero Revit API calls. Binds to ViewModels only.      │
├────────────────────────────────────────────────────────┤
│ Application Layer (ViewModels, DTOs, Commands)         │
│ - Dispatches work to Services. Manages UI state.       │
├────────────────────────────────────────────────────────┤
│ Domain Layer (Pure Business Logic & Math)              │
│ - Completely decoupled from Autodesk.Revit.DB.        │
│ - 100% unit testable without running Revit!            │
├────────────────────────────────────────────────────────┤
│ Infrastructure Layer (Revit API Adapters)              │
│ - Implements IExternalCommand, IExternalApplication.  │
│ - FilteredElementCollector, Transactions, Geometry.    │
└────────────────────────────────────────────────────────┘
```

---

## 2. Directory Layout Convention

```
src/MyPlugin/
├── Commands/              # IExternalCommand entry points
│   └── AuditModelCommand.cs
├── Core/                  # Revit API interaction adapters
│   ├── RevitTask.cs       # STA thread dispatcher
│   ├── FailureHandler.cs  # Warning preprocessor
│   └── Collectors/        # Specific element queries
├── Domain/                # Pure business logic (POCOs, math, interfaces)
│   ├── Models/
│   └── Services/
├── UI/                    # Presentation
│   ├── Views/             # WPF Windows & Pages (.xaml & .xaml.cs)
│   └── ViewModels/        # CommunityToolkit.Mvvm ViewModels
└── App.cs                 # IExternalApplication (Ribbon & DI Bootstrap)
```
