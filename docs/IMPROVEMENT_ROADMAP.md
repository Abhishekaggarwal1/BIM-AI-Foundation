# BIM-AI-Foundation: Technical Improvement Roadmap
<!-- Prioritized Evolution & Enhancement Strategy -->

This roadmap outlines prioritized recommendations to ensure **BIM-AI-Foundation** remains the industry standard for AI-assisted AEC software development.

---

## 1. Priority 1: Must Fix (Completed During Audit)

- [x] **Fix AutoCAD.NET NuGet Package Version:** Upgraded to `25.1.0` so AutoCAD projects restore and compile out-of-the-box.
- [x] **Restructure Navisworks Template:** Adopted Clean Architecture (`src/CleanNavisworksAddin/`), added `.sln`, integrated `Chuongmep.Navis.Api`, and isolated skill files with `<Compile Remove="skills\**" />`.
- [x] **PowerShell 7 Shim (`pwsh.cmd`):** Added a shim so standard Windows systems without PowerShell 7 can run CLI commands without errors.
- [x] **CLI `init` Directory Pre-Creation:** Ensured `Invoke-Init` creates the target folder if it does not already exist.
- [x] **Correct Repository URL in README:** Updated README URLs to `https://github.com/Abhishekaggarwal1/BIM-AI-Foundation`.
- [x] **Comprehensive CI/CD Pipeline:** Enhanced `.github/workflows/ci.yml` to build all Revit versions (2024–2026), AutoCAD, Navisworks, and validate Python syntax.

---

## 2. Priority 2: Should Improve (Recommended Next Steps)

1. **Decoupled Unit Testing Project Template:**
   - Add a pre-configured unit test project template (`templates/CleanRevitAddin/tests/CleanRevitAddin.Tests`) referencing xUnit and demonstrating pure domain testing decoupled from the Revit API.
2. **CLI Cross-Platform Shell Script Enhancement:**
   - Expand `cli/bim-ai.sh` to provide native bash scaffolding on macOS / Linux without requiring PowerShell.
3. **Automated Roslyn Analyzer for Revit Invariants:**
   - Package the checks currently in `bim-ai.ps1 validate` into a custom Roslyn Analyzer (`BIM.AI.Analyzers.dll`). This enables real-time squiggly warnings in Visual Studio and Cursor for STA threading and obsolete parameter APIs as the developer or AI types.
4. **Enhanced Civil 3D Template:**
   - Introduce a dedicated template (`templates/CleanCivil3DAddin`) using `Autodesk.Civil.3D.NET` NuGet packages to match the AutoCAD and Navisworks templates.

---

## 3. Priority 3: Optional Future Development

1. **Tekla Structures Open API Integration:**
   - Scaffold templates and skills for Tekla Structures C# plugins (`Tekla.Structures.Model`).
2. **Rhino.Inside.Revit Zero-Touch Node Scaffolder:**
   - Provide a template for authoring custom Grasshopper components that query and manipulate Revit models.
3. **Headless Cloud Worker via APS Design Automation:**
   - Add sample bundles and automation scripts for running add-ins in Autodesk Platform Services (APS) Design Automation for Revit.
4. **Interactive Skill Discovery Assistant:**
   - Add an interactive terminal command (`bim-ai.ps1 search <query>`) that queries skill descriptions and outputs the best matching skill for a given task.

