# System Architecture: BIM-AI-Foundation
<!-- BIM-AI-Foundation | Architecture Guide -->

## 1. Architectural Vision
**BIM-AI-Foundation** is an open-source development and knowledge framework for building AEC/BIM software with AI coding assistants.

Unlike runtime MCP servers (which enable end-users to interactively control a running Revit session), BIM-AI-Foundation operates at **development time**, equipping AI coding assistants (Claude Code, Cursor, Copilot, Codex, Antigravity) with the domain knowledge, rules, and skills necessary to write high-quality, compile-ready, crash-free Revit add-ins.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        AI CODING ASSISTANTS                            │
│           (Claude Code, Cursor, GitHub Copilot, Codex)                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                         Reads on Semantic Match
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                         BIM-AI-FOUNDATION                              │
├───────────────────────────────────┬────────────────────────────────────┤
│ 1. Master AI Instructions         │ 2. Progressive Skill Router        │
│    - AGENTS.md (AAIF Open Spec)   │    - skills/*/SKILL.md             │
│    - CLAUDE.md                    │    - Token-optimized definitions   │
│    - .cursor/rules/*.mdc          │                                    │
│    - .github/copilot-instructions │                                    │
├───────────────────────────────────┼────────────────────────────────────┤
│ 3. Technical Knowledge Base       │ 4. Multi-Targeted Code Templates   │
│    - STA Threading Invariants     │    - CleanRevitAddin               │
│    - Transaction Lifecycles       │    - Nice3point Build Tasks        │
│    - ForgeTypeId / UnitUtils      │    - Revit 2024 (.NET 4.8)         │
│    - 2024-2026 Breaking Changes   │    - Revit 2025/2026 (.NET 8.0)    │
└───────────────────────────────────┴────────────────────────────────────┘
                                    │
                         Generates / Scaffolds
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                     COMPILED REVIT ADD-IN (.DLL)                       │
│             Loaded natively into Autodesk Revit 2024-2026              │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Key Subsystems

### 2.1 The Multi-AI Configuration Layer
Different AI tools read rules from different paths:
- `AGENTS.md`: The emerging vendor-neutral open standard (AAIF / Linux Foundation).
- `CLAUDE.md`: Anthropic Claude Code entry point.
- `.cursor/rules/*.mdc`: Modern Cursor modular rules engine with YAML frontmatter, globs, and auto-attach triggers.
- `.github/copilot-instructions.md`: GitHub Copilot workspace context.
- `.windsurfrules`: Windsurf IDE rules.

BIM-AI-Foundation maintains a synchronized layer across all formats so developers can use their AI tool of choice.

### 2.2 The Agent Skills Specification (`agentskills.io`)
Skills are packaged as self-contained directories containing a `SKILL.md` file with standard YAML frontmatter:
- `name`: Lowercase identifier matching directory name.
- `description`: Explains what the skill does and **when the agent should activate it**.
- `compatibility`: Declares supported Revit and .NET versions.
- `metadata`: Supplemental author and version tags.

### 2.3 The Progressive Disclosure Engine
To prevent prompt context window exhaustion, BIM-AI-Foundation uses a 2-tier retrieval architecture:
1. **Tier 1 (Root Router ~1.2k tokens):** The master instruction file provides fundamental invariants and a semantic router mapping tasks to skill paths.
2. **Tier 2 (On-Demand Deep Dives ~2k tokens):** The AI assistant dynamically reads only the specific `SKILL.md` or `knowledge/*.md` file relevant to the active user prompt.
