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
2. **Modular Agent Skills (`agentskills.io` standard):** Task-specific procedural recipes that AI assistants load dynamically on-demand, reducing prompt token bloat by **85–90%**.
3. **Revit 2024–2026 Version Breaking Change Matrix:** Accurate guidance on the historic .NET Framework 4.8 to .NET 8.0 migration in Revit 2025, `ElementId.Value` (Int64), and `ForgeTypeId`.
4. **Multi-Targeted C# Project Template:** Production-tested Clean Architecture template (`templates/CleanRevitAddin`) compiling for Revit 2024, 2025, and 2026 from a single codebase via `Nice3point.Revit.Build.Tasks`.
5. **Multi-AI Compatibility:** Instant out-of-the-box support for Claude Code, Cursor IDE, GitHub Copilot, Windsurf, and OpenAI Codex.
6. **Developer CLI (`cli/bim-ai.ps1`):** A command-line tool to initialize existing repositories, scaffold new add-ins, and validate C# code for Revit anti-patterns.

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
│   ├── revit-api/                     # Deep dives (threading, transactions, filters, geometry)
│   ├── versions/                      # Revit 2024, 2025, 2026 specifics
│   └── architecture/                  # Clean Architecture, MVVM, and DI
├── skills/                            # Agent Skills specification (agentskills.io)
│   ├── revit-plugin-scaffold/         # Scaffolding modern multi-version addins
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

## 🛠️ Quickstart

### Option A: Scaffold a Brand New Multi-Version Plugin
```powershell
# In PowerShell:
pwsh ./cli/bim-ai.ps1 new -Name "MyCoolAddin" -TargetDir "C:\Projects"
```
This generates a complete, compile-ready multi-targeted solution for Revit 2024, 2025, and 2026 with all AI rules and skills pre-installed.

### Option B: Inject AI Rules into an Existing Plugin Repository
```powershell
pwsh ./cli/bim-ai.ps1 init -TargetDir "C:\MyExistingPlugin"
```
Immediately equips your existing repository with `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, and the BIM skills catalog.

### Option C: Validate an Existing Codebase for Revit Anti-Patterns
```powershell
pwsh ./cli/bim-ai.ps1 validate -TargetDir "C:\MyExistingPlugin"
```
Scans your C# code for deprecated `ElementId.IntegerValue`, obsolete `ParameterType`, and dangerous un-dispatched `Task.Run()` calls.

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
