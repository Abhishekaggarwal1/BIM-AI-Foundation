---
name: revit-dockable-panel
description: |
  Creation and registration of modern WPF dockable panels / palettes inside Autodesk Revit using MVVM.
  Use whenever user asks to create a side panel, palette, dockable dialog, or modern tool window in Revit.
compatibility: Targets Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Dockable Panel Skill

Dockable panels must be registered once during `IExternalApplication.OnStartup`.

## Registration Workflow

1. Create a WPF `Page` implementing `IDockablePaneProvider`.
2. Define a unique static `DockablePaneId` (using a static GUID).
3. Call `application.RegisterDockablePane(id, "Title", page)` in `OnStartup`.
4. Provide a command to show the pane via `uiApp.GetDockablePane(id).Show()`.

Reference `examples/DockablePanelTemplate.xaml` and `examples/DockablePanelTemplate.xaml.cs`.
