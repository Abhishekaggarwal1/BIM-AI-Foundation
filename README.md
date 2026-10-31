# BIM-AI-Foundation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Revit: 2024-2026](https://img.shields.io/badge/Autodesk%20Revit-2024%20%7C%202025%20%7C%202026-blue.svg)](https://www.autodesk.com/products/revit)
[![.NET: 4.8 | 8.0](https://img.shields.io/badge/.NET-Framework%204.8%20%7C%208.0-purple.svg)](https://dotnet.microsoft.com/)
[![Standard: AGENTS.md](https://img.shields.io/badge/Standard-AGENTS.md%20%7C%20Agent%20Skills-green.svg)](https://agentskills.io)

**BIM-AI-Foundation** is an open-source development and knowledge framework for AI-assisted Building Information Modeling (BIM) software development.

It eliminates the need for developers to repeatedly explain BIM concepts, Revit API quirks, threading models, transaction lifecycles, and version breaking changes to AI coding assistants (Claude Code, Cursor, GitHub Copilot, OpenAI Codex, Antigravity) every time they build a new plugin.

---

## 🚀 The Problem & The Solution

```
THE CURRENT STRUGGLE (WITHOUT FOUNDATION):
Developer: "Create a Revit plugin to audit unplaced rooms"
AI Assistant:
 ❌ Calls Revit API from Task.Run()            --> HARD REVIT CRASH (STA Thread Violation)
 ❌ Forgets to wrap in using (Transaction)     --> DATABASE LOCK / CRASH
 ❌ Uses obsolete ElementId.IntegerValue        --> OVERFLOW ERROR on large projects
 ❌ Uses deprecated ParameterType enum          --> COMPILATION FAILURE in Revit 2024+
 ❌ Targets .NET 4.8 for Revit 2025            --> DLL FAILS TO LOAD (Revit 2025 runs .NET 8)
 Token Cost: 80,000+ tokens spent debugging and pasting documentation.

WITH BIM-AI-FOUNDATION:
Developer clones or installs BIM-AI-Foundation.
AI Assistant:
 ✔ Reads AGENTS.md and relevant skills/ on demand (< 3,000 tokens)
 ✔ Strictly respects the Single-Threaded Apartment (STA) model via RevitTask
 ✔ Scopes Transactions cleanly with IFailuresPreprocessor warning swallowers
 ✔ Correctly targets .NET Framework 4.8 (Revit 2024) and .NET 8.0 (Revit 2025-2026)
 ✔ Generates clean, production-grade, compile-ready code on the FIRST turn!
```

---

## ⚡ Key Features

1. **Master AI Instructions:** Root instructions (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/*.mdc`, `.github/copilot-instructions.md`) establishing non-negotiable Revit API constraints.
2. **Modular Agent Skills (`agentskills.io` standard):** Task-specific procedural recipes that AI assistants load dynamically on-demand, reducing prompt token bloat by **85–90%**. Supports both **C# .NET Plugins** and **pyRevit Python Extensions**.
3. **Revit 2024–2026 Version Breaking Change Matrix:** Accurate guidance on the historic .NET Framework 4.8 to .NET 8.0 migration in Revit 2025, `ElementId.Value` (Int64), and `ForgeTypeId`.
4. **Multi-Targeted C# Project Template:** Production-tested Clean Architecture template (`templates/CleanRevitAddin`) compiling for Revit 2024, 2025, and 2026 from a single codebase via `Nice3point.Revit.Build.Tasks`.
5. **pyRevit Extension & Python Scripting Support:** Native support for pyRevit extensions (`.extension`), tabs, panels, `.pushbutton` directories, `bundle.yaml`, and `pyrevit.forms` dialogs.
6. **Multi-AI Compatibility:** Instant out-of-the-box support for Claude Code, Cursor IDE, GitHub Copilot, Windsurf, and OpenAI Codex.
7. **Developer CLI (`cli/bim-ai.ps1`):** A command-line tool to initialize existing repositories, scaffold new add-ins, and validate C# code for Revit anti-patterns.

---

## 📂 Repository Structure

```text
BIM-AI-Foundation/
├── AGENTS.md                          # Primary open standard master instructions
├── CLAUDE.md                          # Claude Code instructions
├── .cursorrules                       # Legacy Cursor instructions fallback
├── .windsurfrules                     # Windsurf IDE instructions
├── .cursor/rules/                     # Modern Cursor modular rules (.mdc)
│   ├── revit-core.mdc                 # Core STA threading & transaction invariants
│   ├── revit-versions.mdc             # Version-specific guidelines (.NET 4.8 vs .NET 8)
│   ├── revit-architecture.mdc         # Clean Architecture & MVVM guidelines
│   └── bim-skills-router.mdc          # Progressive disclosure skill router
├── .github/copilot-instructions.md    # GitHub Copilot workspace instructions
├── docs/                              # Framework documentation
│   ├── ARCHITECTURE.md                # System design & how AI integration works
│   ├── TOKEN_OPTIMIZATION.md          # Benchmark & token reduction report
│   └── MULTI_AI_GUIDE.md              # How to configure Cursor, Claude Code, Copilot
├── knowledge/                         # Technical knowledge base
│   ├── INDEX.md                       # High-density knowledge retrieval index
│   ├── breaking-changes-matrix.md     # 2024 vs 2025 vs 2026 breaking changes matrix
│   ├── revit-api/                     # Deep dives (threading, transactions, pyrevit, geometry)
│   ├── versions/                      # Revit 2024, 2025, 2026 specifics
│   └── architecture/                  # Clean Architecture, MVVM, and DI
├── skills/                            # Agent Skills specification (agentskills.io)
│   ├── revit-plugin-scaffold/         # Scaffolding modern multi-version C# addins
│   ├── revit-pyrevit-extension/       # pyRevit extensions, Python ribbon buttons, bundle.yaml
│   ├── revit-external-event/          # Thread-safe async & RevitTask dispatcher
│   ├── revit-parameter-manager/       # Parameters & ForgeTypeId conversions
│   ├── revit-element-collector/       # High-speed FilteredElementCollector recipes
│   ├── revit-geometry-analysis/       # Solids, boolean intersections, ray casting
│   ├── revit-failure-handler/         # Warning suppression & IFailuresPreprocessor
│   ├── revit-model-validation/        # Model health audits & QA/QC checkers
│   └── revit-dockable-panel/          # Dockable panels & WPF MVVM palettes
├── templates/                         # Tested C# project templates
│   └── CleanRevitAddin/               # Complete solution targeting Revit 2024-2026
├── cli/                               # Framework installer and plugin generator CLI
│   ├── bim-ai.ps1                     # PowerShell cross-platform CLI tool
│   ├── bim-ai.sh                      # Bash CLI wrapper
│   └── bim-ai.cmd                     # Windows batch runner
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # MIT License
└── README.md
```

---

---

## 💡 How Is This Different From Other Revit AI Projects?

There is a fundamental difference between **BIM-AI-Foundation** and existing tools like `revit-mcp-server` or `RevitMCPBridge`:

| Feature | Runtime MCP Bridges (`revit-mcp-server`, `RevitMCPBridge`) | **BIM-AI-Foundation** (This Repository) |
| :--- | :--- | :--- |
| **Who is it for?** | **End-Users / BIM Modelers** | **BIM Developers & Software Engineers** |
| **What does it do?** | Controls an already-running Revit session via chat (e.g. *"Delete wall 105"*, *"Export sheets"*). | **Builds brand new, standalone Revit plugins (`.dll`), custom ribbon buttons, and tools.** |
| **Does Revit need to be open?** | **Yes.** Requires an open Revit instance connected via local socket or named pipe. | **No.** Works at development time in your code editor (Cursor, VS Code, Claude Code). |
| **Can you create custom Revit buttons?** | ❌ No. Cannot create distributable compiled add-ins or Ribbon UI. | 🟢 **Yes!** Fully scaffolds Ribbon tabs, buttons, dockable palettes, and commands. |
| **Multi-version C# compilation** | ❌ None. | 🟢 **Built-in multi-targeting for Revit 2024, 2025, and 2026** (.NET 4.8 and .NET 8.0). |
| **Prevents AI hallucinations & crashes** | ❌ No. (Doesn't guide AI when writing plugin code). | 🟢 **Yes!** Enforces STA threading, `RevitTask`, transaction scoping, and version rules. |

---

## 🛠️ Step-by-Step: How to Create a Custom Revit Tool / Button

If you want to build a tool or feature that Revit doesn't natively have, follow this 5-minute walkthrough:

### Step 1: Scaffold your new plugin project
Open your terminal and run:
```powershell
pwsh ./cli/bim-ai.ps1 new -Name "SmartWallAutomation" -TargetDir "C:\MyRevitPlugins"
```
This generates a complete, multi-targeted C# solution (`C:\MyRevitPlugins\SmartWallAutomation`) pre-configured for Revit 2024, 2025, and 2026, complete with Ribbon UI, dockable panel, and all AI rules pre-installed.

### Step 2: Open the project in your favorite AI editor
Open the folder `C:\MyRevitPlugins\SmartWallAutomation` in **Cursor**, **VS Code** (with GitHub Copilot), or run **Claude Code**.

### Step 3: Tell your AI what button you want to build
In your AI chat / Composer, simply prompt:
> *"Add a new Ribbon button called 'Audit Missing Marks' under our BIM Tools tab. When clicked, it should find all doors without a Mark, assign sequential mark numbers starting from D-101, swallow any duplicate mark warnings, and show a summary TaskDialog."*

### Step 4: AI writes 100% correct code without hallucination
Because your project contains `AGENTS.md` and `skills/`, the AI assistant will automatically:
1. Use `skills/revit-failure-handler` to suppress popup warnings.
2. Use `skills/revit-parameter-manager` to safely write parameters without throwing exceptions.
3. Use `skills/revit-external-event` to ensure thread-safety.
4. Support both Revit 2024 (.NET 4.8) and Revit 2025/2026 (.NET 8.0).

### Step 5: Build and run in Revit
Press `Ctrl + Shift + B` in Visual Studio or run:
```bash
dotnet build
```
Your compiled add-in (`SmartWallAutomation.dll` and `.addin`) will be automatically placed into Revit's add-ins folder. Launch Revit, and your brand new custom button will appear in the ribbon ready to use!

---

## ❓ Frequently Asked Questions (FAQ)

### Q: Does this repository require an active connection to Revit or the cloud?
**No.** This is a software engineering foundation that runs locally in your code editor. Your AI coding assistant (Cursor, Claude Code, Copilot) uses this repository's instructions, skills, and templates to write accurate Revit C# code. You only launch Revit when you want to run and test your compiled add-in.

### Q: Can I use this with an existing Revit plugin I already developed?
**Yes!** Open your existing plugin folder and run:
```powershell
pwsh ./cli/bim-ai.ps1 init -TargetDir "C:\Path\To\Your\ExistingPlugin"
```
This injects `AGENTS.md`, `.cursor/rules/`, and the skills catalog into your existing repository so AI assistants immediately follow Revit best practices.

### Q: Can I validate my existing C# code for Revit bugs?
**Yes!** Run:
```powershell
pwsh ./cli/bim-ai.ps1 validate -TargetDir "C:\Path\To\Your\ExistingPlugin"
```
It will scan your code and warn you about obsolete APIs (`ElementId.IntegerValue`), deprecated parameter types, or unsafe thread calls (`Task.Run`).

---

## 🛠️ CLI Quickstart Reference

### Option A: Scaffold a Brand New Multi-Version Plugin
```powershell
pwsh ./cli/bim-ai.ps1 new -Name "MyCoolAddin" -TargetDir "C:\Projects"
```

### Option B: Inject AI Rules into an Existing Plugin Repository
```powershell
pwsh ./cli/bim-ai.ps1 init -TargetDir "C:\MyExistingPlugin"
```

### Option C: Validate an Existing Codebase for Revit Anti-Patterns
```powershell
pwsh ./cli/bim-ai.ps1 validate -TargetDir "C:\MyExistingPlugin"
```

---

## 🧪 Testing and Building

Build the multi-version template across all supported versions:
```bash
# Build the entire solution:
dotnet build templates/CleanRevitAddin/CleanRevitAddin.sln

# Build specifically for Revit 2024 (.NET Framework 4.8):
dotnet build -f net48 -c "Release R24"

# Build specifically for Revit 2025 (.NET 8.0):
dotnet build -f net8.0-windows -c "Release R25"

# Build specifically for Revit 2026 (.NET 8.0):
dotnet build -f net8.0-windows -c "Release R26"
```

---

## 🗺️ Roadmap & Platform Expansion
- [x] Master AI instructions & progressive disclosure router
- [x] Autodesk Revit 2024, 2025, 2026 (.NET 4.8 & .NET 8.0)
- [x] Initial suite of 8 core Agent Skills
- [x] Multi-targeting C# Clean Architecture template
- [x] CLI installer and code validator
- [ ] Autodesk Civil 3D support (AutoCAD/Civil 3D API skills & rules)
- [ ] Autodesk Navisworks support (Clash & coordination add-in skills)
- [ ] Tekla Structures Open API skills
- [ ] OpenBIM / IFC code generation rules (Xbim, IfcOpenShell)

---

## 🤝 Contributing
Contributions are warmly welcomed! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on submitting new Agent Skills or enhancing the technical knowledge base.

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---

## 🌐 Official Repository
* **GitHub:** [https://github.com/AbhishekAbhishek1/BIM-AI-Foundation](https://github.com/AbhishekAbhishek1/BIM-AI-Foundation)
* **Clone:** `git clone https://github.com/AbhishekAbhishek1/BIM-AI-Foundation.git`
