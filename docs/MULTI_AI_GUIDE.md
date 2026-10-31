# Multi-AI Setup & Integration Guide
<!-- BIM-AI-Foundation | User Guide -->

This guide explains how to use BIM-AI-Foundation with your preferred AI coding assistant.

---

## 1. Claude Code (CLI)
Claude Code automatically parses `CLAUDE.md` in the current project root:
1. Clone or initialize the repository:
   ```bash
   pwsh ./cli/bim-ai.ps1 init -TargetDir "path/to/your/project"
   ```
2. Run Claude Code:
   ```bash
   claude
   ```
3. Ask your prompt directly (e.g., *"Create an external command that extracts all unplaced rooms and displays them in a WPF dialog"*). Claude will read `CLAUDE.md` and load matching skills.

---

## 2. Cursor IDE
Cursor uses modular rules defined in `.cursor/rules/*.mdc`:
1. When opening any project initialized with `bim-ai init`, Cursor automatically attaches:
   - `revit-core.mdc` (always active)
   - `revit-versions.mdc` (active for C# files)
   - `revit-architecture.mdc` (active for MVVM/WPF files)
2. Use `@` symbols in the Composer/Chat to mention specific skills (e.g., `@revit-dockable-panel/SKILL.md`).

---

## 3. GitHub Copilot (VS Code / Visual Studio)
GitHub Copilot reads workspace instructions from `.github/copilot-instructions.md`:
1. Initialize your project with `bim-ai init`.
2. Open the project in VS Code or Visual Studio with GitHub Copilot installed.
3. Copilot Chat will automatically adhere to the Revit STA threading rules, transaction scoping, and version constraints.

---

## 4. Antigravity & OpenAI Codex
BIM-AI-Foundation includes the root `AGENTS.md` standard file, which is natively loaded by Antigravity, OpenAI Codex, and compliant autonomous developer agents.
