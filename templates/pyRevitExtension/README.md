# pyRevit Extension Template

This template provides a production-ready **pyRevit Extension** scaffold for developers writing Python tools and custom Ribbon buttons for Autodesk Revit.

---

## Folder Structure

```text
{{Name}}.extension/
└── {{Name}}.tab/
    └── Automation.panel/
        ├── ModelAudit.pushbutton/
        │   ├── bundle.yaml
        │   └── script.py
        └── WallJoiner.pushbutton/
            ├── bundle.yaml
            └── script.py
```

---

## How to Install and Test in Revit

1. **Option A: Register via pyRevit CLI**
   ```bash
   pyrevit extend ui {{Name}} <path-to-folder-containing-extension>
   ```

2. **Option B: Place in pyRevit Extensions Folder**
   Copy the `{{Name}}.extension` folder to:
   * `%APPDATA%\pyRevit\Extensions\`

3. **Reload pyRevit in Revit:**
   * Go to the **pyRevit** tab in Revit.
   * Click **Reload** (or hold `Ctrl` + click `Reload` to clear cache).
   * Your custom tab `{{Name}}` will appear with your buttons!

---

## Developing with AI Coding Assistants

Because this folder includes `BIM-AI-Foundation` rules:
- Any AI assistant (Cursor, Claude Code, GitHub Copilot) will automatically format new `.pushbutton` directories with `bundle.yaml` and `script.py`.
- Scripts will use high-performance `FilteredElementCollector` quick filters, 64-bit `ElementId.Value`, and safe `with revit.Transaction()` blocks.
