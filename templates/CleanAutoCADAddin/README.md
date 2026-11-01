# CleanAutoCADAddin Template

A production-ready, multi-version template for building Autodesk AutoCAD .NET plugins targeting **AutoCAD 2024 (.NET Framework 4.8)** and **AutoCAD 2025/2026 (.NET 8.0 Core)** from a single unified codebase.

---

## Features
- **Multi-Targeting:** Builds for `net48` and `net8.0-windows`.
- **Autodesk Autoloader:** Includes `PackageContents.xml` for zero-install deployment into `%APPDATA%\Autodesk\ApplicationPlugins\`.
- **STA Thread Safety:** Demonstrates `DocumentLock` and scoped `Transaction` usage.
- **Sample Commands:**
  - `BIM_DRAWGRID`: Prompts for spacing and draws an automated grid in ModelSpace.
  - `BIM_AUDITLAYERS`: Lists all active layers and entity counts.

---

## How to Build:
```bash
# Build all target frameworks:
dotnet build CleanAutoCADAddin.sln

# Target AutoCAD 2024 (.NET 4.8):
dotnet build -f net48

# Target AutoCAD 2025/2026 (.NET 8.0):
dotnet build -f net8.0-windows
```
