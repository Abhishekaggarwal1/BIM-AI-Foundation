---
name: navisworks-plugin-scaffold
description: |
  Scaffolding Autodesk Navisworks .NET plugins (C#), automating Clash Detective tests, creating saved search sets, and exporting coordination reports.
  Use whenever user asks to create Navisworks plugins, automate Navisworks clashes, manipulate Navisworks Document/ModelItem hierarchy, or build Navisworks ribbons.
compatibility: Autodesk Navisworks Manage & Simulate 2024-2026 (.NET Framework 4.8 / .NET 8).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Navisworks Plugin Scaffold & Clash Automation Skill

Autodesk Navisworks is the AEC industry standard for multi-disciplinary coordination, 4D simulation, and clash detection.

---

## 1. Prime Invariants for Navisworks Development

### 1.1 Plugin Class Attributes
Every Navisworks add-in requires two core attributes on the plugin class:
```csharp
using Autodesk.Navisworks.Api.Plugins;

[Plugin("BimNavisAutomation", "BIMFOUNDATION", DisplayName = "BIM Clash Automator", ToolTip = "Automates clash test grouping and reporting")]
[AddInPlugin(AddInLocation.AddIn)]
public class ClashAutomationPlugin : AddInPlugin
{
    public override int Execute(params string[] parameters)
    {
        // Execution entry point
        return 0;
    }
}
```

### 1.2 Accessing the Active Document & Selection Tree
* Access the document via `Autodesk.Navisworks.Api.Application.ActiveDocument`.
* Elements are represented as `ModelItem` hierarchies:
  ```csharp
  Document doc = Application.ActiveDocument;
  ModelItemEnumerableCollection selection = doc.CurrentSelection.SelectedItems;
  ```

### 1.3 Clash Detective Automation
* Access clash tests via `DocumentClash.GetClash(doc)`.
* Clash tests are contained within `docClash.TestsData.Tests`:
  ```csharp
  using Autodesk.Navisworks.Api.Clash;

  DocumentClash docClash = DocumentClash.GetClash(doc);
  foreach (ClashTest test in docClash.TestsData.Tests)
  {
      // Iterate test results
      foreach (ClashResult result in test.Children)
      {
          ModelItem item1 = result.Item1;
          ModelItem item2 = result.Item2;
          double distance = result.Distance;
      }
  }
  ```

---

## 2. Standard Navisworks Plugin Template

```csharp
using System;
using System.Windows.Forms;
using Autodesk.Navisworks.Api;
using Autodesk.Navisworks.Api.Clash;
using Autodesk.Navisworks.Api.Plugins;

namespace BimNavisworksAddin
{
    [Plugin("BimNavisAuditor", "BIMAIFOUNDATION", DisplayName = "Audit Clash Tests", ToolTip = "Audits all clash tests in the active model")]
    [AddInPlugin(AddInLocation.AddIn)]
    public class NavisworksAuditorPlugin : AddInPlugin
    {
        public override int Execute(params string[] parameters)
        {
            Document doc = Autodesk.Navisworks.Api.Application.ActiveDocument;
            if (doc == null)
            {
                MessageBox.Show("No active Navisworks document found.", "Error");
                return 0;
            }

            DocumentClash docClash = DocumentClash.GetClash(doc);
            if (docClash == null || docClash.TestsData == null)
            {
                MessageBox.Show("Clash Detective data is unavailable.", "Clash Auditor");
                return 0;
            }

            int totalTests = docClash.TestsData.Tests.Count;
            int totalClashes = 0;

            foreach (var test in docClash.TestsData.Tests)
            {
                if (test is ClashTest clashTest)
                {
                    totalClashes += clashTest.Children.Count;
                }
            }

            MessageBox.Show(
                $"Coordination Audit Summary:\n- Total Clash Tests: {totalTests}\n- Total Clashes Recorded: {totalClashes}",
                "BIM-AI-Foundation Clash Audit"
            );

            return 0;
        }
    }
}
```
