---
name: aps-design-automation
description: |
  Developing cloud-based headless Revit batch automation engines using Autodesk Platform Services (APS, formerly Forge) Design Automation API for Revit.
  Use whenever user asks to run Revit add-ins in the cloud, batch-process models headlessly on APS/Forge, create AppBundles, or execute Design Automation Workitems.
compatibility: APS Design Automation v3 / Revit 2024-2026 engines.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# APS Design Automation for Revit Skill

Autodesk Platform Services (APS) Design Automation runs headless Revit engines in AWS cloud containers to batch-process, export, or audit BIM models at scale.

---

## 1. Core Invariants for Design Automation

1. **Zero UI:** `Autodesk.Revit.UI` is unavailable. Any attempt to show a `TaskDialog`, WPF window, or Windows Form will cause the cloud worker container to hang and fail with a timeout!
2. **`DesignAutomationData` Interface:**
   The entry point implements `DesignAutomationHandler`:
   ```csharp
   using Autodesk.Revit.DB;
   using DesignAutomationFramework;

   public void HandleDesignAutomationReadyEvent(object sender, DesignAutomationReadyEventArgs e)
   {
       e.Succeeded = true;
       ProcessModel(e.DesignAutomationData);
   }

   private void ProcessModel(DesignAutomationData data)
   {
       Document doc = data.RevitDoc;
       // Execute unattended model changes or data extraction...
   }
   ```
3. **AppBundle Package Structure:**
   * Contains `<AddinName>.bundle` with `PackageContents.xml`.
   * ZIP archive uploaded to APS Design Automation endpoint.
