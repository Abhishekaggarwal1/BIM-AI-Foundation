# Contributing to BIM-AI-Foundation

We welcome contributions from the global BIM and AEC software engineering community!

## How You Can Contribute

1. **Add New Agent Skills (`skills/<skill-name>/`):**
   - Each skill must follow the `agentskills.io` standard with a `SKILL.md` file and standard YAML frontmatter (`name`, `description`, `compatibility`, `metadata`).
   - Include verified, minimal code snippets or complete tested classes in an `examples/` subfolder.
2. **Update Knowledge Base (`knowledge/`):**
   - Improve documentation on Revit API edge cases, performance quirks, or undocumented behavior.
   - Expand the `breaking-changes-matrix.md` with new release details.
3. **Expand to Other BIM Platforms:**
   - Architecture is designed to accommodate Autodesk Civil 3D, Navisworks, Tekla Structures, Rhino/Inside, and IFC tools in future milestones.
4. **Improve CLI & Tooling (`cli/`):**
   - Enhance the PowerShell/Bash CLI, add Roslyn-based analyzers, or build validation hooks.

## Contribution Guidelines
- Keep skill files concise (< 500 lines) to preserve AI context windows.
- Always verify code against both .NET Framework 4.8 (Revit 2024) and .NET 8.0 (Revit 2025/2026).
- Adhere to the MIT License terms.
