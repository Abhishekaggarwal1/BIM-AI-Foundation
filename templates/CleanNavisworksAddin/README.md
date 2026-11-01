# CleanNavisworksAddin Template

A production-ready template for building Autodesk Navisworks Manage & Simulate plugins.

---

## Features
- Implements `Autodesk.Navisworks.Api.Plugins.AddInPlugin`
- Demonstrates active document checking, clash detective querying, and selection retrieval.
- Ready for packaging into `%APPDATA%\Autodesk\ApplicationPlugins\` or Navisworks `Plugins/` folder.

---

## How to Build
```bash
dotnet build CleanNavisworksAddin.csproj -c Release
```
