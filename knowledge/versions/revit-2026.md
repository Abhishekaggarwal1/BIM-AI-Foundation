# Revit 2026 API Specifics
<!-- BIM-AI-Foundation | Version Reference -->

## 1. Runtime Environment
* **Target Runtime:** **.NET 8.0 (.NET Core)** (`net8.0-windows`)
* **Project Format:** Modern SDK-style `.csproj`

## 2. Key Enhancements & Additions
* **Advanced Toposolid Subdivision:** APIs for programmatic boundary subdivision, contour point manipulation, and excavation volume calculation.
* **Cloud Collaboration APIs:** Enhanced endpoints for Autodesk Construction Cloud (ACC) coordination and linked cloud models.
* **Performance Enhancements:** Improved high-speed element iteration in large multidisciplinary models.

## 3. MSBuild Target Definition:
```xml
<PropertyGroup Condition="'$(Configuration)' == 'Release R26'">
  <TargetFramework>net8.0-windows</TargetFramework>
  <DefineConstants>REVIT2026;REVIT2025_OR_GREATER;REVIT2026_OR_GREATER;NET8_0_OR_GREATER</DefineConstants>
</PropertyGroup>
```
