---
name: revit-plugin-scaffold
description: |
  Scaffolds a modern, production-grade Autodesk Revit C# plugin multi-targeting Revit 2024, 2025, and 2026.
  Use whenever creating a new Revit add-in, generating .csproj files, authoring .addin manifests, or setting up Ribbon UI.
compatibility: Requires .NET 8.0 SDK. Targets net48 (Revit 2024) and net8.0-windows (Revit 2025-2026).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Plugin Scaffold Skill

Follow these steps to create a clean, multi-version Revit add-in using SDK-style projects and Nice3point NuGet references.

## Step 1: SDK-Style `.csproj` Configuration

Create `<ProjectName>.csproj` with multi-targeting:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <UseWPF>true</UseWPF>
    <UseWindowsForms>true</UseWindowsForms>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <Configurations>Debug R24;Debug R25;Debug R26;Release R24;Release R25;Release R26</Configurations>
    <Configurations>$(Configurations);Debug;Release</Configurations>
  </PropertyGroup>

  <!-- Revit 2024 (.NET Framework 4.8) -->
  <PropertyGroup Condition="$(Configuration.Contains('R24'))">
    <TargetFramework>net48</TargetFramework>
    <DefineConstants>REVIT2024</DefineConstants>
    <RevitVersion>2024</RevitVersion>
  </PropertyGroup>

  <!-- Revit 2025 (.NET 8.0) -->
  <PropertyGroup Condition="$(Configuration.Contains('R25'))">
    <TargetFramework>net8.0-windows</TargetFramework>
    <DefineConstants>REVIT2025;REVIT2025_OR_GREATER;NET8_0_OR_GREATER</DefineConstants>
    <RevitVersion>2025</RevitVersion>
  </PropertyGroup>

  <!-- Revit 2026 (.NET 8.0) -->
  <PropertyGroup Condition="$(Configuration.Contains('R26'))">
    <TargetFramework>net8.0-windows</TargetFramework>
    <DefineConstants>REVIT2026;REVIT2025_OR_GREATER;REVIT2026_OR_GREATER;NET8_0_OR_GREATER</DefineConstants>
    <RevitVersion>2026</RevitVersion>
  </PropertyGroup>

  <!-- Fallback Default for IDE testing -->
  <PropertyGroup Condition="!$(Configuration.Contains('R24')) and !$(Configuration.Contains('R25')) and !$(Configuration.Contains('R26'))">
    <TargetFramework>net8.0-windows</TargetFramework>
    <DefineConstants>REVIT2025;REVIT2025_OR_GREATER;NET8_0_OR_GREATER</DefineConstants>
    <RevitVersion>2025</RevitVersion>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Nice3point.Revit.Build.Tasks" Version="2.0.*" />
    <PackageReference Include="Nice3point.Revit.Api.RevitAPI" Version="$(RevitVersion).*" />
    <PackageReference Include="Nice3point.Revit.Api.RevitAPIUI" Version="$(RevitVersion).*" />
    <PackageReference Include="CommunityToolkit.Mvvm" Version="8.2.*" />
  </ItemGroup>
</Project>
```

---

## Step 2: The `.addin` Manifest File

Create `<ProjectName>.addin` in the project root:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RevitAddIns>
  <AddIn Type="Application">
    <Name>$(ProjectName)</Name>
    <Assembly>$(ProjectName).dll</Assembly>
    <AddInId>A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D</AddInId>
    <FullClassName>$(RootNamespace).App</FullClassName>
    <VendorId>BIMFoundation</VendorId>
    <VendorDescription>BIM-AI-Foundation Open-Source Initiative</VendorDescription>
  </AddIn>
</RevitAddIns>
```

---

## Step 3: Implement `App.cs` (`IExternalApplication`)

```csharp
using Autodesk.Revit.UI;
using System.Reflection;

namespace MyPlugin;

public class App : IExternalApplication
{
    public Result OnStartup(UIControlledApplication application)
    {
        string tabName = "BIM Tools";
        try { application.CreateRibbonTab(tabName); } catch { }

        RibbonPanel panel = application.CreateRibbonPanel(tabName, "General");
        string location = Assembly.GetExecutingAssembly().Location;

        var buttonData = new PushButtonData(
            "cmdMain",
            "Open Tool",
            location,
            "MyPlugin.Commands.MainCommand"
        )
        {
            ToolTip = "Launches the main plugin interface"
        };

        panel.AddItem(buttonData);
        return Result.Succeeded;
    }

    public Result OnShutdown(UIControlledApplication application) => Result.Succeeded;
}
```
