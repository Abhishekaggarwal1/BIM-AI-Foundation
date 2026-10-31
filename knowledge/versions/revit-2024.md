# Revit 2024 API Specifics
<!-- BIM-AI-Foundation | Version Reference -->

## 1. Runtime Environment
* **Target Runtime:** .NET Framework 4.8 (`net48`)
* **Project Format:** SDK-style `.csproj` targeting `net48` (with `Microsoft.NET.Sdk` and Windows Desktop target)
* **API Assembly Path:** `C:\Program Files\Autodesk\Revit 2024\RevitAPI.dll`

## 2. Major Features & Breaking Changes
* **`ElementId.Value` (Int64):** `ElementId.IntegerValue` marked obsolete. Always use `ElementId.Value` (`long`).
* **Toposolid API:** Introduction of `Toposolid` element category, replacing `TopographySurface`. `Toposolid.Create()` creates modern solid site geometry with layers.
* **ForgeTypeId Integration:** Full deprecation of older unit enums.
* **Analytical Automation:** Structural analytical elements are completely decoupled from physical geometry.

## 3. MSBuild Target Definition:
```xml
<PropertyGroup Condition="'$(Configuration)' == 'Release R24'">
  <TargetFramework>net48</TargetFramework>
  <DefineConstants>REVIT2024</DefineConstants>
</PropertyGroup>
```
